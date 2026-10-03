\
\ .vocab.f
\
.( .VOCAB )
\

: .VOCAB    ( voc-link -- ) 
    BASE @ SWAP HEX
    DUP U. 
    CELL-                   \ vocabulary's pfa
    NFA ID.
    BASE !
;

