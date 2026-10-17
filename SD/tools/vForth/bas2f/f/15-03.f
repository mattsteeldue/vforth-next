\ 15-03.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/15-colours-03.txt
\ guide: doc/basic-to-vforth/15-colours.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 PRINT AT 5,3;PAPER 6;INK 1;"*"
\   20 PRINT AT 6,0;ATTR (5,3)

\ --- words defined earlier in the guide

\ 15-colours.md:84
: ATTR-ADDR  ( row col -- a )  SWAP 32 * +  $5800 + ;
: ATTR  ( row col -- b )  ATTR-ADDR C@ ;
5 3 ATTR-ADDR .                 \ => 22691

\ --- the translation

\ 15-colours.md:220
\ no-test in the guide: it waits for keys, never ends or
\ needs hardware the emulator lacks
NEEDS .AT
: STAR  ( -- )
    5 3 .AT  1 .INK 6 .PAPER ." *"
    6 0 .AT  5 3 ATTR . ;
