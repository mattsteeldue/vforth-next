\
\ align.f
\
.( ALIGN included ) 6 EMIT
\
\ force HERE to an even address.
: ALIGN ( -- )
    HERE 1 AND ALLOT
;
