\ 12-01.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/12-conditions-01.txt
\ guide: doc/basic-to-vforth/12-conditions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 INPUT "Answer (y/n)? ";a$
\   20 INPUT "Number? ";x
\   30 IF a$="y" AND x>0 THEN PRINT x: ELSE PRINT "-"

\ --- the translation

\ 12-conditions.md:24
: SHOW  ( x answer -- )
    [CHAR] y =  OVER 0> AND
    IF  .  ELSE  DROP ." -"  THEN ;
5 CHAR y SHOW                   \ => 5
-5 CHAR y SHOW                  \ => -
5 CHAR n SHOW                   \ => -
