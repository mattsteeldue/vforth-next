\
\ endif.f
\
.( ENDIF )
\
NEEDS THEN
\
: ENDIF ( a 2 -- ) \ compile-time 
       (     -- )  \ run-time
    [COMPILE] THEN 
    ; 
    IMMEDIATE
