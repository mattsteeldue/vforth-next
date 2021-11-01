\
\ flip.f
\
\
.( FLIP )
\
\ exchange hi and lo byte of n1
\ 
CODE FLIP ( n1 -- n2 ) 
    HEX
    E1 C,       \   pop  hl
    7D C,       \   ls   a,l
    6C C,       \   ld   l,h
    67 C,       \   ld   h,a
    E5 C,       \   push hl
    DD C, E9 C, \   jp   (ix)
SMUDGE 
DECIMAL
        
