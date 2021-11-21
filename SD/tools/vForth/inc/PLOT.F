\
\ plot.f

\ Layer2 PLOT.f
\
needs FLIP

BASE @ HEX \ save base status

\ find "Layer 2" 16K Base-Page
12 reg@ 2* CONSTANT Layer2-Base-Page

: pixeladd ( x y -- a )  \ x: vertical  y:horizontal
  over 0FF and 5 rshift  \ divide x by 32
  Layer2-Base-Page 
  + mmu7!                \ fit correct 8K page
  swap 1F and            \ x mod 32
  \ 8 lshift +             \ turn it high byte part
  FLIP +
  E000 or
;

: PLOT  ( x y c -- )     \ x: vertical  y:horizontal
  -rot over 8 lshift over +
  C000 U< if pixeladd c! else drop then
;
decimal

BASE !
