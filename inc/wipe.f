\
\ WIPE.f
\
.( WIPE )
\
\ Set content of current Screen to blanks
\
: WIPE ( -- )
    16 0 DO
        I E
    LOOP
;
