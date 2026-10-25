\ 13-01.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/13-01.txt
\ guide: doc/basic-to-vforth/13-the-character-set.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 FOR a=65 TO 90: PRINT CHR$ a;: NEXT a
\   20 PRINT
\   30 FOR a=32 TO 127: PRINT CHR$ a;: NEXT a

\ --- the translation

\ 13-the-character-set.md:257
: CAPITALS  ( -- )  [CHAR] Z 1+ [CHAR] A DO  I EMIT  LOOP ;
CAPITALS                        \ => ABCDEFGHIJKLMNOPQRSTUVWXYZ
: SMALLS  ( -- )  [CHAR] z 1+ [CHAR] a DO  I EMIT  LOOP ;
SMALLS                          \ => abcdefghijklmnopqrstuvwxyz
CHAR Z . CHAR z .               \ => 90 122
: CHARSET  ( -- )  128 32 DO  I EMIT  LOOP ;
CHARSET
