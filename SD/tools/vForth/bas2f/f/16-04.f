\ 16-04.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/16-graphics-04.txt
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

\ --- words defined earlier in the guide

\ 16-graphics.md:142
\ no-test in the guide: it waits for keys, never ends or
\ needs hardware the emulator lacks
: XLINE  ( row2 col2 row1 col1 -- )
    ['] L0-XOR IS PLOTOP  DRAW-LINE  ['] L0-SET IS PLOTOP ;

\ --- the translation

\ 16-graphics.md:375
\ no-test in the guide: it waits for keys, never ends or
\ needs hardware the emulator lacks
: RIM  ( -- )
    175   0  175 254 XLINE          \ bottom
    175 255    1 255 XLINE          \ right
      0 255    0   1 XLINE          \ top
      0   0  174   0 XLINE ;        \ left
: TRACE  ( -- )  RIM  KEY DROP  RIM ;
