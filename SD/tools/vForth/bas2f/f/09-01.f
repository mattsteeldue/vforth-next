\ 09-01.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/09-01.txt
\ guide: doc/basic-to-vforth/09-mathematical-functions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 PRINT 2^10

\ --- words defined earlier in the guide

\ 09-mathematical-functions.md:28
NEEDS FLOATING
FLOATING
7.0 2.0 F/ F.                   \ => 3.5000e0
INTEGER

\ --- the translation

\ 09-mathematical-functions.md:170
FLOATING
2.0 10.0 F** F.                 \ => 1.0240e3
INTEGER
