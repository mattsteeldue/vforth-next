\
\ -move.f
\
\ move from a to current screen line n
\
.( -MOVE included ) 6 EMIT
\
NEEDS LINE
\
\ -MOVE
: -MOVE ( a -- n )  
    LINE C/L CMOVE 
    UPDATE 
;
\
