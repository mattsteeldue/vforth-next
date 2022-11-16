\
\ show-progress.f
\
.( SHOW-PROGRESS )
\
\ Used inside a counted loop to show a simple progressing animation
\ The current count-index must be passed.
\

: SHOW-PROGRESS ( n -- )
    3 AND 2*                \ span chars 41, 43, 45, 47 i.e  ")+-/"
    2 SELECT                \ progress is shown on screen only
    [CHAR] ) + EMIT 
    8 EMIT                  \ backspace
    DEVICE @ SELECT
;
