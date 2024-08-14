\
\ layer10.f
\
\ Lo-Res
\
.( LAYER10 )
\
\ Layer 1,0 – LoRes (Enhanced ULA) mode, 128 w x 96 h pixels, 256 colours
\ total, 1 colour per pixel
\
NEEDS IDE_MODE!
NEEDS NARROWCHAR
NEEDS PAUSEOFF

BASE @

: LAYER10
    $0100 IDE_MODE!
    NARROWCHAR
    PAUSEOFF
;

BASE !
