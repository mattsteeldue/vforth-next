\
\ ^do.f
\
.( ?DO )
\

NEEDS LOOP
NEEDS +LOOP

: ?DO       ( -- a 3 ) \ compile-time
            ( n m --     ) \ run-time
    COMPILE (?DO)
    CSP @ !CSP
    HERE 0 , 0
    HERE 3
    ; 
    IMMEDIATE


