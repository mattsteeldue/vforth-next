\ 02-02.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/02-decisions-02.txt
\ guide: doc/basic-to-vforth/02-decisions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 INPUT "Score? ";s
\   20 IF s>=90
\   30   PRINT "excellent"
\   40 ELSE IF s>=60
\   50   PRINT "pass"
\   60 ELSE
\   70   PRINT "fail"
\   80 ENDIF

\ --- the translation

\ 02-decisions.md:214
: GRADE  ( score -- )
    DUP 89 > IF  DROP ." excellent"  EXIT THEN
        59 > IF       ." pass"       EXIT THEN
    ." fail" ;
95 GRADE                        \ => excellent
90 GRADE                        \ => excellent
60 GRADE                        \ => pass
59 GRADE                        \ => fail
