\
\ again.f
\
.( AGAIN )
\
NEEDS BACK
\
: AGAIN     ( a 1 -- ) \ compile-time 
            (     -- ) \ run-time
    ?COMP
    2 ?PAIRS 
    COMPILE BRANCH
    BACK 
    ; 
    IMMEDIATE


