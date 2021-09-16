\
\ layer11.f
\
\ ULA
\
.( LAYER11 )
\
\ Layer 1,1 – Standard Res (Enhanced ULA) mode, 256 w x 192 h pixels,
\ 256 colours total, 32 x 24 cells, each capable of displaying 2 colours
\
NEEDS IDE_MODE!

: LAYER11
    [ HEX ] 0101 IDE_MODE!
    1E EMITC 4 EMITC
;

DECIMAL
