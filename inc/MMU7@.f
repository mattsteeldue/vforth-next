\
\ mmu7@.f
\
.( MMU7@ )
\

NEEDS REG@

BASE @

\ query current page in MMU7 8K-RAM : 0 and 223
: MMU7@ ( -- n )
    [ DECIMAL 87 ] LITERAL REG@
;

BASE !
