\
\ do.f
\
.( DO )
\

NEEDS LOOP
NEEDS +LOOP

( DO  ... LOOP )
( DO  ... n +LOOP )
( ?DO ... LOOP )
( ?DO ... n +LOOP )
: DO        ( -- a 3 ) \ compile-time
            ( n m --     ) \ run-time
    COMPILE (DO)
    CSP @ !CSP
    HERE 3 
    ; 
    IMMEDIATE

