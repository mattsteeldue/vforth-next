\ 14-01.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/14-more-about-print-and-input-01.txt
\ guide: doc/basic-to-vforth/14-more-about-print-and-input.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 FOR n=1 TO 5
\   20   PRINT n;TAB 6;n*n;TAB 12;n*n*n
\   30 NEXT n

\ --- the translation

\ 14-more-about-print-and-input.md:223
: POWERS  ( -- )
    6 1 DO
        CR  I .  6 .TAB  I I * .  12 .TAB  I I * I * .
    LOOP ;
