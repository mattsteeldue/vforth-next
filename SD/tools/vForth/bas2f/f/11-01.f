\ 11-01.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/11-01.txt
\ guide: doc/basic-to-vforth/11-arrays.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 DIM m(10)
\   20 FOR n=1 TO 10: READ m(n): NEXT n
\   30 LET t=0
\   40 FOR n=1 TO 10: LET t=t+m(n): NEXT n
\   50 PRINT t/10
\   60 DATA 7,4,9,6,8,5,10,6,7,8

\ --- the translation

\ 11-arrays.md:214
CREATE MARKS  7 , 4 , 9 , 6 , 8 , 5 , 10 , 6 , 7 , 8 ,
: MARK  ( i -- n )  CELLS MARKS + @ ;
: AVERAGE  ( -- n )  0  10 0 DO  I MARK +  LOOP  10 / ;
AVERAGE .                       \ => 7
