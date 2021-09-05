\
\ layer2.f
\
\ Hi-Col Layer2
\
.( LAYER2 included ) 6 EMIT
\
\ Layer 2 – 256 w x 192 h pixels, 256 colours total, one colour per pixel
\
NEEDS IDE_MODE!

: LAYER2
    [ HEX ] 0200 IDE_MODE!
    1E EMITC 4 EMITC
;

DECIMAL
