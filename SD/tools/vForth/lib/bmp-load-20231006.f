\
\ bmp-load.f
\

.( BMP-LOAD )

\ load a .bmp file in Layer-2 memory
\
\ LOAD-BMP performs the following steps
\  - check for "BM" signature for error checking
\  - check for (signed) vertical size 
\ Example:
\   NEEDS WAIT-KEY  NEEDS LAYERS  NEEDS PAD"
\   PAD" C:/demos/bmp256converts/bitmaps/future.bmp"
\   BMP-LOAD 
\   lAYER2 WAIT-KEY lAYER12

BASE @ DECIMAL

NEEDS FLIP

\ wrapper around ERROR to close file-handle before giving up.
\ like ?ERROR it expects a flag and the error-code number,
: ?BMP-ERROR ( f fh n -- )
    ROT IF
        SWAP F_CLOSE DROP
        ERROR
    ELSE
        2DROP
    THEN
;

$12 REG@ 2* CONSTANT BMP-PAGE
VARIABLE BMP-FH
CREATE   BMP-HEADER 50 ALLOT


: BMP-FH-CHECK ( fh -- )
    \ filehandle in return-stack
    >R
    \ read to PAD first 50 bytes of header (50=32h)
    BMP-HEADER  50      R@ F_READ 
           SWAP 50 - OR R@ $2E ?BMP-ERROR \ read-error
    \ check BMP signature
    BMP-HEADER        @    $4D42 - R@ $26 ?BMP-ERROR \ not a BMP file
    \ horizontal size in pixels (signed integer) 
    BMP-HEADER  $12 + @ ABS $100 - R@ $26 ?BMP-ERROR \ not a BMP file
    \ vertical size in pixel (signed integer) 
    BMP-HEADER  $16 + @ ABS $0C0 - R@ $26 ?BMP-ERROR \ not a BMP file
    \ take offset to payload-data, skipping header
    PAD  $0A + 2@ SWAP 
    R@ F_SEEK R@ $2D ?BMP-ERROR \ pos error
    R> DROP
;


: BMP-FH-LOAD-LINE ( b fh -- )
    \ read 32 rows
    >R
    32 0 DO
        FLIP $E000 OR \ destination address
        $100 R@ F_READ 46 ?BMP-ERROR
        DROP \ ignore number of byte read
    LOOP
    R> DROP
;


: BMP-FH-LOAD ( fh -- )
    \ Loop for each  8k page
    BMP-HEADER  $16 + @ 0< 
    IF 
        BMP-PAGE 6 + BMP-PAGE 
        DO
            \ fit the correct 8K page at MMU7
            I MMU7!            
            I .
        LOOP
    ELSE 
        BMP-PAGE BMP-PAGE 5 +
        DO
            \ fit the correct 8K page at MMU7
            I MMU7!            
            I .
        -1 +LOOP
    THEN
    CR .
;



: BMP-LOAD ( -- )  
    \ address a must be a "z-string address" at PAD
    PAD PAD 10 - 01               
    F_OPEN  $29 ?ERROR              \ open error.
    
    DUP BMP-FH-CHECK
    DUP BMP-FH-LOAD
    
    \ close file using file-handle number
    F_CLOSE  42 ?ERROR
;

BASE !
