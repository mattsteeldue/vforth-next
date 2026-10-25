\ 16-02b.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/16-02.txt
\ guide: doc/basic-to-vforth/16-graphics.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 FOR n=0 TO 255
\   20   LET x=(n-128)/50
\   30   IF x<>0 THEN PLOT n,88+30*x*LN (ABS x)
\   40 NEXT n

\ --- words defined earlier in the guide

\ 16-graphics.md:282
NEEDS VALUE
NEEDS TO
NEEDS +TO
0 VALUE LN50
: SLICE  ( u -- n )  2* 1+ 10000 SWAP / ;
: XLNX  ( u -- y )  3 *  LN50 25000 */ ;
: LN-UP  ( u -- )  0 TO LN50  50 ?DO  I SLICE +TO LN50  LOOP ;
100 LN-UP  LN50 .  100 XLNX .   \ => 3442 41

\ --- the translation

\ 16-graphics.md:301
\ no-test in the guide: it waits for keys, never ends or
\ needs hardware the emulator lacks
: TWIN  ( u -- )                \ the point at u and its mirror at -u
    DUP XLNX                    ( u y )
    87 OVER -  2 PICK 128 +  PLOT
    87 +  128 ROT -  PLOT ;
: XLNX-GRAPH  ( -- )
    0 TO LN50  128 50 DO  I TWIN  I SLICE +TO LN50  LOOP
    0 TO LN50  1 49 DO  I SLICE NEGATE +TO LN50  I TWIN  -1 +LOOP ;
