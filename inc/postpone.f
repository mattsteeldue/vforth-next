\
\ postpone.f
\
.( POSTPONE )
\
: POSTPONE ( -- cccc )
    ?COMP
    -FIND
    0= 0 ?ERROR
    192 < IF 
        COMPILE COMPILE 
    THEN
    ' , 
; IMMEDIATE    

