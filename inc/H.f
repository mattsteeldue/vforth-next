\
\ H.f
\
.( H ) 
\
\ Quick reference
\ [ TIB ]  <->  [ PAD ]  <->   [BLOCK]
\          TEXT        H  E  RE
\                      D  S  INS
\
NEEDS LINE
\
: H ( n -- )        \ hold line n to PAD
    LINE 
    PAD 1+ 
    C/L 
    DUP PAD C! 
    CMOVE 
;
