\ 07-04.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/07-strings-04.txt
\ guide: doc/basic-to-vforth/07-strings.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 LET a$="   hello there   "
\   20 PRINT a$[<>+];"."

\ --- words defined earlier in the guide

\ 07-strings.md:26
NEEDS S"
: PLANET  ( -- a n )  S" Spectrum" ;
PLANET TYPE                     \ => Spectrum
PLANET NIP .                    \ => 8

\ 07-strings.md:54
CREATE NAME$  32 ALLOT

\ 07-strings.md:68
: $!  ( a n dest -- )  2DUP C!  1+ SWAP CMOVE ;
PLANET NAME$ $!
NAME$ COUNT TYPE                \ => Spectrum
NAME$ C@ .                      \ => 8

\ 07-strings.md:93
: /STRING  ( a n k -- a2 n2 )  ROT OVER + -ROT - ;
PLANET 2 /STRING TYPE           \ => ectrum
PLANET 3 MIN TYPE               \ => Spe

\ --- the translation

\ 07-strings.md:333
: -LEADING  ( a n -- a2 n2 )
    BEGIN
        DUP IF  OVER C@ BL =  ELSE  0  THEN
    WHILE  1 /STRING  REPEAT ;
: UPCASE  ( a n -- )
    BOUNDS ?DO  I C@ UPPER I C!  LOOP ;
: UNTIDY  ( -- a n )  S"    hello there   " ;
: TIDY  ( a n -- )
    -LEADING -TRAILING  NAME$ $!
    NAME$ COUNT UPCASE ;
UNTIDY NIP .                    \ => 17
UNTIDY TIDY
NAME$ COUNT TYPE                \ => HELLO THERE
NAME$ C@ .                      \ => 11
