\ 09-05.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/09-05.txt
\ guide: doc/basic-to-vforth/09-mathematical-functions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 FOR a=30 TO 60 STEP 30
\   20   PRINT 200*SIN (a*PI/180)
\   30 NEXT a

\ --- the translation

\ 09-mathematical-functions.md:290
\ no-test in the guide: it waits for keys, never ends or
\ needs hardware the emulator lacks
FLOATING
: HEIGHT  ( degrees -- fp )  FLOAT DEG>RAD FSIN  200.0 F* ;
INTEGER
30 HEIGHT F>D D.                \ => 100
60 HEIGHT F>D D.                \ => 173
