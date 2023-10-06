\
\ .border.f
\
.( .BORDER )
\

BASE @ \ save base status

\
HEX
CODE .BORDER  ( b -- )
    E1  C,          \ pop hl
    26  C,  07 C,   \ ld  h, 7
    7D  C,          \ ld  a, l
    A4  C,          \ and h
    D3  C,  FE C,   \ out ($FE), a
    07  C,          \ rlca
    07  C,          \ rlca
    07  C,          \ rlca
    AD  C,          \ xor l
    AC  C,          \ xor h
    32  C, 5C48 ,   \ ld ($5C48), a
    DD  C,  E9 C,   \ jp (hl)
    SMUDGE

BASE !
