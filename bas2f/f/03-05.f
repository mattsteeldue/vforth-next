\ 03-05.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/03-05.txt
\ guide: doc/basic-to-vforth/03-looping.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 LET p=42
\   20 FOR a=1 TO 9
\   30   FOR b=1 TO 9
\   40     IF a*b=p THEN PRINT a;" ";b: EXIT: EXIT 80
\   50   NEXT b
\   60 NEXT a
\   70 PRINT "none"
\   80 REM continue here
\   90 PRINT a
\   100 PRINT b

\ --- the translation

\ 03-looping.md:273
NEEDS J
NEEDS UNLOOP
: FACTORS  ( p -- )
    10 1 DO
        10 1 DO
            J I * OVER = IF
                DROP  J . I .
                UNLOOP UNLOOP EXIT
            THEN
        LOOP
    LOOP
    DROP ." none" ;
42 FACTORS              \ => 6 7
97 FACTORS              \ => none
