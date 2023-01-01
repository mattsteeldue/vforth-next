\
\ -move.f
\
\ move from a to current screen line n
\
.( -MOVE )
\
NEEDS LINE      ( n -- a )   \ address of current screen line n
\
: -MOVE ( a n -- )  
    LINE C/L CMOVE 
    UPDATE 
;
\
