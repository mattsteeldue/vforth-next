\ 01-01b.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/01-basic-programming-concepts-01.txt
\ guide: doc/basic-to-vforth/01-basic-programming-concepts.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 LET apples=7
\   20 LET pears=5
\   30 PRINT apples+pears

\ --- the translation

\ 01-basic-programming-concepts.md:319
7 5 + .                         \ => 12
