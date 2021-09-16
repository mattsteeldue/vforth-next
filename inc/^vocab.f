\
\ .vocab.f
\
.( ?VOCAB )
\

: .VOCAB    ( voc-link -- ) 
    BASE @ SWAP HEX
    DUP U. 
    CELL- CELL-
    NFA ID.
    BASE !
;


: ?VOCAB
    CR ." Current  "  CURRENT  @  .VOCAB
    CR ." Context  "  CONTEXT  @  .VOCAB
    CR ." Voc-Link "  VOC-LINK @
    BEGIN
        DUP CELL- .VOCAB SPACE
        @ ?DUP 0=
    UNTIL
;

    
