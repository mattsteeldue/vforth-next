\
\ WIPE.f
\
.( WIPE included ) 6 EMIT
\
\ Set content of current Screen to blanks
\
: WIPE ( -- )
    16 0 DO
        I E
    LOOP
;
