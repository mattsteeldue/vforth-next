\
\ align.f
\
.( ALIGN )
\
\ force HERE to an even address.
: ALIGN ( -- )
    HERE 1 AND ALLOT
;
