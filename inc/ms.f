\
\ ms.f
\
\
.( ms )

BASE @ \ save base status


( ms delay )
\ at 3.5MHz n ms delay
CODE (ms) ( n -- )       \ 0 <= n <= 255
    HEX
    D1 C,       \   POP  DE|           \   10 T
    50 C,       \   LD   D'|  B|       \    4 T
    26 C, CD C, \   LDN  H'|  205  N,  \    7 T
                \   HERE    \ BEGIN,   \
    44 C,       \     LD   B'|  H|     \    4 T
    00 C,       \     HERE  NOP        \    4 T
    10 C, FD C, \     DJNZ  BACK,      \ 13/8 T : 3480 T =(4+13)*204 + 12
    1D C,       \     DEC   E'|        \    4 T
    20 C, F9 C, \   JRF  NZ'| BACK,    \ 12/7 T : 3500 T  ( -5 T on exit)
    42 C,       \   LD   B'|  D|       \    4 T
    DD C, E9 C, \   JP(IX)
    SMUDGE

: ms
    7 REG@ 
    0 7 REG!
    SWAP (ms)
    7 REG!
;

\ : ms
\     1 7 REG@ 3 AND LSHIFT
\     0 DO
\         DUP (ms)
\     LOOP
\     DROP
\ ;

BASE !
