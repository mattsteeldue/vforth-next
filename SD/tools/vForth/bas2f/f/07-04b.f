\ 07-04b.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/07-04.txt
\ guide: doc/basic-to-vforth/07-strings.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 LET a$="   hello there   "
\   20 PRINT a$[<>+];"."

\ --- words defined earlier in the guide

\ 07-strings.md:89
CREATE NAME$  32 ALLOT

\ --- the translation

\ 07-strings.md:398
NEEDS WITHIN
: LOWER  ( c -- c2 )  DUP 65 91 WITHIN IF  32 +  THEN ;
: LOWCASE  ( a n -- )
    BOUNDS ?DO  I C@ LOWER I C!  LOOP ;
NAME$ COUNT LOWCASE
NAME$ COUNT TYPE                \ => hello there
