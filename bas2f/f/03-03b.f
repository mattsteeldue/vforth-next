\ 03-03b.f -- the Forth side of a NextBASIC listing
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

\ 03-looping.md:228
: ROW  ( r -- )
    5 1 DO  DUP I * 3 .R  LOOP
    DROP CR ;
: TABLE  ( -- )
    4 1 DO  I ROW  LOOP ;
2 ROW                   \ => 2 4 6 8
