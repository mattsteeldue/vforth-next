\
\ inc/move.f
\
\
.( MOVE )
\
BASE @ \ save base status

\ exchange hi and lo byte of n1
\ 
: MOVE ( a1 a2 u -- )
    >R
    2DUP < IF
        R> CMOVE>
    ELSE
        R> CMOVE
    THEN
;
            
BASE !
