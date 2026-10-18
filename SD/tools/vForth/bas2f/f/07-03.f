\ 07-03.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/07-03.txt
\ guide: doc/basic-to-vforth/07-strings.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 LET c$="1234567890123456"
\   20 LET c$( TO 12)="************"
\   30 PRINT c$

\ --- words defined earlier in the guide

\ 07-strings.md:26
NEEDS S"
: PLANET  ( -- a n )  S" Spectrum" ;
PLANET TYPE                     \ => Spectrum
PLANET NIP .                    \ => 8

\ 07-strings.md:89
CREATE NAME$  32 ALLOT

\ 07-strings.md:103
: $!  ( a n dest -- )  2DUP C!  1+ SWAP CMOVE ;
PLANET NAME$ $!
NAME$ COUNT TYPE                \ => Spectrum
NAME$ C@ .                      \ => 8

\ --- the translation

\ 07-strings.md:352
CREATE CARD$  20 ALLOT
: CARD  ( -- a n )  S" 1234567890123456" ;
CARD CARD$ $!
CARD$ 1+ 12 42 FILL
CARD$ COUNT TYPE                \ => ************3456
