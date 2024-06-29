\
\ MMU1.f
\
.( MMU1 )
\

BASE @

.( MMU1! )

\ set MMU1 8K-RAM page to n given between 0 and 223

CODE mmu1! ( n -- )

    HEX 

        HEX 

        E1 C,               \   pop     hl
        7D C,               \   ld      a, l
        ED C, 92 C, 51 C,   \   nextreg 81,a
        DD C, E9 C,         \   jpix  

    FORTH
    SMUDGE

BASE !
