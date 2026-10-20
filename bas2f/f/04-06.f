\ 04-06.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/04-06.txt
\ guide: doc/basic-to-vforth/04-procedures-and-subroutines.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 PROC total("Sum: ",4,8,15,16)
\   20 STOP
\   30 DEFPROC total(t$,DATA)
\   40   LOCAL n
\   50   LOCAL s=0
\   60   REPEAT: WHILE DATA
\   70     READ n: s+=n
\   80   REPEAT UNTIL 0
\   90   PRINT t$;s
\   100 ENDPROC

\ --- the translation

\ 04-procedures-and-subroutines.md:465
: TOTAL  ( n1 .. nk k -- sum )
    0 SWAP  0 ?DO  +  LOOP ;
4 8 15 16  4 TOTAL .            \ => 43
0 TOTAL .                       \ => 0
