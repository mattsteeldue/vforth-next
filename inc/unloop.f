\
\ unloop.f
\
.( UNLOOP )
\
\ Discards DO-LOOP limit and index from Return Stack
\
: UNLOOP ( -- )
    R>
    R> R> 2DROP
    >R
;
