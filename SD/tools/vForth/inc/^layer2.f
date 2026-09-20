\
\ ^layer2.f
\
\ Hi-Col Layer2 show display
\
.( ?LAYER2 )
\
\
NEEDS LAYERS    \ loads all the layer words, including LAYER2 and LAYER12
NEEDS WAIT-KEY

: ?LAYER2
    LAYER2
    WAIT-KEY
    LAYER12
;
