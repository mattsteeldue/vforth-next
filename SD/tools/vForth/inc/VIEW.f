\
\ view.f

.( VIEW )

\ Typical usage 
\
\   VIEW filename
\
BASE @
DECIMAL

: VIEW ( -- cccc )
    NOOP
;


NEEDS VIEW-FILE-PAD

: VIEW-CCCC ( -- )
    [COMPILE] PAD"
    VIEW-FILE-PAD
;


' VIEW-CCCC ' VIEW >BODY !


BASE !

