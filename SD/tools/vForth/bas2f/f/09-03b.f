\ 09-03b.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/09-03.txt
\ guide: doc/basic-to-vforth/09-mathematical-functions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 INPUT r
\   20 PRINT 2*PI*r,PI*r*r

\ --- the translation

\ 09-mathematical-functions.md:246
: CIRC  ( r -- c )  2* 355 113 */ ;
: AREA  ( r -- a )  DUP * 355 113 */ ;
100 CIRC .                      \ => 628
10 AREA .                       \ => 314
100 AREA .                      \ => 31415
