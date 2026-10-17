\ 15-01.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/15-colours-01.txt
\ guide: doc/basic-to-vforth/15-colours.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 FOR c=0 TO 7
\   20   PAPER c: PRINT "    "
\   30 NEXT c
\   40 PAPER 7

\ --- the translation

\ 15-colours.md:190
\ no-test in the guide: it waits for keys, never ends or
\ needs hardware the emulator lacks
: COLUMN  ( -- )
    8 0 DO  I .PAPER  ."     "  7 .PAPER CR  LOOP ;
