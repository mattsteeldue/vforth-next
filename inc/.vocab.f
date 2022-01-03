\
\ .vocab.f
\
.( .VOCAB )
\

: .VOCAB    ( voc-link -- ) 
    BASE @ SWAP HEX
    DUP U. 
    CELL- CELL-
    NFA ID.
    BASE !
;

