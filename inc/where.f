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
    DUP B/SCR /MOD DUP SCR ! 
    ." Screen# " DECIMAL . CR
    B/BUF * ROT + C/L /MOD DUP 3 .R SPACE
    ROT B/SCR / (LINE) -TRAILING TYPE
    CR 2+ SPACES [CHAR] ^ EMIT SPACE
;
\
