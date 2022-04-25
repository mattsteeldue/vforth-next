\
\ .at.f
\
.( .AT )
\
\ set current screen print position at row n1 column n2.
\

BASE @ \ save base status

DECIMAL
: .AT ( n1 n2 -- )
    22 EMITC
    SWAP EMITC EMITC 
;

BASE !
