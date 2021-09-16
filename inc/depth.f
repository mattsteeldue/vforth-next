\
\ DEPTH.f
\
.( DEPTH )
\
\ return the current calculator stack depth
\
: DEPTH ( -- n )      
    S0 @ SP@ - 2/ 1 - 
;
