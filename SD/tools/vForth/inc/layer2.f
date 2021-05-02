\
\ layer2.f
\
\ Hi-Col Layer2
\
.( LAYER2 ) 
\
NEEDS IDE_MODE!

: LAYER2
    [ HEX ] 0200 IDE_MODE!
    1E EMITC 4 EMITC
;

DECIMAL
