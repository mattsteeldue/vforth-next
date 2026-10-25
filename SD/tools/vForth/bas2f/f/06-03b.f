\ 06-03b.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/06-03.txt
\ guide: doc/basic-to-vforth/06-expressions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 %i=7: %p=1: %b=1: %f=0
\   20 PRINT %(f<<7)|(b<<6)|(p<<3)|i

\ --- the translation

\ 06-expressions.md:494
: INK@    ( attr -- ink )    7 AND ;
: PAPER@  ( attr -- paper )  3 RSHIFT 7 AND ;
: BIT?    ( n bit -- flag )  1 SWAP LSHIFT AND 0= 0= ;
79 INK@ .                       \ => 7
79 PAPER@ .                     \ => 1
79 6 BIT? .                     \ => -1
79 7 BIT? .                     \ => 0
