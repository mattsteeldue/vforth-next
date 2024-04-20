\
\ postpone.f
\
.( POSTPONE )
\
: POSTPONE ( -- cccc )
    ?COMP
    -FIND
    0= 0 ?ERROR
    $C0 < IF 
        COMPILE COMPILE 
    THEN
    COMPILE, 
; IMMEDIATE    

