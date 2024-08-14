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
NEEDS NARROWCHAR
NEEDS PAUSEOFF

: LAYER2
    $0200 IDE_MODE!
    NARROWCHAR
    PAUSEOFF
;

BASE !
