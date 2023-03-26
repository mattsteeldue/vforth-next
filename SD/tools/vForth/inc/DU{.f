\ du{.f
\
.( DU< )
\

NEEDS D<

BASE @
HEX
\
: DU< ( d1 d2 -- f )
    8000 XOR 
    ROT
    8000 XOR
    -ROT
    D<
;

BASE !
