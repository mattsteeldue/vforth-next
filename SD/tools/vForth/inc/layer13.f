\
\ layer13.f
\
\ Hi-Col
\
.( LAYER13 )
\
\ Layer 1,3 – Timex HiColour (Enhanced ULA) mode, 256 w x 192 h pixels,
\ 256 colours total, 32 x 192 cells, each capable of displaying 2 colours
\ 
NEEDS IDE_MODE!
NEEDS NARROWCHAR
NEEDS PAUSEOFF

BASE @

: LAYER13
    $0103 IDE_MODE!
    NARROWCHAR
    PAUSEOFF
;

BASE !
