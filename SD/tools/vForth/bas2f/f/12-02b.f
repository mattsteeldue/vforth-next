\ 12-02b.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/12-02.txt
\ guide: doc/basic-to-vforth/12-conditions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 INPUT a,b
\   20 PRINT (a AND NOT a<b)+(b AND a<b)

\ --- the translation

\ 12-conditions.md:205
3 8 MAX .  8 3 MAX .  3 8 MIN .                 \ => 8 8 3
