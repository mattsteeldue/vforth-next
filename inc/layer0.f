\
\ layer0.f
\
.( LAYER0 )
\
\ Layer 0 – Standard Spectrum (ULA) mode, 256 w x 192 h pixels, 8 colours
\ total (2 intensities), 32 x 24 cells, each capable of displaying 2 colours
\
NEEDS IDE_MODE!

: LAYER0
    [ HEX ] 0000 IDE_MODE!
;

DECIMAL
