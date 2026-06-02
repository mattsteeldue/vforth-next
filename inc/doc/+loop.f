\
\ loop.f
\
.( LOOP )
\
NEEDS DO
NEEDS ?DO
NEEDS ?DO-
\
: +LOOP     ( A 3 -- ) \ COMPILE-TIME
            (     -- ) \ RUN-TIME
    3 ?PAIRS 
    COMPILE (+LOOP) 
    ?DO- \ BACK
    ; 
    IMMEDIATE

