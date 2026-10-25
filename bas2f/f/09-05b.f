\ 09-05b.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/09-05.txt
\ guide: doc/basic-to-vforth/09-mathematical-functions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 FOR a=30 TO 60 STEP 30
\   20   PRINT 200*SIN (a*PI/180)
\   30 NEXT a

\ --- the translation

\ 09-mathematical-functions.md:295
CREATE SINES
    0 , 1736 , 3420 , 5000 , 6428 ,
    7660 , 8660 , 9397 , 9848 , 10000 ,
: SIN10  ( tens-of-degrees -- sine*10000 )  CELLS SINES + @ ;
: COS10  ( tens-of-degrees -- cosine*10000 )  9 SWAP - SIN10 ;
3 SIN10 .                       \ => 5000
200 3 SIN10 10000 */ .          \ => 100
200 6 SIN10 10000 */ .          \ => 173
200 6 COS10 10000 */ .          \ => 100
