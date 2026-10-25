\ 10-01.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/10-01.txt
\ guide: doc/basic-to-vforth/10-random-numbers.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 FOR n=1 TO 2
\   20   PRINT 1+RND (20);" ";
\   30 NEXT n

\ --- the translation

\ 10-random-numbers.md:173
: D20  ( -- n )  20 RND 1+ ;
: THROW  ( -- )  D20 .  D20 . ;
1 RANDOMIZE
THROW                           \ => 1 4
THROW                           \ => 18 12
