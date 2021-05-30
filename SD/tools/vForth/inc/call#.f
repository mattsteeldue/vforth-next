\
\ call#.f
\
.( call# )
\
\ call utility. must save BC and IX
\
.( Call utility. )        CR
\ CALL# ( n1 a -- n2 )
\ First argument n1 is passed via bc register AND a register
\ Routine can return bc register which is pushed on TOS
\
HEX
CODE  CALL#  ( n1 -- n2 )
    E1 C, D1 C,             \ pop hl    pop de
    C5 C, DD C, E5 C,       \ push bc   push ix
    4B C, 42 C, 7B C,       \ ld a,e    ld bc,de
    CD C,  (NEXT) 0A + ,    \ call hl
    69 C, 60 C,             \ ld hl,bc
    DD C, E1 C, C1 C,       \ pop ix    pop bc
    E5 C,                   \ push hl
    DD C, E9 C,             \ jp ix
    SMUDGE
\
DECIMAL
\
