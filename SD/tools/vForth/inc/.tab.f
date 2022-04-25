\
\ .tab.f
\
.( .TAB )
\

BASE @ \ save base status

DECIMAL
: .TAB ( n1 -- )
    23 EMITC
    SPLIT EMITC EMITC
;

BASE !
