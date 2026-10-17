\ 04-02.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/04-procedures-and-subroutines-02.txt
\ guide: doc/basic-to-vforth/04-procedures-and-subroutines.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 PROC rect(3,4) TO a,p
\   20 PRINT a;" ";p
\   30 STOP
\   40 DEFPROC rect(w,h)
\   50 ENDPROC =w*h,2*(w+h)

\ --- words defined earlier in the guide

\ 04-procedures-and-subroutines.md:191
: RECT  ( w h -- area perimeter )  { W H -- SURFACE PERIM }
    W H *  TO SURFACE
    W H + 2*  TO PERIM ;
3 4 RECT . .                    \ => 14 12

\ --- the translation

\ 04-procedures-and-subroutines.md:334
VARIABLE SIZE
VARIABLE EDGE
3 4 RECT  EDGE !  SIZE !
SIZE ? EDGE ?                   \ => 12 14
