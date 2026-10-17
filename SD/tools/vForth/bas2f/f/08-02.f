\ 08-02.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/08-functions-02.txt
\ guide: doc/basic-to-vforth/08-functions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 DEF FN t(n)=n?(0,n+FN t(n-1))
\   20 PRINT FN t(10)

\ --- the translation

\ 08-functions.md:320
: TRI  ( n -- sum )  DUP IF  DUP 1- RECURSE +  THEN ;
10 TRI .                        \ => 55
