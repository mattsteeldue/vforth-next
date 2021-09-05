\
\ line.f
\
\ leave address of current screen line n
\
.( LINE included ) 6 EMIT
\
\ LINE
: LINE ( n -- a )   
    DUP 0 <        3 ?ERROR  \ error 3: No such line.
    DUP L/SCR < 0= 3 ?ERROR 
    SCR @ (LINE) DROP 
;
\
