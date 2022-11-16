\
\ reg!.f
\
.( REG! )
\

BASE @

\ set MMU7 8K-RAM page to n given between 0 and 223
\ optimized version that uses NEXTREG n,A Z80n op-code.

CODE MMU7! ( n -- )

        HEX 

        E1 C,               \   pop     hl
        7D C,               \   ld      a, l
        ED C, 92 C, 57 C,   \   nextreg 87,a
        DD C, E9 C,         \   jpix  

    FORTH
    SMUDGE

BASE !
