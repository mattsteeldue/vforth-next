\ 15-02.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/15-02.txt
\ guide: doc/basic-to-vforth/15-colours.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 PRINT "e";CHR$ 8;OVER 1;"'";OVER 0

\ --- the translation

\ 15-colours.md:233
: E-ACUTE  ( -- )  ." e" 8 EMITC  1 .OVER ." '" 0 .OVER ;
