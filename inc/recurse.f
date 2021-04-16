\
\ recurse.f
\
.( RECURSE ) CR
\
\ recurse ( -- )  compile time 
: RECURSE ( -- )
    ?COMP
    LATEST PFA CFA , 
;
IMMEDIATE
\
