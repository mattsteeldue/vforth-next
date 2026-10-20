\ 01-03.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/01-03.txt
\ guide: doc/basic-to-vforth/01-basic-programming-concepts.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 LET total=0
\   20 INPUT item
\   30 total+=item
\   40 PRINT total
\   50 GO TO 20

\ --- the translation

\ 01-basic-programming-concepts.md:379
VARIABLE TOTAL
: ADD  ( n -- )  TOTAL +!  TOTAL ? ;
5 ADD                           \ => 5
7 ADD                           \ => 12
0 TOTAL !
