\ 02-01.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/02-decisions-01.txt
\ guide: doc/basic-to-vforth/02-decisions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 INPUT n
\   20 IF n<0 THEN PRINT "negative": ELSE IF n>0 THEN PRINT "positive": ELSE
\       PRINT "zero"

\ --- the translation

\ 02-decisions.md:176
: ?SGN  ( n -- )
    DUP 0< IF
        DROP ." negative"
    ELSE
        0> IF  ." positive"  ELSE  ." zero"  THEN
    THEN ;
-7 ?SGN                        \ => negative
7 ?SGN                         \ => positive
0 ?SGN                         \ => zero
