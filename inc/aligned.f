\
\ aligned.f
\
.( ALIGNED included ) 6 EMIT
\
\ force to an even address.
: ALIGNED ( a1 -- a2 )
    DUP 1 AND +
;


