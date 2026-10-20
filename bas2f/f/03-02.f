\ 03-02.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/03-02.txt
\ guide: doc/basic-to-vforth/03-looping.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 FOR n=10 TO 1 STEP -1: PRINT n;" ";: NEXT n
\   20 PRINT
\   30 FOR n=1 TO 9 STEP 3: PRINT n;" ";: NEXT n

\ --- the translation

\ 03-looping.md:189
: DOWN    1 10 DO  I .  -1 +LOOP ;
: BY-3   10  1 DO  I .   3 +LOOP ;
DOWN                    \ => 10 9 8 7 6 5 4 3 2 1
BY-3                    \ => 1 4 7
