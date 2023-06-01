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
    BLOCK               \ a
    DUP C/L BLANK       \ a
    [CHAR] \ OVER C!    \ a
    PAD OVER 2+ C/L     \ a  pad a+2 u
    CMOVE               \ a
    C/L +               \ a1
    B/BUF C/L -         \ a1 u1
    LOAD-BYTES          \
    UPDATE              \
;

BASE !
