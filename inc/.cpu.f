\
\ .cpu.f
\
.( .cpu )
\
\ .cpu
\ given a cfa or an xt, it determines the name and shows it using ID.
: .CPU
    BASE @
    [ DECIMAL 36 ] LITERAL BASE !
    [ HEX 10     ] LITERAL +ORIGIN @ U.
    BASE !
;
\
DECIMAL
\
