\
\ 2rot.f
\

NEEDS CODE

CODE 2ROT

\      d3  |d2  |d1  |
\      h l |h l |h l |
\ SP   LHED|LHED|LHED|
\ SP  +0123|4567|89ab|

    21  C,  000B  ,      \  ld      hl, $000B
    39  C,               \  add     hl, sp   
    56  C,               \  ld      d, (hl)  
    2B  C,               \  dec     hl       
    5E  C,               \  ld      e, (hl)  
    2B  C,               \  dec     hl       
    D5  C,               \  push    de       
    56  C,               \  ld      d, (hl)  
    2B  C,               \  dec     hl       
    5E  C,               \  ld      e, (hl)  
    2B  C,               \  dec     hl       
    D5  C,               \  push    de       

\      d1  |d3  |d2  |d1  |
\      h l |h l |h l |h l |
\ SP   LHED|LHED|LHED|LHED|
\ SP       +0123|4567|89ab|

    54  C,               \  ld      d, h     
    5D  C,               \  ld      e, l     
    13  C,               \  inc     de       
    13  C,               \  inc     de       
    13  C,               \  inc     de       
    13  C,               \  inc     de       
    C5  C,               \  push    bc       
    01  C,  000C  ,      \  ld      bc, $000C
    ED  C,  B8   C,      \  lddr             
    C1  C,               \  pop     bc       
    D1  C,               \  pop     de       
    D1  C,               \  pop     de       
    DD  C,  E9           \  jp (ix)
    
    SMUDGE

