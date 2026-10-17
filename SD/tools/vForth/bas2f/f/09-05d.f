\ 09-05d.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/09-mathematical-functions-05.txt
\ guide: doc/basic-to-vforth/09-mathematical-functions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 FOR a=30 TO 60 STEP 30
\   20   PRINT 200*SIN (a*PI/180)
\   30 NEXT a

\ --- words defined earlier in the guide

\ 09-mathematical-functions.md:327
NEEDS VALUE
NEEDS TO
NEEDS +TO
0 VALUE SINE  0 VALUE COSINE
: START-WAVE  ( amplitude -- )  100 * TO COSINE  0 TO SINE ;
: TURN  ( -- )
    COSINE 201 8192 */ +TO SINE
    SINE 201 8192 */ NEGATE +TO COSINE ;
: TURNS  ( n -- )  0 ?DO  TURN  LOOP ;
80 START-WAVE  64 TURNS  SINE 100 / .   \ => 80
64 TURNS  SINE 100 / .          \ => 0

\ --- the translation

\ 09-mathematical-functions.md:352
\ no-test in the guide: it waits for keys, never ends or
\ needs hardware the emulator lacks
: WAVE  ( -- )
    80 START-WAVE
    256 0 DO  87 SINE 100 / -  I PLOT  TURN  LOOP ;
