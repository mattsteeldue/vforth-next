\
\ layer2.f
\
\ Hi-Col Layer2
\
.( LAYER2 )
\
\ Layer 2 – 256 w x 192 h pixels, 256 colours total, one colour per pixel
\

BASE @

NEEDS IDE_MODE!

: LAYER2
    [ HEX ] 0200 IDE_MODE!
    1E EMITC 4 EMITC
    1A EMITC 0 EMITC
;

BASE !
