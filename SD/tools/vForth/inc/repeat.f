\
\ repeat.f
\
.( REPEAT )
\
NEEDS AGAIN
NEEDS THEN
\
: REPEAT    ( a1 1 a2 4 -- ) \ compile-time
            (           -- ) \ run-time
    [COMPILE] AGAIN
    \ 2-
    [COMPILE] THEN
    ; 
    IMMEDIATE


