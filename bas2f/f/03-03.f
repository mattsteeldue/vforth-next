\ 03-03.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/03-03.txt
\ guide: doc/basic-to-vforth/03-looping.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 FOR r=1 TO 3
\   20   FOR c=1 TO 4
\   30     PRINT r*c;" ";
\   40   NEXT c
\   50   PRINT
\   60 NEXT r

\ --- the translation

\ 03-looping.md:209
NEEDS J
: TABLE  ( -- )
    4 1 DO
        5 1 DO  J I * 3 .R  LOOP
        CR
    LOOP ;
TABLE
\ output of the last line:
\   1  2  3  4
\   2  4  6  8
\   3  6  9 12
