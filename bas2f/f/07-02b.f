\ 07-02b.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/07-02.txt
\ guide: doc/basic-to-vforth/07-strings.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 LET n$="Spectrum"
\   20 LET g$="Hello, "+n$+"!"
\   30 PRINT g$
\   40 PRINT LEN g$

\ --- words defined earlier in the guide

\ 07-strings.md:26
NEEDS S"
: PLANET  ( -- a n )  S" Spectrum" ;
PLANET TYPE                     \ => Spectrum
PLANET NIP .                    \ => 8

\ --- the translation

\ 07-strings.md:351
: GREET  ( a n -- )  ." Hello, " TYPE ." !" ;
PLANET GREET                    \ => Hello, Spectrum!
