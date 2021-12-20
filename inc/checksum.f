\
\ checksum
\
.( CHECKSUM )
\

BASE @

( Checksum of a RAM chunk )
\ calculate the checksum of addresses between a and a+n inclusive.
\ Checksum algoritm is XOR-ing each byte and rotating

CODE CHECKSUM ( a n -- n2 )

        HEX 

        D9 C,       \   exx
        C1 C,       \   pop    bc
        E1 C,       \   pop    hl
        AF C,       \   xora   a
    HERE
        86 C,       \   add    (hl)
        ED C, A1 C, \   cpi
        EA C, ,     \   jp     pe, AAAA
        4F C,       \   ld     c, a
        C5 C,       \   push   bc
        D9 C,       \   exx
        DD C, E9 C, \   jpix  
        
        SMUDGE 

BASE !
