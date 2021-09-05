\
\ postpone.f
\
.( POSTPONE included ) 6 EMIT
\
: POSTPONE ( -- cccc )
    ?COMP
    -FIND
    0= 0 ?ERROR
    192 < IF 
        COMPILE COMPILE 
    THEN
    COMPILE, 
; IMMEDIATE    

