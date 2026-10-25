\ 09-04.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/09-04.txt
\ guide: doc/basic-to-vforth/09-mathematical-functions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 PRINT SQR 2

\ --- the translation

\ 09-mathematical-functions.md:257
FLOATING
2.0 FSQRT F.                    \ => 1.4142e0
INTEGER
