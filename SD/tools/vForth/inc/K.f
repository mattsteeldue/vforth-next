\
\ K.f
\
.( K included ) 6 EMIT
\
\ Used inside a DO-LOOP gives the index of the second outer loop 
\
: K ( -- n )
    RP@ [ 10 ] LITERAL + @ 
;
