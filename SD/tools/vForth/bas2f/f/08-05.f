\ 08-05.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/08-functions-05.txt
\ guide: doc/basic-to-vforth/08-functions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 DEF FN l$(a$,n)=a$( TO n)
\   20 DEF FN t$(a$)=a$(2 TO )
\   30 PRINT FN l$("ZX Spectrum Next",4)
\   40 PRINT FN t$("ZX Spectrum Next")

\ --- words defined earlier in the guide

\ 08-functions.md:358
: /STRING  ( a u k -- a2 u2 )  ROT OVER + -ROT - ;
: POS  ( a u c -- n )
    >R  OVER SWAP
    BEGIN  DUP WHILE
        OVER C@ R@ = IF
            DROP SWAP - 1+  R> DROP EXIT
        THEN
        1 /STRING
    REPEAT
    R> DROP  2DROP DROP 0 ;
: MACHINE  ( -- a u )  S" ZX Spectrum Next" ;
MACHINE BL POS .                \ => 3
MACHINE CHAR N POS .            \ => 13
MACHINE CHAR q POS .            \ => 0

\ --- the translation

\ 08-functions.md:392
: LEFT$   ( a u n -- a u2 )   MIN ;
: RIGHT$  ( a u n -- a2 u2 )  OVER MIN >R  + R@ -  R> ;
: MID$    ( a u from n -- a2 u2 )  >R 1- /STRING R> MIN ;
: TL$     ( a u -- a2 u2 )    DUP IF  1 /STRING  THEN ;
MACHINE 4 LEFT$ TYPE            \ => ZX S
MACHINE 4 RIGHT$ TYPE           \ => Next
MACHINE 4 8 MID$ TYPE           \ => Spectrum
MACHINE TL$ TYPE                \ => X Spectrum Next
MACHINE 99 RIGHT$ TYPE          \ => ZX Spectrum Next
