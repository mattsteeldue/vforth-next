\
\ RE.f
\
.( RE ) 
\
\ Quick reference
\ [ TIB ]  <->  [ PAD ]  <->   [BLOCK]
\          TEXT        H  E  RE
\                      D  S  INS
\
NEEDS -MOVE
\
\
: RE ( n -- )       \ replace line n using PAD content
    PAD 1+ SWAP 
    -MOVE 
;
