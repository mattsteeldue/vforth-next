\ 06-02b.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/06-02.txt
\ guide: doc/basic-to-vforth/06-expressions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 LET a=2: LET b=3: LET c=7: LET d=4
\   20 PRINT (a+b)*(c-d)

\ --- the translation

\ 06-expressions.md:468
: F  ( a b c d -- n )  -  -ROT  +  * ;
2 3 7 4 F .                     \ => 15
