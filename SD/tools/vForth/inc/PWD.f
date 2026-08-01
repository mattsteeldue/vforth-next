\
\ pwd.f
\
.( PWD )
\
\ Print current directory
\

NEEDS IDE_PATH

: PWD ( -- )
    \ put to PAD just a dot "." followed by an $FF.
    [ CHAR . $FF00 + ] LITERAL PAD !
    PAD 1 IDE_PATH
    #44 ?ERROR              \ NextZXOS DOS call error
    PAD
    BEGIN
        DUP C@
        DUP $FF -
    WHILE
        EMIT
        1+
    REPEAT
    DROP
;
