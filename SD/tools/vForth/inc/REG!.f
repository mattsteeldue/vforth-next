\
\ reg!.f
\
.( REG! )
\

BASE @

\ write value b to Next REGister n 
\ : reg! ( b n -- )
\     [ hex 243B ] literal p!
\     [ hex 253B ] literal p!
\ ;

CODE reg! ( b n -- )

        HEX 

        D9 C,           \   exx
        01 C, 243B ,    \   ld      bc, $243B 
        E1 C,           \   pop    hl
        ED C, 69 C,     \   out    (c), l
        04 C,           \   inc    b
        E1 C,           \   pop    hl
        ED C, 69 C,     \   out    (c), l
        D9 C,           \   exx
        DD C, E9 C, \   jpix  

    FORTH
    SMUDGE

BASE !
