\
\ 2variable.f
\
.( 2VARIABLE included ) 6 EMIT
\
\ 2variable ( d -- )  compile time (initial value)
\           ( -- a )  run-time
: 2VARIABLE 
    VARIABLE ,
;
\
