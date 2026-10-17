\ 08-04.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/08-functions-04.txt
\ guide: doc/basic-to-vforth/08-functions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 LET a$="ZX Spectrum Next"
\   20 PRINT IN (a$," ")
\   30 PRINT IN (a$,"N")
\   40 PRINT IN (a$,"q")

\ --- the translation

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
