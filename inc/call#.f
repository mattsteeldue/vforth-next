\
\ call#.f
\
.( CALL# )
\
\ call utility. must save BC and IX

BASE @ \ save base status

\
\ CALL# ( n1 a -- n2 )
\ First argument n1 is passed via bc register AND a register
\ Routine can return bc register which is pushed on TOS
\
HEX
CODE  CALL#  ( n1 a -- n2 )
    D9 C,                   \  exx
    E1 C,                   \  pop hl    ; address
    C1 C,                   \  pop bc    ; argument
    79 C,                   \  ld  a, c
    D9 C,                   \ exx
    DD C, E5 C,             \ push ix
    D5 C,                   \ push de 
    C5 C,                   \ push bc 
    D9 C,                   \  exx
    CD C,  HERE 0B + ,      \  call hl --> jp(hl) ! not jp(ix) !
    D9 C,                   \  exx
    C1 C,                   \ pop bc    
    D1 C,                   \ pop de
    DD C, E1 C,             \ pop ix    
    D9 C,                   \  exx
    C5 C,                   \  push bc
    D9 C,                   \ exx
    DD C, E9 C,             \ jp ix

    FORTH
    SMUDGE
\
BASE !
\
