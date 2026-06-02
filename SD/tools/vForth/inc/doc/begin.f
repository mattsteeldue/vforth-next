\
\ begin.f
\
.( BEGIN )
\
( BEGIN ... AGAIN )
( BEGIN ... f UNTIL )
( BEGIN ... f WHILE ... REPEAT )

: BEGIN     ( -- a 1 ) \ compile-time  
            ( --     ) \ run-time
    ?COMP 
    HERE 
    2
    ; 
    IMMEDIATE

