\
\ WIPE.f
\
.( WIPE )

NEEDS EDITOR

BASE @ DECIMAL

\
\ Set content of current Screen to blanks
\
: WIPE ( -- )
    16 0 DO
        I EDITOR E 
    LOOP
;

BASE !
