\
\ else.f
\
.( ELSE )
\
NEEDS THEN
\
: ELSE      ( a 1 -- ) \ compile-time 
            (   f -- ) \ run-time
    ?COMP
    2 ?PAIRS  
    COMPILE BRANCH
    HERE 0 , 
    SWAP 2 [COMPILE] THEN
    2 
    ; 
    IMMEDIATE



