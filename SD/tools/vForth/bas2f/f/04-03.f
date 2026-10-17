\ 04-03.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/04-procedures-and-subroutines-03.txt
\ guide: doc/basic-to-vforth/04-procedures-and-subroutines.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   5 PRIVATE CLEAR
\   10 FOR i=1 TO 3: PROC ticket(): NEXT i
\   20 STOP
\   30 DEFPROC ticket()
\   40   PRIVATE t=0
\   50   t+=1
\   60   PRINT "Ticket ";t
\   70 ENDPROC

\ --- words defined earlier in the guide

\ 04-procedures-and-subroutines.md:218
VARIABLE TICKETS
: TICKET  ( -- n )  1 TICKETS +!  TICKETS @ ;
TICKET . TICKET . TICKET .      \ => 1 2 3
0 TICKETS !
TICKET .                        \ => 1

\ --- the translation

\ 04-procedures-and-subroutines.md:358
0 TICKETS !
: .TICKET  ( -- )  ." Ticket " TICKET . ;
.TICKET                         \ => Ticket 1
.TICKET                         \ => Ticket 2
