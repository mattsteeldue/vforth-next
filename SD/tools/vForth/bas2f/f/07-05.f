\ 07-05.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/07-strings-05.txt
\ guide: doc/basic-to-vforth/07-strings.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 PRINT "ab"*3
\   20 PRINT "Spectrum"*-1

\ --- words defined earlier in the guide

\ 07-strings.md:26
NEEDS S"
: PLANET  ( -- a n )  S" Spectrum" ;
PLANET TYPE                     \ => Spectrum
PLANET NIP .                    \ => 8

\ --- the translation

\ 07-strings.md:375
: TIMES  ( a n k -- )
    0 ?DO  2DUP TYPE  LOOP  2DROP ;
: AB  ( -- a n )  S" ab" ;
AB 3 TIMES                      \ => ababab
: BACKWARDS  ( a n -- )
    DUP 0 ?DO  1- 2DUP + C@ EMIT  LOOP  2DROP ;
PLANET BACKWARDS                \ => murtcepS
