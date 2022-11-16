\
\ source.f
\
.( SOURCE )

\ a is the address of, and u is the number of characters in, the input buffer.

VARIABLE SOURCE-P
VARIABLE SOURCE-L
0 SOURCE-P !
0 SOURCE-L !

: SOURCE ( -- a u )

    \ first check for negative SOURCE-ID, i.e. during EVALUATE
    SOURCE-ID @ 1+
    IF    
        SOURCE-ID @ 
        IF
            \ ." source-id is greater than zero " CR
            \ source-id is an open file-handle [2,15] during INCLUDE/NEEDS 
            \ the input buffer is exploited via 1 BLOCK.
            1 BLOCK 80 \ B/BUF
        ELSE
            \ source is zero during LOAD and keyboard input.
            BLK @ 
            IF
                \ ." source-id is zero and BLK not " CR
                \ BLK is non zero during a LOAD
                >IN @ BLK @ B/SCR /MOD -ROT          \ scr  in  r
                B/BUF * + C/L / SWAP                 \ row  scr
                (LINE)                               \ a n
            ELSE
                \ ." source-id is zero and BLK too " CR
                \ BLK is zero during keyboard input
                TIB @ C/L                            \ whatever...
            THEN
        THEN
    ELSE
        \ ." source-id is negative " CR
        \ during EVALUATE current input buffer is put there
        SOURCE-P @         \ a
        SOURCE-L @         \ u
    THEN
;

