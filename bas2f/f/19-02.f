\ 19-02.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/19-02.txt
\ guide: doc/basic-to-vforth/19-nextzxos-and-alternatives.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 PRINT "Hello"

\ --- the translation

\ 19-nextzxos-and-alternatives.md:265
: HELLO  ( -- )  ." Hello" CR ;
HELLO
