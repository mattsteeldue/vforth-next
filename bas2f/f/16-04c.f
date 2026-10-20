\ 16-04c.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/16-04.txt
\ guide: doc/basic-to-vforth/16-graphics.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 GO SUB 100
\   20 PAUSE 0
\   30 GO SUB 100
\   40 STOP
\   100 PLOT OVER 1;0,0: DRAW OVER 1;255,0: DRAW OVER 1;0,175
\   110 DRAW OVER 1;-255,0: DRAW OVER 1;0,-174
\   120 RETURN

\ --- the translation

\ 16-graphics.md:413
: CLIP-L2  ( row1 col1 row2 col2 -- )
    ROT SWAP                    \ row1 row2 col1 col2
    1 $1C REG!                  \ start again from the first one
    SWAP $18 REG!  $18 REG!     \ columns: left, right
    SWAP $18 REG!  $18 REG! ;   \ rows: top, bottom
0 0 191 255 CLIP-L2
