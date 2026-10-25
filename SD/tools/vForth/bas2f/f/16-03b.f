\ 16-03b.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/16-03.txt
\ guide: doc/basic-to-vforth/16-graphics.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 LAYER 1,2: CLS
\   20 FOR n=1 TO 65536
\   30   LET r=INT (RND*65536)
\   40   PLOT r-512*INT (r/512),32+INT (r/512)
\   50 NEXT n
\   60 PAUSE 0

\ --- words defined earlier in the guide

\ 16-graphics.md:334
NEEDS RND
23670 CONSTANT SEED
: NEXT-RND  ( -- u )  SEED @ NEXT-SEED  DUP SEED ! ;
: STEPS  ( n -- )  0 ?DO  NEXT-RND DROP  LOOP ;
1 SEED !  65535 STEPS  SEED @ .  \ => 25340
1 STEPS  SEED @ .               \ => 1

\ --- the translation

\ 16-graphics.md:344
\ no-test in the guide: it waits for keys, never ends or
\ needs hardware the emulator lacks
NEEDS GRAPHICS
: RND-FILL  ( -- )
    LAYER12 CLS
    256 0 DO  256 0 DO
        NEXT-RND  DUP 9 RSHIFT 32 +  SWAP 511 AND  PLOT
    LOOP  LOOP ;
