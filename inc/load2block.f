\
\ load2block.f
\

.( LOAD2BLOCK ) 

\ load up to 448 bytes from filename held in PAD to specified BLOCK n
\ starting from line 1 while filename string itself is copied to line 0.
\ PAD is volatile.

\ Example:
\ PAD" /sfx/zxgames/arcanoid2_1.afx" 4400 LOAD2BLOCK

NEEDS LOAD-BYTES

BASE @

DECIMAL

\ n BLOCK number
\ WARNING: In this implementation a Screen occupies two BLOCKs
\ WARNING: so for example Screen# 440 is BLOCK 880.
: LOAD2BLOCK ( n -- )
    \ assign a BUFFER and load BLOCK n into it
    BLOCK               \ a
    \ blank the first row to accomodate the filename (64 bytes)
    DUP C/L BLANK       \ a
    \ and prepare a comment 
    [CHAR] (            \ a  b   )
    OVER C!             \ a 
    \ copy filename to this comment line
    PAD C/L             \ a  pad u
    -TRAILING 1-        \ a  pad u1
    >R OVER 2+ R>       \ a  pad a+2 u1
    CMOVE               \ a
    \ advance address to the second line
    C/L +               \ a1
    B/BUF C/L -         \ a1 u1
    \ load up to 448 bytes to BLOCK
    LOAD-BYTES          \
    \ mark the block for update
    UPDATE              \
;

BASE !
