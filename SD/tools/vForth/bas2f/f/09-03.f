\ 09-03.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/09-mathematical-functions-03.txt
\ guide: doc/basic-to-vforth/09-mathematical-functions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 INPUT r
\   20 PRINT 2*PI*r,PI*r*r

\ --- the translation

\ 09-mathematical-functions.md:234
\ no-test in the guide: it waits for keys, never ends or
\ needs hardware the emulator lacks
FLOATING
: CIRC  ( fp -- fp2 )  2.0 F* PI F* ;
: AREA  ( fp -- fp2 )  2DUP F* PI F* ;
INTEGER
FLOATING 2.5 CIRC F. INTEGER    \ => 1.5708e1
FLOATING 2.5 AREA F. INTEGER    \ => 1.9635e1
