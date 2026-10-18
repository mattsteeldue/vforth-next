\ 02-03b.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/02-03.txt
\ guide: doc/basic-to-vforth/02-decisions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 INPUT "Choice (0-2)? ";c
\   20 ON c: PRINT "load": PRINT "save": PRINT "quit": ELSE PRINT "what?"

\ --- the translation

\ 02-decisions.md:253
NEEDS EXEC:
: .LOAD  ." load" ;
: .SAVE  ." save" ;
: .QUIT  ." quit" ;
: CHOICE  ( n -- )
    0 MAX 2 MIN
    EXEC: .LOAD .SAVE .QUIT ;
1 CHOICE                        \ => save
7 CHOICE                        \ => quit
