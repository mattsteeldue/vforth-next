\
\ rshift.f
\

.( RSHIFT )

NEEDS CODE      \ just to be sure we are fine

BASE @ \ save base status

\ bit left shift of u bits

CODE rshift ( n1 u -- n2 )

    HEX

    D9 C,           \ EXX             
    C1 C,           \ POP     BC|     
    41 C,           \ LD      B'|    C| 
    D1 C,           \ POP     DE|     
    ED C, 2A C,     \ BSLADE,B        
    D5 C,           \ PUSH    DE|     
    D9 C,           \ EXX             
    DD C, E9 C,     \ Next

    FORTH
    SMUDGE

BASE !
