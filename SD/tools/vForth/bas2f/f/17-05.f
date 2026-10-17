\ 17-05.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/17-time-and-motion-05.txt
\ guide: doc/basic-to-vforth/17-time-and-motion.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 BORDER 0: PAPER 7: CLS
\   20 REG 67,0: REG 98,0: REG 97,0
\   30 FOR %b=0 TO 31
\   40 REG 96,232: REG 96,%b*8
\   50 REG 96,64: REG 96,16
\   60 REG 96,65: REG 96,%b&7*32
\   70 NEXT %b
\   80 REG 96,255: REG 96,255
\   90 REG 98,192
\   100 PAUSE 0
\   110 REG 98,0: REG 64,16: REG 65,0

\ --- the translation

\ 17-time-and-motion.md:549
\ no-test in the guide: it waits for keys, never ends or
\ needs hardware the emulator lacks
NEEDS COPPER  NEEDS LAYER0  NEEDS .PAPER  NEEDS .BORDER
: BAND  ( b -- )                \ eight lines, a shade of red
    DUP 8 * 52 COP-WAIT
    16 $40 COP-MOVE  7 AND 32 * $41 COP-MOVE ;
: BARS  ( -- )
    LAYER0  7 .PAPER  0 .BORDER  CLS  0 $43 REG!
    COP-STOP  32 0 DO  I BAND  LOOP  COP-HALT  COP-START
    KEY DROP
    COP-STOP  16 $40 REG!  0 $41 REG! ;
