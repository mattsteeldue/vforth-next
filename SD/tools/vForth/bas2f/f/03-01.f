\ 03-01.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/03-01.txt
\ guide: doc/basic-to-vforth/03-looping.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 LET s=0
\   20 FOR i=1 TO 10
\   30   LET s=s+i
\   40 NEXT i
\   50 PRINT s

\ --- the translation

\ 03-looping.md:168
: SUM-TO  ( n -- sum )
    0 SWAP              \ the running total, under n
    1+ 1 DO             \ from 1 to n: the limit is n+1
        I +
    LOOP ;
10 SUM-TO .             \ => 55
