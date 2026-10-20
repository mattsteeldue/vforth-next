\ 05-02.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/05-02.txt
\ guide: doc/basic-to-vforth/05-read-data-restore.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 FOR n=1 TO 5
\   20   READ d: PRINT d;" ";
\   30 NEXT n
\   40 DATA 31,28,31,30,31

\ --- the translation

\ 05-read-data-restore.md:207
CREATE MONTHS  31 , 28 , 31 , 30 , 31 ,
: .MONTHS  ( -- )
    MONTHS 5 CELLS BOUNDS DO
        I @ .
    2 +LOOP ;
.MONTHS                         \ => 31 28 31 30 31
