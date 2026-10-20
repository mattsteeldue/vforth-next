\ 08-05.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/08-05.txt
\ guide: doc/basic-to-vforth/08-functions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 DEF FN l$(a$,n)=a$( TO n)
\   20 DEF FN t$(a$)=a$(2 TO )
\   30 PRINT FN l$("ZX Spectrum Next",4)
\   40 PRINT FN t$("ZX Spectrum Next")

\ --- words defined earlier in the guide

\ 08-functions.md:361
NEEDS SCAN
: POS  ( a u c -- n )
    >R TUCK R> SCAN NIP
    DUP IF  - 1+  ELSE  NIP  THEN ;
: MACHINE  ( -- a u )  S" ZX Spectrum Next" ;
MACHINE BL POS .                \ => 3
MACHINE CHAR N POS .            \ => 13
MACHINE CHAR q POS .            \ => 0

\ --- the translation

\ 08-functions.md:411
NEEDS /STRING
: LEFT$   ( a u n -- a u2 )   MIN ;
: RIGHT$  ( a u n -- a2 u2 )  OVER MIN >R  + R@ -  R> ;
: MID$    ( a u from n -- a2 u2 )  >R 1- /STRING R> MIN ;
: TL$     ( a u -- a2 u2 )    DUP IF  1 /STRING  THEN ;
MACHINE 4 LEFT$ TYPE            \ => ZX S
MACHINE 4 RIGHT$ TYPE           \ => Next
MACHINE 4 8 MID$ TYPE           \ => Spectrum
MACHINE TL$ TYPE                \ => X Spectrum Next
MACHINE 99 RIGHT$ TYPE          \ => ZX Spectrum Next
