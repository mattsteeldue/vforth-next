\ 05-06.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/05-06.txt
\ guide: doc/basic-to-vforth/05-read-data-restore.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 LET x=5
\   20 READ a,b,c: PRINT a;" ";b;" ";c
\   30 LET x=10: RESTORE
\   40 READ a,b,c: PRINT a;" ";b;" ";c
\   50 DATA x,x*2,x*x

\ --- the translation

\ 05-read-data-restore.md:313
NEEDS EVALUATE
NEEDS S"
10 CONSTANT DATA-SCR
: DATA-LINE  ( n -- a )  8 /MOD  DATA-SCR 2* +  BLOCK  SWAP 64 * + ;
: LINE!  ( a u n -- )  DATA-LINE  DUP 64 BLANK  SWAP CMOVE  UPDATE ;
VARIABLE DATA#
: RESTORE-LINE  ( n -- )  DATA# ! ;
: READ-LINE  ( -- ? )
    DATA# @ DATA-LINE  PAD 64 CMOVE  PAD 64 EVALUATE
    1 DATA# +! ;
VARIABLE X
S" X @" 0 LINE!
S" X @ 2 *" 1 LINE!
S" X @ DUP *" 2 LINE!
5 X !  0 RESTORE-LINE
READ-LINE . READ-LINE . READ-LINE .     \ => 5 10 25
10 X !  0 RESTORE-LINE
READ-LINE . READ-LINE . READ-LINE .     \ => 10 20 100
