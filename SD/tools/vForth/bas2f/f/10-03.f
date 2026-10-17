\ 10-03.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/10-random-numbers-03.txt
\ guide: doc/basic-to-vforth/10-random-numbers.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 LET h=0
\   20 FOR n=1 TO 100
\   30   LET h=h+RND (2)
\   40 NEXT n
\   50 PRINT h

\ --- the translation

\ 10-random-numbers.md:165
: HEADS  ( tosses -- heads )  0 SWAP 0 ?DO  2 RND +  LOOP ;
1 RANDOMIZE
100 HEADS .                     \ => 45
1000 HEADS .                    \ => 531
