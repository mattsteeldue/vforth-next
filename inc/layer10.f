\
\ layer10.f
\
\ Lo-Res
\
.( LAYER10 ) 
\
NEEDS IDE_MODE!

: LAYER10
    [ HEX ] 0100 IDE_MODE!
    1E EMITC 4 EMITC
;

DECIMAL
