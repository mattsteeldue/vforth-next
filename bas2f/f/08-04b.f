\ 08-04b.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/08-04.txt
\ guide: doc/basic-to-vforth/08-functions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 LET a$="ZX Spectrum Next"
\   20 PRINT IN (a$," ")
\   30 PRINT IN (a$,"N")
\   40 PRINT IN (a$,"q")

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

\ 08-functions.md:384
NEEDS SEARCH
: POS$  ( a u a2 u2 -- n )
    2OVER NIP >R  SEARCH
    IF  NIP R> SWAP - 1+  ELSE  2DROP R> DROP 0  THEN ;
: BRAND  ( -- a u )  S" Spectrum" ;
: QUERY$  ( -- a u )  S" next" ;
MACHINE BRAND POS$ .            \ => 4
MACHINE QUERY$ POS$ .           \ => 13
QUERY$ MACHINE POS$ .           \ => 0
