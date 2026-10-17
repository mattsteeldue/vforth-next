\ 14-01b.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/14-more-about-print-and-input-01.txt
\ guide: doc/basic-to-vforth/14-more-about-print-and-input.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 FOR n=1 TO 5
\   20   PRINT n;TAB 6;n*n;TAB 12;n*n*n
\   30 NEXT n

\ --- the translation

\ 14-more-about-print-and-input.md:234
: POWERS  ( -- )
    6 1 DO
        CR  I 3 .R  I I * 6 .R  I I * I * 6 .R
    LOOP ;
POWERS
\ output of the last line:
\   1     1     1
\   2     4     8
\   3     9    27
\   4    16    64
\   5    25   125
