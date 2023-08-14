\ &&.f
\
.( ** )
\


BASE @
HEX
\
: ** ( n u -- n1 )
    1 SWAP          \  n 1 u
    0 ?DO           \  n 1
        OVER *      \  n n1
    LOOP            \  n n1
    NIP             \  n1
;

BASE !
