\
\ J.f
\
.( J included ) 6 EMIT
\
\ Used inside a DO-LOOP gives the index of the first outer loop 
\
: J ( -- n )
    RP@ [ 6 ] LITERAL + @ 
;
