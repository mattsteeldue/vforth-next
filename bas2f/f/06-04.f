\ 06-04.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/06-04.txt
\ guide: doc/basic-to-vforth/06-expressions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 %a=50000
\   20 PRINT %a/2
\   30 PRINT % SGN {a/2}

\ --- the translation

\ 06-expressions.md:516
50000 0 2 UM/MOD NIP .          \ => 25000
50000 2 / .                     \ => -7768
