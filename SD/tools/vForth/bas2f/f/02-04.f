\ 02-04.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/02-04.txt
\ guide: doc/basic-to-vforth/02-decisions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 INPUT n
\   20 PRINT n?(1,2,5,10,20,50)

\ --- the translation

\ 02-decisions.md:276
CREATE COINS  1 , 2 , 5 , 10 , 20 , 50 ,
: COIN  ( n -- value )  5 MIN  CELLS COINS + @ ;
2 COIN .                        \ => 5
9 COIN .                        \ => 50
