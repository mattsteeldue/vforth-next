\ 06-01b.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/06-01.txt
\ guide: doc/basic-to-vforth/06-expressions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 INPUT "Celsius? ";c
\   20 PRINT c*9/5+32

\ --- the translation

\ 06-expressions.md:438
: C>F10  ( celsius -- tenths )  90 5 */ 320 + ;
: .TENTHS  ( n -- )  0 <# # 46 HOLD #S #> TYPE ;
37 C>F10 .                      \ => 986
37 C>F10 .TENTHS                \ => 98.6
100 C>F10 .TENTHS               \ => 212.0
