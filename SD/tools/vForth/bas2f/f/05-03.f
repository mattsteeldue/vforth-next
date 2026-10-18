\ 05-03.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/05-03.txt
\ guide: doc/basic-to-vforth/05-read-data-restore.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 INPUT m
\   20 RESTORE
\   30 FOR i=1 TO m: READ d: NEXT i
\   40 PRINT d
\   50 DATA 31,28,31,30,31,30,31,31,30,31,30,31

\ --- the translation

\ 05-read-data-restore.md:234
CREATE MDAYS
    31 C, 28 C, 31 C, 30 C, 31 C, 30 C,
    31 C, 31 C, 30 C, 31 C, 30 C, 31 C,
: DAYS-IN  ( month -- days )  1- MDAYS + C@ ;
2 DAYS-IN .                     \ => 28
12 DAYS-IN .                    \ => 31
