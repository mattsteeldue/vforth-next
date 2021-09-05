\
\ unused.f
\
.( UNUSED included ) 6 EMIT
\
\ unused
: UNUSED ( -- n ) \ return free dictionary space
    SP@ PAD - 
;
\
