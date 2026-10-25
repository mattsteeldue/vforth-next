\ 06-03.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/06-03.txt
\ guide: doc/basic-to-vforth/06-expressions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 %i=7: %p=1: %b=1: %f=0
\   20 PRINT %(f<<7)|(b<<6)|(p<<3)|i

\ --- the translation

\ 06-expressions.md:485
: ATTR  ( ink paper bright flash -- attr )
    7 LSHIFT  SWAP 6 LSHIFT OR
    SWAP 3 LSHIFT OR  OR ;
7 1 1 0 ATTR .                  \ => 79
