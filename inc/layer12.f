\
\ layer12.f
\
\ Hi-Res
\
.( LAYER12 ) 
\
\ Layer 1,2 – Timex HiRes (Enhanced ULA) mode, 512 w x 192 h pixels,
\ 256 colours total, only 2 colours on screen
\
NEEDS IDE_MODE!

: LAYER12
    [ HEX ] 0102 IDE_MODE!
    1E EMITC 8 EMITC
;

DECIMAL
