\
\ layer0.f
\
\ ULA legacy
\
.( LAYER0 )
\
\ Layer 0 � Standard Spectrum (ULA) mode, 256 w x 192 h pixels, 8 colours
\ total (2 intensities), 32 x 24 cells, each capable of displaying 2 colours
\
NEEDS IDE_MODE!

BASE @

: LAYER0
    $0000 IDE_MODE!
    -1 $5C8C C!
;

BASE !
