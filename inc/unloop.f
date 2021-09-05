\
\ unloop.f
\
.( UNLOOP included ) 6 EMIT
\
\ Discards DO-LOOP limit and index from Return Stack
\
: UNLOOP ( -- )
    R>
    R> R> 2DROP
    >R
;
