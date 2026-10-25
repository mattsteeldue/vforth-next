\ 17-02f.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/17-02.txt
\ guide: doc/basic-to-vforth/17-time-and-motion.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 T$= TIME $
\   20 PRINT 't$
\   30 PROC now() TO h,m,s
\   40 PRINT "It's ";h;":";m
\   90 STOP
\   100 DEFPROC Now()
\   110 T$= TIME $
\   120 PRINT 't$
\   130 hh= VAL (T$(12)+T$(13))
\   140 mi= VAL (T$(15)+T$(16))
\   150 ss= VAL (T$(18)+T$(19))
\   160 ENDPROC =hh,mi,ss

\ --- words defined earlier in the guide

\ 17-time-and-motion.md:332
: ROW!  ( n1 ... n16 a -- )
    15 +  16 0 DO  SWAP OVER C!  1-  LOOP  DROP ;
: ROW,  ( n1 ... n16 -- )  HERE ROW!  16 ALLOT ;
CREATE PROBE  1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 ROW,
PROBE C@ .  PROBE 15 + C@ .     \ => 1 16

\ 17-time-and-motion.md:344
$E3 CONSTANT _                  \ transparent
$88 CONSTANT h                  \ hair, brown
$F6 CONSTANT o                  \ skin
$00 CONSTANT k                  \ eye and shoes, black
$E0 CONSTANT s                  \ shirt, red
$03 CONSTANT t                  \ trousers, blue
CREATE WALKER
_ _ _ _ _ _ h h h h _ _ _ _ _ _ ROW,
_ _ _ _ _ h h h h h h _ _ _ _ _ ROW,
_ _ _ _ _ h o o o o _ _ _ _ _ _ ROW,
_ _ _ _ _ o o o o k _ _ _ _ _ _ ROW,
_ _ _ _ _ o o o o o o o _ _ _ _ ROW,
_ _ _ _ _ _ o o o o _ _ _ _ _ _ ROW,
_ _ _ _ _ s s s s s s s _ _ _ _ ROW,
_ _ _ _ s s s s s s s s s _ _ _ ROW,
_ _ _ s s _ s s s s s _ s s _ _ ROW,
_ _ o _ _ _ s s s s s _ _ _ o _ ROW,
_ _ _ _ _ _ t t t t t _ _ _ _ _ ROW,
_ _ _ _ _ t t t _ t t t _ _ _ _ ROW,
_ _ _ _ _ t t t _ _ t t t _ _ _ ROW,
_ _ _ t t t _ _ _ _ _ t t t _ _ ROW,
_ k k k _ _ _ _ _ _ _ _ k k k _ ROW,
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ ROW,
WALKER 255 + C@ .               \ => 227

\ 17-time-and-motion.md:381
CREATE WALKER2  256 ALLOT
WALKER WALKER2 256 CMOVE
: ROW2!  ( n1 ... n16 r -- )  16 * WALKER2 + ROW! ;
_ _ _ _ _ s s s s s s s _ _ _ _  7 ROW2!
_ _ _ _ _ s s s s s s s _ _ _ _  8 ROW2!
_ _ _ _ _ _ s s s s s _ _ _ _ _  9 ROW2!
_ _ _ _ _ _ _ t t t _ _ _ _ _ _ 11 ROW2!
_ _ _ _ _ _ _ t t t _ _ _ _ _ _ 12 ROW2!
_ _ _ _ _ _ _ t t t _ _ _ _ _ _ 13 ROW2!
_ _ _ _ _ _ _ k k k k k _ _ _ _ 14 ROW2!
WALKER2 14 16 * + 7 + C@ .      \ => 0

\ --- the translation

\ 17-time-and-motion.md:398
\ no-test in the guide: it waits for keys, never ends or
\ needs hardware the emulator lacks
NEEDS SPRITE
: PATTERN!  ( a p -- )  SWAP SPRITE-BUFFER 256 CMOVE  SPRITE-INIT ;
WALKER 0 PATTERN!  WALKER2 1 PATTERN!
