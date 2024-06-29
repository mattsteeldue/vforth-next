\
\ MMU0.f
\
.( MMU0 )
\

BASE @

.( MMU0! )

\ set MMU0 8K-RAM page to n given between 0 and 223

CODE mmu0! ( n -- )

    HEX 

        HEX 

        E1 C,               \   pop     hl
        7D C,               \   ld      a, l
        ED C, 92 C, 50 C,   \   nextreg 80,a
        DD C, E9 C,         \   jpix  

    FORTH
    SMUDGE

BASE !
