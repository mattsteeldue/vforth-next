\ 08-01.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/08-functions-01.txt
\ guide: doc/basic-to-vforth/08-functions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 LET t=20
\   20 DEF FN m(a,b)=(a+b)/2
\   30 DEF FN d()=t*2
\   40 PRINT FN m(4,10)
\   50 PRINT FN d()

\ --- words defined earlier in the guide

\ 08-functions.md:61
: MEAN  ( a b -- m )  + 2 / ;
4 10 MEAN .                     \ => 7

\ --- the translation

\ 08-functions.md:302
VARIABLE T  20 T !
: DOUBLE-T  ( -- n )  T @ 2* ;
4 10 MEAN .                     \ => 7
DOUBLE-T .                      \ => 40
