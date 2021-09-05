\
\ recurse.f
\
.( RECURSE included ) 6 EMIT
\
\ recurse ( -- )  compile time 
: RECURSE ( -- )
    ?COMP
    LATEST PFA CFA , 
;
IMMEDIATE
\
