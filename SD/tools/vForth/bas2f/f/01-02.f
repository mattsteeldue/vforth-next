\ 01-02.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/01-basic-programming-concepts-02.txt
\ guide: doc/basic-to-vforth/01-basic-programming-concepts.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 REM inches to millimetres
\   20 INPUT "Inches? ";i
\   30 PRINT i;" in = ";i*25.4;" mm"
\   40 GO TO 20

\ --- the translation

\ 01-basic-programming-concepts.md:337
: >MM  ( inches -- mm )  254 10 */ ;
12 >MM .                        \ => 304
