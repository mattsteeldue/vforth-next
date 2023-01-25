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
    E1 C,       \   pop  hl
    7C C,       \   ld   a,h
    26 C, 00 C, \   ld   h,0
    E5 C,       \   push hl
    6F C,       \   ld   l,a
    E5 C,       \   push hl
    DD C, E9 C, \   jp   (ix)

    FORTH
    SMUDGE
        
BASE !
