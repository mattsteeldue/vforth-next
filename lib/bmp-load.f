\
\ bmp-load.f
\
\ v-Forth 1.8 - NextZXOS version - build 2025-01-01            
\ MIT License (c) 1990-2025 Matteo Vitturi     
\
\ load a .bmp file in Layer 2 memory
\
\ LOAD-BMP performs the following steps
\  - check for "BM" signature for error checking
\  - check for (signed) vertical size 
\ Example:
\ create filename 
\     ," C:/demos/bmp256converts/bitmaps/future.bmp"
\ filename bmp-load 
\     Layer2 wait-key Layer12

NEEDS FLIP
NEEDS S"

VARIABLE BMP-FH
VARIABLE BMP-FN 

VARIABLE BMP-HS \ horizontal size in pixels (signed integer) 
VARIABLE BMP-VS \ vertical size in pixel (signed integer) 

$12 REG@ 
CONSTANT L2-RAM-PAGE           \ keeps Layer 2 Active RAM Page


\ wrapper around ERROR to close file-handle before giving up.
\ like ?ERROR it expects a flag and the error-code number,
: BMP-ERROR ( f n -- )
    SWAP IF
        BMP-FH @ F_CLOSE DROP
        BMP-FN @ COUNT TYPE SPACE
        ERROR
    ELSE
        DROP
    THEN
;


: BMP-LOAD ( a -- )  
    \ address a must be a "counted z-string address", the kind created by ,"
    DUP BMP-FN !
    1+ 0 01 F_OPEN #41 ?ERROR  \ open error.
    \ store file-handle number
    BMP-FH !    
    \ read to PAD first 50 bytes of header (50=32h)
    PAD $32 BMP-FH @ F_READ 
    SWAP $32 - OR  #46 BMP-ERROR \ read-error

    \ take (signed) size
    PAD $12 + @ BMP-HS !
    PAD $16 + @ BMP-VS !

    \ check BMP signature
    PAD @ $4D42 -       #38 BMP-ERROR \ not a BMP file
    BMP-HS @ ABS $100 - #38 BMP-ERROR \ not a BMP file
    BMP-VS @ ABS $0C0 - #39 BMP-ERROR \ not a BMP file
    
    \ take offset to payload-data, skipping header
    PAD $0A + 2@ SWAP 
    BMP-FH @ F_SEEK     #45 BMP-ERROR \ pos error

    \ Loop for each  8k page
    6 0 DO
        \ depending on sign of vertical sign determine page number
        BMP-VS @ 0< IF I ELSE 5 I - THEN 
        \ fit the correct 8K page at MMU7
        L2-RAM-PAGE 2* + MMU7!            
        \ read 32 rows
        $20 0 DO
            BMP-VS @ 0< IF I ELSE $1F I -  THEN 
            FLIP $E000 OR \ destination address
            $100 BMP-FH @ F_READ #46 ?ERROR 
            DROP \ ignore number of byte read
        LOOP
    LOOP
    \ close file using file-handle number
    BMP-FH @ F_CLOSE  #42 ?ERROR
;


: (BMP-LOAD)      ( a n -- )
    >R
    PAD R@              \ a pad n
    CMOVE               
    0 PAD R> + C!
    PAD 1- BMP-LOAD
;


: BMP-LOAD" ( -- cccc )
    STATE @
    IF
        [compile] s"        \ at runtime: addr n
        compile (BMP-LOAD) 
    ELSE
        [char] "  word count over + 0 swap !      \ get a string
        1- 
        BMP-LOAD
    THEN
; IMMEDIATE

DECIMAL
