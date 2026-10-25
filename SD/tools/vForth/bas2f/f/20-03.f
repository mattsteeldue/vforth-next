\ 20-03.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/20-03.txt
\ guide: doc/basic-to-vforth/20-channels-streams-drivers-and-windows.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   5 OPEN #3,"s"
\   10 LPRINT "Squares"
\   20 FOR i=1 TO 5: LPRINT i*i;" ";: NEXT i
\   30 LPRINT
\   40 CLOSE #3

\ --- the translation

\ 20-channels-streams-drivers-and-windows.md:317
\ no-test in the guide: it waits for keys, never ends or
\ needs hardware the emulator lacks
: SQUARES  ( -- )
    ." Squares" CR
    6 1 DO  I I * .  LOOP CR ;
3 SELECT SQUARES VIDEO
