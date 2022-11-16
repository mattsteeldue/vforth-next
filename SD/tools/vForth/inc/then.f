\
\ then.f
\
.( THEN )
\
\
: THEN ( a 2 -- ) \ compile-time 
       (     -- ) \ run-time
    ?COMP
    2 ?PAIRS  
    HERE OVER - SWAP ! 
    ; 
    IMMEDIATE


