\
\ 2constant.f
\
.( 2CONSTANT included ) 6 EMIT
\
\ 2constant ( d -- )  compile time
\           ( -- d )  run-time
: 2CONSTANT 
    <BUILDS , , DOES>
    2@
;
\
