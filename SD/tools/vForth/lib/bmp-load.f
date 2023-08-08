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

VARIABLE BMP-FH

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

HEX

: BMP-LOAD ( -- )  
    \ address a must be a "counted z-string address", the kind created by ,"
    PAD 0 01 F_OPEN  29 ?ERROR  \ open error.
    \ save file-handle number
    >R
    \ read to HERE first 50 bytes of header (50=32h)
    HERE 32 R@ F_READ 
    SWAP 32 - OR R@ 2E ?BMP-ERROR \ read-error
    
    \ check BMP signature
    HERE      @    4D42 - R@ 26 ?BMP-ERROR \ not a BMP file
    \ horizontal size in pixels (signed integer) 
    HERE 12 + @ ABS 100 - R@ 26 ?BMP-ERROR \ not a BMP file
    \ vertical size in pixel (signed integer) 
    HERE 16 + @ ABS 0C0 - R@ 26 ?BMP-ERROR \ not a BMP file
    
    \ take offset to payload-data, skipping header
    HERE 0A + 2@ SWAP 
    R@ F_SEEK R@ 2D ?BMP-ERROR \ pos error

    \ Loop for each  8k page
    6 0 DO
        \ depending on sign of vertical sign determine page number
        HERE 16 + @ 0< IF I ELSE 5 I - THEN 
        \ fit the correct 8K page at MMU7
        12 REG@ 2* + MMU7!            
        \ read 32 rows
        20 0 DO
            HERE 16 + @ 0< IF I ELSE 1F I -  THEN 
            FLIP E000 OR \ destination address
            100 R@ F_READ 46 ?ERROR 
            DROP \ ignore number of byte read
        LOOP
    LOOP
    \ close file using file-handle number
    R> F_CLOSE  42 ?ERROR
;

BASE !
