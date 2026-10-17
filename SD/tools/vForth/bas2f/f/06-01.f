\ 06-01.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/06-expressions-01.txt
\ guide: doc/basic-to-vforth/06-expressions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 INPUT "Celsius? ";c
\   20 PRINT c*9/5+32

\ --- the translation

\ 06-expressions.md:398
: C>F  ( celsius -- fahrenheit )  9 5 */ 32 + ;
100 C>F .                       \ => 212
-40 C>F .                       \ => -40
37 C>F .                        \ => 98
