\
\ exec%.f
\
\ Vectorized fast case structure 
\
\ Used in colon definition in the form
\   : MY_ACTION_LIST ( n -- )
\     EXEC: 
\       word0   \ executed when n = 0
\       word1   \ executed when n = 1
\       word2   \ executed when n = 2
\       ... 
\   ;
\
\ to execute the word indexed by n passed.
\ Warning: there is no run-time checking on n.

BASE @

HERE ' EXIT ,       \ Used below for bc

CODE EXEC:  ( n -- )
    HEX
    E1      C,      \   pop     hl
    29      C,      \   add     hl, hl
    09      C,      \   add     hl, bc
    5E      C,      \   ld      e, (hl)
    23      C,      \   inc     hl
    56      C,      \   ld      d, (hl)
    01      C, ,    \   ld      bc, [EXIT]
    EB      C,      \   ex      de, hl
    E9      C,      \   jp      (hl)

SMUDGE

BASE !
