\ 09-02b.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/09-mathematical-functions-02.txt
\ guide: doc/basic-to-vforth/09-mathematical-functions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 FOR y=0 TO 10 STEP 5
\   20   PRINT y,1000*1.05^y
\   30 NEXT y

\ --- the translation

\ 09-mathematical-functions.md:214
: YEARS  ( n years -- n2 )  0 ?DO  105 100 */  LOOP ;
1000 10 YEARS .                 \ => 1623
10000 10 YEARS .                \ => 16284
