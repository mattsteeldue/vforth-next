\ 13-03.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/13-03.txt
\ guide: doc/basic-to-vforth/13-the-character-set.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   5 CLEAR 49999
\   10 LET a=50000
\   20 FOR n=0 TO 767
\   30 v=PEEK (15616+n)
\   40 POKE a+n, v|INT (v>>1)
\   50 NEXT n
\   60 DPOKE 23606,a-256
\   70 LIST

\ --- the translation

\ 13-the-character-set.md:314
\ no-test in the guide: it waits for keys, never ends or
\ needs hardware the emulator lacks
CREATE FONT  768 ALLOT
: BOLD  ( -- )
    768 0 DO  15616 I + C@  DUP 1 RSHIFT OR  FONT I + C!  LOOP ;
BOLD  FONT 256 - 23606 !
WORDS
