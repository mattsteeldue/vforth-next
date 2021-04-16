\
\ -move.f
\
NEEDS LINE
\
\
.( -MOVE ) 
\
\ move from a to current screen line n
\
\ -MOVE
: -MOVE ( a -- n )  
    LINE C/L CMOVE 
    UPDATE 
;
\
