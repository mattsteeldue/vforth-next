\ 22-02.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/22-02.txt
\ guide: doc/basic-to-vforth/22-in-out-and-the-next-registers.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 PRINT "Press SPACE"
\   20 IF %IN 32766&1 THEN GO TO 20
\   30 PRINT "Thank you"

\ --- the translation

\ 22-in-out-and-the-next-registers.md:228
: SPACE?  ( -- flag )  32766 P@ 1 AND 0= ;
: WAIT-SPACE  ( -- )
    ." Press SPACE" CR
    BEGIN SPACE? UNTIL
    ." Thank you" CR ;
SPACE? .                        \ => 0
