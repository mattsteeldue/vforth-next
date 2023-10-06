\
\ pwd.f
\
.( PWD )
\
\ Print current directory
\

NEEDS IDE_PATH

BASE @

: PWD ( -- )
    \ put to PAD just a dot "." followed by an $FF.
    [ CHAR . $FF00 + ] LITERAL PAD !    
    PAD 1 IDE_PATH
    [ DECIMAL ] 44 ?ERROR
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

BASE !
