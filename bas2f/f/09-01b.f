\ 09-01b.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/09-01.txt
\ guide: doc/basic-to-vforth/09-mathematical-functions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 PRINT 2^10

\ --- the translation

\ 09-mathematical-functions.md:179
: **  ( n u -- n^u )  1 SWAP 0 ?DO  OVER *  LOOP  NIP ;
2 10 ** .                       \ => 1024
3 4 ** .                        \ => 81
7 0 ** .                        \ => 1
2 16 ** .                       \ => 0
