\
\ source.f
\
.( SOURCE )

\ a is the address of, and u is the number of characters in, the input buffer.

: SOURCE ( -- a u )

    SOURCE-ID @ 
    IF    
        \ during INCLUDE/NEEDS or EVALUATE
        1 BLOCK 85
    ELSE
        BLK @ IF
            >IN @ BLK @ B/SCR /MOD -ROT          \ scr  in  r
            B/BUF * + C/L / SWAP                 \ row  scr
            (LINE)                               \ a n
        ELSE
            TIB @ C/L                            \ whatever...
        THEN
    THEN
    
;

