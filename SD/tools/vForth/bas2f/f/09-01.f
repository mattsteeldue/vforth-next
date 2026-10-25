\ 09-01.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/09-01.txt
\ guide: doc/basic-to-vforth/09-mathematical-functions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 PRINT 2^10

\ --- the translation

\ 09-mathematical-functions.md:170
FLOATING
2.0 10.0 F** F.                 \ => 1.0240e3
INTEGER
