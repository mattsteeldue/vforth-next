\ 02-03.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/02-decisions-03.txt
\ guide: doc/basic-to-vforth/02-decisions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 INPUT "Choice (0-2)? ";c
\   20 ON c: PRINT "load": PRINT "save": PRINT "quit": ELSE PRINT "what?"

\ --- the translation

\ 02-decisions.md:235
NEEDS CASE
: CHOICE  ( n -- )
    CASE
        0 OF  ." load"  ENDOF
        1 OF  ." save"  ENDOF
        2 OF  ." quit"  ENDOF
        ." what?"
    ENDCASE ;
1 CHOICE                        \ => save
7 CHOICE                        \ => what?
