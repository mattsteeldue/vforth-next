\ 07-02.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/07-02.txt
\ guide: doc/basic-to-vforth/07-strings.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 LET n$="Spectrum"
\   20 LET g$="Hello, "+n$+"!"
\   30 PRINT g$
\   40 PRINT LEN g$

\ --- words defined earlier in the guide

\ 07-strings.md:26
NEEDS S"
: PLANET  ( -- a n )  S" Spectrum" ;
PLANET TYPE                     \ => Spectrum
PLANET NIP .                    \ => 8

\ 07-strings.md:102
CREATE NAME$  32 ALLOT

\ 07-strings.md:116
: $!  ( a n dest -- )  2DUP C!  1+ SWAP CMOVE ;
PLANET NAME$ $!
NAME$ COUNT TYPE                \ => Spectrum
NAME$ C@ .                      \ => 8

\ 07-strings.md:182
: $+!  ( a n dest -- )
    >R  DUP R@ C@ +  -ROT
    R@ COUNT + SWAP CMOVE
    R> C! ;
: SUFFIX  ( -- a n )  S"  Next" ;
SUFFIX NAME$ $+!
NAME$ COUNT TYPE                \ => Spectrum Next
NAME$ C@ .                      \ => 13

\ --- the translation

\ 07-strings.md:338
CREATE G$  40 ALLOT
: GREETING  ( a n -- )
    S" Hello, " G$ $!   G$ $+!   S" !" G$ $+! ;
PLANET GREETING
G$ COUNT TYPE                   \ => Hello, Spectrum!
G$ C@ .                         \ => 16
