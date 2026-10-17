\ 05-04.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/05-read-data-restore-04.txt
\ guide: doc/basic-to-vforth/05-read-data-restore.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 FOR i=1 TO 3
\   20   READ c$: PRINT c$;" ";
\   30 NEXT i
\   40 DATA "red","green","blue"

\ --- the translation

\ 05-read-data-restore.md:240
CREATE C0  ," red"
CREATE C1  ," green"
CREATE C2  ," blue"
CREATE COLOURS  C0 , C1 , C2 ,
: COLOUR  ( i -- )  CELLS COLOURS + @  COUNT TYPE ;
1 COLOUR                        \ => green
: .COLOURS  ( -- )  3 0 DO  I COLOUR SPACE  LOOP ;
.COLOURS                        \ => red green blue
