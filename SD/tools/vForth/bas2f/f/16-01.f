\ 16-01.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/16-graphics-01.txt
\ guide: doc/basic-to-vforth/16-graphics.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 FOR n=0 TO 255
\   20   LET x=(n-128)/50
\   30   IF x<>0 THEN LET y=88+30/x: IF y>=0 AND y<=175 THEN PLOT n,y
\   40 NEXT n

\ --- the translation

\ 16-graphics.md:231
1500 50 / .  1500 -50 / .       \ => 30 -30
