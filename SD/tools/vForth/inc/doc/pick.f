\
\ pick.f
\

.( PICK )

NEEDS CODE      \ just to be sure we are fine

BASE @ \ save base status

HEX

\ Duplicate the nth item on the stack to the top of the stack.
\ Zero based, that is the top item on the stack is the zeroth item,
\ the one below that is the first item and so on. (O PICK has the
\ same effect as DUP, 1 PICK the same as OVER).

CODE pick ( n -- v )
    E1  C,          \   pop     hl          // number of cells 
    29  C,          \   add     hl, hl          
    39  C,          \   add     hl, sp      // address of v
    7E  C,          \   ld      a, (hl)      
    23  C,          \   inc     hl
    66  C,          \   ld      h, (hl)    
    6F  C,          \   ld      l, a
    E5 C,           \   push    hl
    DD C, E9 C,     \   jp      (ix)

    FORTH
    SMUDGE

BASE !
