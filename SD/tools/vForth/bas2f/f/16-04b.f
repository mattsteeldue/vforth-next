\ 16-04b.f -- the Forth side of a NextBASIC listing
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

\ --- the translation

\ 16-graphics.md:397
\ no-test in the guide: it waits for keys, never ends or
\ needs hardware the emulator lacks
: FILL-RECT  ( row1 col1 row2 col2 -- )
    ROT 2SWAP 1+ SWAP           \ col2 col1 row2+1 row1
    ?DO  I 2 PICK  I 3 PICK  DRAW-LINE  LOOP
    2DROP ;
LAYER2  28 TO ATTRIB  120 100 130 140 FILL-RECT
