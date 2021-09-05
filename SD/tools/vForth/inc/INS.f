\
\ INS.f
\
.( INS included ) 6 EMIT
\
\ Quick reference
\ [ TIB ]  <->  [ PAD ]  <->   [BLOCK]
\          TEXT        H  E  RE
\                      D  S  INS
\
NEEDS RE
NEEDS S
\
\
: INS ( n -- )      \ insert line n from PAD
    DUP S RE 
;
