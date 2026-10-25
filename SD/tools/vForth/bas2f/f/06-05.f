\ 06-05.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/06-05.txt
\ guide: doc/basic-to-vforth/06-expressions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 PRINT 24*60*60

\ --- the translation

\ 06-expressions.md:530
24 60 * 60 * .                  \ => 20864
24 60 * 60 M* D.                \ => 86400
