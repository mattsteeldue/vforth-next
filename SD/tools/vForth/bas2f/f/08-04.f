\ 08-04.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/08-04.txt
\ guide: doc/basic-to-vforth/08-functions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 LET a$="ZX Spectrum Next"
\   20 PRINT IN (a$," ")
\   30 PRINT IN (a$,"N")
\   40 PRINT IN (a$,"q")

\ --- the translation

\ 08-functions.md:361
NEEDS SCAN
: POS  ( a u c -- n )
    >R TUCK R> SCAN NIP
    DUP IF  - 1+  ELSE  NIP  THEN ;
: MACHINE  ( -- a u )  S" ZX Spectrum Next" ;
MACHINE BL POS .                \ => 3
MACHINE CHAR N POS .            \ => 13
MACHINE CHAR q POS .            \ => 0
