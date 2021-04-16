\
\ D.f
\
.( D ) 
\
\ Quick reference
\ [ TIB ]  <->  [ PAD ]  <->   [BLOCK]
\          TEXT        H  E  RE
\                      D  S  INS
\
NEEDS H
NEEDS LINE
NEEDS -MOVE
NEEDS E
\
\
: D ( n -- )        \ remove line n from current screen
    DUP H 
    L/SCR 1- DUP ROT 
    ?DO 
        I 1+ LINE 
        I -MOVE 
    LOOP 
    E 
;
