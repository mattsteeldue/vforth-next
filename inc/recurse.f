\
\ recurse.f
\
.( RECURSE )
\
\ recurse ( -- )  compile time 
: RECURSE ( -- )
    ?COMP
    LATEST PFA CFA , 
;
IMMEDIATE
\
