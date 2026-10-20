\ 19-01.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/19-01.txt
\ guide: doc/basic-to-vforth/19-nextzxos-and-alternatives.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 DIM a(10)
\   20 FOR i=1 TO 10: LET a(i)=i*i: NEXT i
\   30 SAVE "squares.dat" DATA a()
\   40 DIM a(10)
\   50 LOAD "squares.dat" DATA a()
\   60 PRINT a(5)

\ --- the translation

\ 19-nextzxos-and-alternatives.md:209
\ no-test in the guide: it waits for keys, never ends or
\ needs hardware the emulator lacks
NEEDS PAD"  NEEDS SAVE-BYTES  NEEDS LOAD-BYTES
CREATE SQUARES  10 CELLS ALLOT
: SQUARES!  ( -- )
    10 0 DO  I 1+ DUP *  SQUARES I CELLS + !  LOOP ;
SQUARES!
PAD" squares.dat" SQUARES 10 CELLS SAVE-BYTES
SQUARES 10 CELLS ERASE
PAD" squares.dat" SQUARES 10 CELLS LOAD-BYTES
SQUARES 4 CELLS + @ .           \ => 25
