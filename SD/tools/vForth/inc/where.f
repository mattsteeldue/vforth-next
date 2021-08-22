\
\ where.f
\
.( WHERE )
\
\ \ usually used after an error during LOAD:
\
\ where
\ usually used after an error during LOAD:
: WHERE ( n1 n2 -- ) \ display offending row after an error
    DUP                                 \ >in  blk  blk
    B/SCR /MOD                          \ >in  blk  r   scr
    DUP SCR !                           \ >in  blk  r   scr
    ." Screen# " DECIMAL . CR           \ >in  blk  r   
    B/BUF *                             \ >in  blk  n
    ROT +                               \ blk  >in+n
    C/L /MOD                            \ blk  byt  row
    DUP 3 .R SPACE                      \ blk  byt  row
    ROT                                 \ byt  row  blk  
    B/SCR /                             \ byt  row  scr
    (LINE) -TRAILING TYPE               \ byt  
    CR 2+ SPACES [CHAR] ^ EMIT SPACE
;
\
