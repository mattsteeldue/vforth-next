\ 18-01.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/18-01.txt
\ guide: doc/basic-to-vforth/18-sound-and-music.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 FOR n=1 TO 8
\   20   READ p: BEEP .25,p
\   30 NEXT n
\   40 DATA 0,2,4,5,7,9,11,12

\ --- the translation

\ 18-sound-and-music.md:248
CREATE SCALE  0 C, 2 C, 4 C, 5 C, 7 C, 9 C, 11 C, 12 C,
: MAJOR  ( -- )  8 0 DO  250  SCALE I + C@  BEEP  LOOP ;
