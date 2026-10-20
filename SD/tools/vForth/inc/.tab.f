\
\ .tab.f
\
.( .TAB )
\

BASE @ \ save base status

NEEDS SPLIT

DECIMAL
\ move the print position to column n1 (code 23 = TAB): the ROM wants
\ the low byte first, then the high byte
: .TAB ( n1 -- )
    23 EMITC
    SPLIT SWAP EMITC EMITC
;

BASE !
