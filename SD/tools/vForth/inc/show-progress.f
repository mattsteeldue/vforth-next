\
\ show-progress.f
\
.( SHOW-PROGRESS )
\
\ Used inside a counted loop to show a simple progressing animation
\ The current count-index must be passed.
\
: SHOW-PROGRESS ( n -- )
    3 AND 2*                \ span chars 41, 43, 45, 47
    41 + EMIT 
    8 EMIT                  \ backspace
;
