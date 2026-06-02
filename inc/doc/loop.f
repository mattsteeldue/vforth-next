\
\ loop.f
\
.( LOOP )
\
NEEDS DO
NEEDS ?DO
NEEDS ?DO-
\
: LOOP      ( a 3 -- ) \ compile-time
            (     -- ) \ run-time
    3 ?PAIRS 
    COMPILE (LOOP) 
    ?DO- \ BACK
    ; 
    IMMEDIATE

