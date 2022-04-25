\
\ split.f
\
\
.( SPLIT )
\
BASE @ \ save base status

\ Split two bytes of n1 into two separate numbers, 
\ n2 low byte, n3 high byte.
\ 
CODE SPLIT ( n1 -- n2 n3 ) 
    HEX
    D1 C,       \   pop  de
    AF C,       \   xor  a
    6A C,       \   ld   l,d
    57 C,       \   ld   d,a
    67 C,       \   ld   h,a
    D5 C,       \   push de
    E5 C,       \   push hl
    DD C, E9 C, \   jp   (ix)

    FORTH
    SMUDGE
        
BASE !
