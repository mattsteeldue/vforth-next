\
\ 2over.f
\
.( 2OVER )

NEEDS CODE      \ just to be sure we are fine

BASE @

HEX

CODE 2OVER  ( d1 d2 -- d1 d2 d1 )
      ( n1 n2 n3 n4 -- n1 n2 n3 n4 n1 n2 )
    21  C,  0007  ,      \  ld      hl, 7
    39  C,               \  add     hl, sp
    56  C,               \  ld      d, (hl)
    2B  C,               \  dec     hl
    5E  C,               \  ld      e, (hl)             // d1-L
    D5  C,               \  push    de
    2B  C,               \  dec     hl
    56  C,               \  ld      d, (hl)
    2B  C,               \  dec     hl
    5E  C,               \  ld      e, (hl)             // d1-H
    D5  C,               \  push    de
    DD  C,  E9  C,       \  jp (ix)

    FORTH
    SMUDGE

BASE !

