\
\ until.f
\
.( UNTIL )
\
NEEDS BACK
\
: UNTIL     ( a 1 -- ) \ compile-time 
            (   f -- ) \ run-time
    ?COMP
    2 ?PAIRS
    COMPILE 0BRANCH
    BACK 
    ; 
    IMMEDIATE

