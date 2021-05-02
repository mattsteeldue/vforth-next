\
\ to.f
\
.( TO )
\
: TO ( n -- cccc )
    ' >BODY
    STATE @
    IF
        COMPILE LIT 
        , 
        COMPILE !
    ELSE
        ! 
    ENDIF
;
IMMEDIATE

