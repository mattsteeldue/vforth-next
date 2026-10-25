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
    BEGIN                       \ walk every vocabulary, newest first
        DUP CELL- .VOCAB SPACE
        @ DUP 0=                \ FORTH ends the chain with 0
        ?TERMINAL OR
    UNTIL
    DROP
;

    
