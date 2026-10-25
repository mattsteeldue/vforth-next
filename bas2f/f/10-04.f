\ 10-04.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/10-04.txt
\ guide: doc/basic-to-vforth/10-random-numbers.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 DIM t(6)
\   20 FOR n=1 TO 600
\   30   LET d=1+RND (6)
\   40   LET t(d)=t(d)+1
\   50 NEXT n
\   60 FOR d=1 TO 6: PRINT t(d);" ";: NEXT d

\ --- the translation

\ 10-random-numbers.md:233
CREATE TALLY  6 CELLS ALLOT
: THROWS  ( n -- )
    TALLY 6 CELLS ERASE
    0 ?DO  1  6 RND CELLS TALLY +  +!  LOOP ;
: .TALLY  ( -- )  6 0 DO  I CELLS TALLY + @ 5 .R  LOOP ;
1 RANDOMIZE
600 THROWS
.TALLY                  \ => 88 94 112 88 114 104
