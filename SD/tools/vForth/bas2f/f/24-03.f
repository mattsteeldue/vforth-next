\ 24-03.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/24-the-system-variables-03.txt
\ guide: doc/basic-to-vforth/24-the-system-variables.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 PRINT AT 5,10;"Hello";
\   20 LET c=33-PEEK 23688: LET r=24-PEEK 23689
\   30 PRINT AT 0,0;r,c

\ --- the translation

\ 24-the-system-variables.md:168
\ no-test in the guide: it waits for keys, never ends or
\ needs hardware the emulator lacks
NEEDS .AT
: COL  ( -- n )  33 23688 C@ - ;
: ROW  ( -- n )  24 23689 C@ - ;
: WHERE?  ( -- )  5 10 .AT ." Hello"  COL ROW  0 0 .AT . . ;
WHERE?
