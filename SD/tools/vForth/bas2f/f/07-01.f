\ 07-01.f -- the Forth side of a NextBASIC listing
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

\ --- the translation

\ 07-strings.md:237
: TRIANGLE  ( a n -- )
    1+ 1 DO  DUP I CR TYPE  LOOP  DROP ;
PLANET TRIANGLE
\ output of the last line:
\ S
\ Sp
\ Spe
\ Spec
\ Spect
\ Spectr
\ Spectru
\ Spectrum
