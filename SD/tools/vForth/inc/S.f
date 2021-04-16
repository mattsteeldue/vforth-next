\
\ S.f
\
.( S ) 
\
\ Quick reference
\ [ TIB ]  <->  [ PAD ]  <->   [BLOCK]
\          TEXT        H  E  RE
\                      D  S  INS
\
NEEDS LINE
NEEDS -MOVE
NEEDS E
\
\
: S ( n -- )        \ shift lines >= n down by one
    DUP  L/SCR 1- 
    DO  
        I 1- LINE  
        I -MOVE  
    -1 +LOOP 
    E 
;
