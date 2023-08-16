\
\ ^vocab.f
\
.( ?VOCAB )
\

NEEDS .VOCAB


: ?VOCAB
    CR ." Current  "  CURRENT  @  .VOCAB
    CR ." Context  "  CONTEXT  @  .VOCAB
    CR ." Voc-Link "  VOC-LINK @
    BEGIN
        DUP CELL- .VOCAB SPACE
        @ ?DUP 0=
        ?TERMINAL AND
    UNTIL
;

    
