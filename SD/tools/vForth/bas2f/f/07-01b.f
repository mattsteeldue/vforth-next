\ 07-01b.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/07-strings-01.txt
\ guide: doc/basic-to-vforth/07-strings.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 LET a$="Spectrum"
\   20 FOR n=1 TO LEN a$
\   30   PRINT a$( TO n)
\   40 NEXT n

\ --- words defined earlier in the guide

\ 07-strings.md:26
NEEDS S"
: PLANET  ( -- a n )  S" Spectrum" ;
PLANET TYPE                     \ => Spectrum
PLANET NIP .                    \ => 8

\ 07-strings.md:93
: /STRING  ( a n k -- a2 n2 )  ROT OVER + -ROT - ;
PLANET 2 /STRING TYPE           \ => ectrum
PLANET 3 MIN TYPE               \ => Spe

\ --- the translation

\ 07-strings.md:260
: TAILS  ( a n -- )
    BEGIN  DUP WHILE
        CR 2DUP TYPE  1 /STRING
    REPEAT  2DROP ;
PLANET TAILS
\ output of the last line:
\ Spectrum
\ pectrum
\ ectrum
\ ctrum
\ trum
\ rum
\ um
\ m
