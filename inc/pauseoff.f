\
\ pauseoff.f
\
\ Layers 1 .. 2
\ set Auto-Pause off
\
.( PAUSEOFF )
\

BASE @

: PAUSEOFF

    CLS
    [   
        \ this is some kind of conditional compile.    
        \ dot-version needs CLS, while the other don't.
        0 +ORIGIN $2000 = NOT 2 AND NEGATE ALLOT
    ]

    $1A EMITC 0 EMITC
;

BASE !
