\
\ DEPTH.f
\
.( DEPTH included ) 6 EMIT
\
\ return the current calculator stack depth
\
: DEPTH ( -- n )      
    S0 @ SP@ - 2/ 1 - 
;
