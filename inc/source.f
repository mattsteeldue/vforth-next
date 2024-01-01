\
\ source.f
\
.( SOURCE )

\ a is the address of, and u is the number of characters in, the input buffer.

VARIABLE SOURCE-P   \ heap pointer address of string
VARIABLE SOURCE-L   \ length of string

0 SOURCE-P !
0 SOURCE-L !


: SOURCE ( -- a u )

    SOURCE-ID @ 

    \ during EVALUATE source-id is negative
    0< IF    
        \ during EVALUATE current input buffer is put there
        SOURCE-P @ FAR     \ a
        SOURCE-L @         \ u
    ELSE
        SOURCE-ID @ 
        IF
            \ during INCLUDE/NEEDS source-id is an open file-handle [2,15] 
            \ the input buffer is exploited via 1 BLOCK.
            1 BLOCK C/L 2*
        ELSE
            \ during LOAD or input from keyboard source is zero 
            BLK @ 
            IF
                \ BLK is non-zero during a LOAD
                >IN @ BLK @ B/SCR /MOD -ROT          \ scr  in  r
                B/BUF * + C/L / SWAP                 \ row  scr
                (LINE)                               \ a n
            ELSE
                \ BLK is zero during keyboard input
                TIB @ C/L
            THEN
        THEN
    THEN
;

