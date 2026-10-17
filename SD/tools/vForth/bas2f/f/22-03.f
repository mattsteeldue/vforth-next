\ 22-03.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/22-in-out-and-the-next-registers-03.txt
\ guide: doc/basic-to-vforth/22-in-out-and-the-next-registers.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 FOR c=0 TO 7
\   20   OUT 254,c: PAUSE 10
\   30 NEXT c
\   40 OUT 254,% PEEK 23624>>3&7

\ --- words defined earlier in the guide

\ 22-in-out-and-the-next-registers.md:113
NEEDS .BORDER
: BORDER@  ( -- c )  23624 C@ 3 RSHIFT 7 AND ;
5 .BORDER  2 254 P!  BORDER@ .  \ => 5

\ --- the translation

\ 22-in-out-and-the-next-registers.md:250
NEEDS MS
: STRIPES  ( -- )
    8 0 DO  I 254 P!  200 MS  LOOP
    BORDER@ 254 P! ;
STRIPES
