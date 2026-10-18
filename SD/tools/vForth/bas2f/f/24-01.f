\ 24-01.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/24-01.txt
\ guide: doc/basic-to-vforth/24-the-system-variables.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 POKE 23561,15: POKE 23562,2
\   20 INPUT "Hold a key: ";a$
\   30 POKE 23561,35: POKE 23562,5

\ --- the translation

\ 24-the-system-variables.md:129
: FAST-KEYS  ( -- )  15 23561 C!  2 23562 C! ;
: SLOW-KEYS  ( -- )  35 23561 C!  5 23562 C! ;
FAST-KEYS  23561 C@ .           \ => 15
SLOW-KEYS
