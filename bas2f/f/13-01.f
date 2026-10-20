\ 13-01.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/13-01.txt
\ guide: doc/basic-to-vforth/13-the-character-set.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 FOR a=65 TO 90: PRINT CHR$ a;: NEXT a
\   20 PRINT
\   30 FOR a=32 TO 126: PRINT CHR$ a;: NEXT a

\ --- the translation

\ 13-the-character-set.md:240
: CAPITALS  ( -- )  [CHAR] Z 1+ [CHAR] A DO  I EMIT  LOOP ;
CAPITALS                        \ => ABCDEFGHIJKLMNOPQRSTUVWXYZ
: CHARSET  ( -- )  127 32 DO  I EMIT  LOOP ;
CHARSET
