\ 09-02.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/09-02.txt
\ guide: doc/basic-to-vforth/09-mathematical-functions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 FOR y=0 TO 10 STEP 5
\   20   PRINT y,1000*1.05^y
\   30 NEXT y

\ --- the translation

\ 09-mathematical-functions.md:198
FLOATING
: SAVINGS  ( years -- fp )  FLOAT 1.05 2SWAP F**  1000.0 F* ;
INTEGER
10 SAVINGS F>D D.               \ => 1628
