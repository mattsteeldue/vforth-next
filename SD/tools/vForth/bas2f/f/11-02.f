\ 11-02.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/11-arrays-02.txt
\ guide: doc/basic-to-vforth/11-arrays.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 DIM t(3,6)
\   20 FOR r=1 TO 3: FOR c=1 TO 6
\   30   LET t(r,c)=r*c
\   40 NEXT c: NEXT r
\   50 FOR r=1 TO 3
\   60   FOR c=1 TO 6: PRINT t(r,c);" ";: NEXT c
\   70   PRINT
\   80 NEXT r

\ --- words defined earlier in the guide

\ 11-arrays.md:73
: MATRIX  ( rows cols -- )
    CREATE  2DUP , ,  * CELLS HERE OVER ERASE ALLOT
    DOES>  ( r c pfa -- addr )
        >R  SWAP R@ @ * +  CELLS R> + 2 CELLS + ;
3 6 MATRIX GRID
7 2 5 GRID !
2 5 GRID @ .                    \ => 7

\ --- the translation

\ 11-arrays.md:238
NEEDS J
3 6 MATRIX PRODUCTS
: FILL-PRODUCTS  ( -- )
    3 0 DO  6 0 DO  J 1+ I 1+ *  J I PRODUCTS !  LOOP  LOOP ;
: .PRODUCTS  ( -- )
    3 0 DO  6 0 DO  J I PRODUCTS @ 3 .R  LOOP  CR  LOOP ;
FILL-PRODUCTS .PRODUCTS
\ output of the last line:
\   1  2  3  4  5  6
\   2  4  6  8 10 12
\   3  6  9 12 15 18
