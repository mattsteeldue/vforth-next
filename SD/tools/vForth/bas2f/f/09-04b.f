\ 09-04b.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/09-04.txt
\ guide: doc/basic-to-vforth/09-mathematical-functions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 PRINT SQR 2

\ --- the translation

\ 09-mathematical-functions.md:274
NEEDS DSQRT
2000000. DSQRT .                \ => 1414
200000000. DSQRT .              \ => 14142
