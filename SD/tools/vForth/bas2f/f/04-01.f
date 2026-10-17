\ 04-01.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/04-procedures-and-subroutines-01.txt
\ guide: doc/basic-to-vforth/04-procedures-and-subroutines.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 LET n=5: GO SUB 100
\   20 LET n=12: GO SUB 100
\   30 STOP
\   100 REM a line of n dashes
\   110 FOR i=1 TO n: PRINT "-";: NEXT i
\   120 PRINT
\   130 RETURN

\ --- words defined earlier in the guide

\ 04-procedures-and-subroutines.md:27
: RULE  ( n -- )  0 ?DO  ." -"  LOOP ;
5 RULE                          \ => -----

\ --- the translation

\ 04-procedures-and-subroutines.md:315
5 RULE                          \ => -----
12 RULE                         \ => ------------
