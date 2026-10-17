\ 23-03.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/23-the-memory-03.txt
\ guide: doc/basic-to-vforth/23-the-memory.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 FOR a=23552 TO 23559
\   20   PRINT PEEK a;" ";
\   30 NEXT a

\ --- words defined earlier in the guide

\ 23-the-memory.md:35
CREATE BUF 16 ALLOT
300 BUF C!  BUF C@ .            \ => 44

\ 23-the-memory.md:83
CREATE BYTES  1 C, 2 C, 3 C,
BYTES BUF 3 CMOVE  BUF 2 + C@ . \ => 3

\ 23-the-memory.md:102
: PEEKS  ( a n -- )  BOUNDS DO  I C@ .  LOOP ;
BYTES 3 PEEKS                   \ => 1 2 3
NEEDS DUMP
BYTES 8 DUMP

\ --- the translation

\ 23-the-memory.md:282
23552 8 PEEKS
23552 8 DUMP
