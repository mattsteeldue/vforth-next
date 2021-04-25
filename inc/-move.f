\
\ -move.f
\
\ move from a to current screen line n
\
.( -MOVE ) 
\
NEEDS LINE
\
\ -MOVE
: -MOVE ( a -- n )  
    LINE C/L CMOVE 
    UPDATE 
;
\
