\ 12-06.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/12-06.txt
\ guide: doc/basic-to-vforth/12-conditions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 INPUT a,b,c
\   20 IF a<>b AND a<>c THEN PRINT "neither": ELSE PRINT "one of them"

\ --- the translation

\ 12-conditions.md:283
: NEITHER?  ( a b c -- flag )
    2 PICK <>  -ROT <>  AND ;
5 3 4 NEITHER? .  5 5 4 NEITHER? .  5 3 5 NEITHER? .    \ => -1 0 0
