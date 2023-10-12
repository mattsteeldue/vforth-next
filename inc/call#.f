\
\ call#.f
\
.( CALL# )
\
\ ROM call utility. must save BC, DE and IX

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

    \ this is some kind of conditional compile.    
    \ we're lucky dot-command ROM call can be done in one single op-code.
    0 +ORIGIN 2000 - NOT 1 AND DF *   \ compile RST $18 if dot-command
    0 +ORIGIN 2000 = NOT 1 AND CD * + \ compile CALL  if not dot-command
       C,  HERE 0B + ,      \  call hl --> jp(hl) ! not jp(ix) !

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
