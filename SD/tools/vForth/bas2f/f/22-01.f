\ 22-01.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/22-in-out-and-the-next-registers-01.txt
\ guide: doc/basic-to-vforth/22-in-out-and-the-next-registers.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 LET s=% REG 7&3
\   20 PRINT "Speed: ";s
\   30 RUN AT 0
\   40 PRINT "Now: ";% REG 7&3
\   50 RUN AT s

\ --- the translation

\ 22-in-out-and-the-next-registers.md:203
: SLOW-REPORT  ( -- )
    SPEED@  ." Speed: " DUP . CR
    0 SPEED!  ." Now: " SPEED@ . CR
    SPEED! ;
SLOW-REPORT
\ output of the last line:
\ Speed: 3
\ Now: 0
