\ 15-04.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/15-colours-04.txt
\ guide: doc/basic-to-vforth/15-colours.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 LAYER PALETTE 0,2,BIN 111011000

\ --- words defined earlier in the guide

\ 15-colours.md:123
: RGB8  ( r g b -- c )  2/  SWAP 2 LSHIFT OR  SWAP 5 LSHIFT OR ;
7 3 0 RGB8 .                    \ => 236

\ --- the translation

\ 15-colours.md:237
\ no-test in the guide: it waits for keys, never ends or
\ needs hardware the emulator lacks
: ORANGE  ( -- )
    0 $43 REG!                  \ write the first ULA palette
    2 $40 REG!                  \ entry 2: ink 2, red
    7 3 0 RGB8 $41 REG! ;
