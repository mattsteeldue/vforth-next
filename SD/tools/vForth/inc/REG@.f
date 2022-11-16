\
\ reg@.f
\
.( REG@ )
\

BASE @

\ reads Next REGister n giving byte b
\ : reg@ ( n -- b )
\     [ hex 243B ] literal p!
\     [ hex 253B ] literal p@
\ ;

CODE REG@ ( n -- b )

    HEX 

    D9 C,               \   exx
    01 C, 243B ,        \   ld      bc, $243B 
    E1 C,               \   pop    hl
    ED C, 69 C,         \   out    (c), l
    04 C,               \   inc    b
    ED C, 68 C,         \   IN     (c), l
    E5 C,               \   push   HL
    D9 C,               \   exx
    DD C, E9 C,         \   jpix  

    FORTH
    SMUDGE

BASE !
