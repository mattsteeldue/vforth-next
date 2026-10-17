\ 03-04.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/03-looping-04.txt
\ guide: doc/basic-to-vforth/03-looping.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 FOR i=1 TO 20
\   20   IF i*i>50 THEN EXIT
\   30   PRINT i*i;" ";
\   40 NEXT i
\   50 PRINT "done"

\ --- the translation

\ 03-looping.md:247
: SQUARES  ( -- )
    21 1 DO
        I I * 50 > IF  LEAVE  THEN
        I I * .
    LOOP
    ." done" ;
SQUARES                 \ => 1 4 9 16 25 36 49 done
