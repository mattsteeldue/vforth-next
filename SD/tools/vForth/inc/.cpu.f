\
\ .cpu.f
\
.( .cpu included ) 6 EMIT
\
\ .cpu
\ shows the cpu name (Z80)
: .CPU
    BASE @
    [ DECIMAL 36 ] LITERAL BASE !
    \ at address 16 +ORIGIN there is a value that shows "Z80" 
    [ HEX 10     ] LITERAL +ORIGIN @ U.
    BASE !
;
\
DECIMAL
\
