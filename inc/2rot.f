\
\ 2rot.f
\

.( 2ROT )

NEEDS CODE      \ just to be sure we are fine

BASE @ \ save base status

HEX 

CODE 2ROT   ( d1 d2 d3 -- d2 d3 d1 )
   ( n1 n2 n3 n4 n5 n6 -- n3 n4 n5 n6 n1 n2 )
\ \      d3  |d2  |d1  |
\ \      h l |h l |h l |
\ \ SP   LHED|LHED|LHED|
\ \ SP  +0123|4567|89ab|
\ CODE 2rot  ( d1 d2 d3 -- d2 d3 d1 )
\         
    D9  C,              \  exx
    E1  C,              \  pop     hl  ; d3
    D1  C,              \  pop     de       
    C1  C,              \  pop     bc  ; d2
    F1  C,              \  pop     af
    D9  C,              \  exx
    08  C,              \  ex      af, af'
    E1  C,              \  pop     hl  ; d1
    F1  C,              \  pop     af
    08  C,              \  ex      af, af'
    D9  C,              \  exx
    F5  C,              \  push    af  ; d2
    C5  C,              \  push    bc       
    D5  C,              \  push    de  ; d3
    E5  C,              \  push    hl
    D9  C,              \  exx
    08  C,              \  ex      af, af'
    F5  C,              \  push    af  ; d1
    E5  C,              \  push    hl
    DD  C,  E9   C,     \  jp (ix)
    
    FORTH
    SMUDGE

BASE !
