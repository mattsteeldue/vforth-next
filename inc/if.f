\
\ if.f
\
.( IF )
\
( IF ... THEN )
( IF ... ELSE ... THEN )
: IF    (   -- a 2 ) \ compile-time
        ( f --     ) \ run-time   
    COMPILE 0BRANCH
    HERE 0 , 
    2 
    ; 
    IMMEDIATE

