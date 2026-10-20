\ 11-03.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/11-03.txt
\ guide: doc/basic-to-vforth/11-arrays.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 DIM m$(12,9)
\   20 FOR n=1 TO 12: READ m$(n): NEXT n
\   30 PRINT "Spring: ";m$(3);m$(4);m$(5)
\   40 PRINT "the month of ";m$(5);"ing"
\   50 DATA "January","February","March","April"
\   60 DATA "May","June","July","August","September"
\   70 DATA "October","November","December"

\ --- words defined earlier in the guide

\ 11-arrays.md:98
: SARRAY  ( n len -- )
    CREATE  DUP , * HERE OVER BLANK ALLOT
    DOES>  ( i pfa -- a len )
        DUP @ >R  CELL+ SWAP R@ * +  R> ;
3 10 SARRAY A$

\ 11-arrays.md:110
NEEDS S"
: S!  ( a u dest len -- )  2DUP BLANK  ROT MIN CMOVE ;
S" 1234567890" 1 A$ S!
1 A$ TYPE                       \ => 1234567890
S" much too long a text" 0 A$ S!
0 A$ TYPE  1 A$ TYPE            \ => much too l1234567890

\ --- the translation

\ 11-arrays.md:272
13 9 SARRAY MONTH$
: M!  ( a u i -- )  MONTH$ S! ;
S" January" 1 M!   S" February" 2 M!   S" March" 3 M!
S" April" 4 M!     S" May" 5 M!        S" June" 6 M!
S" July" 7 M!      S" August" 8 M!     S" September" 9 M!
S" October" 10 M!  S" November" 11 M!  S" December" 12 M!
: SPRING  ( -- )  6 3 DO  I MONTH$ TYPE  LOOP ;
." Spring: " SPRING             \ => Spring: March    April    May
." the month of " 5 MONTH$ -TRAILING TYPE ." ing"
\ output of the last line:
\ the month of Maying
