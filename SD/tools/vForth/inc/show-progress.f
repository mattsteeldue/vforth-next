\
\ show-progress.f
\
( SHOW-PROGRESS )
\
\ Used inside a counted loop to show a simple progressing animation
\ If current device is kept in variabile DEVICE (e.g. printer or screen)
\ it will be restored before exit.
\ Current count-index must be passed.

: SHOW-PROGRESS ( n -- )
    6 AND                   \ span chars 41, 43, 45, 47 i.e  ")+-/"
    2 SELECT                \ progress is shown on screen only
    [CHAR] ) + EMIT 
    8 EMIT                  \ backspace
    DEVICE @ SELECT
;
