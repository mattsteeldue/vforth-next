\ 17-04.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/17-04.txt
\ guide: doc/basic-to-vforth/17-time-and-motion.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 LAYER 1,1: CLS: PRINT AT 10,10;"EARTHQUAKE!"
\   20 FOR %n=1 TO 50
\   30 LAYER AT %RND 8,%RND 8
\   40 PAUSE 1
\   50 NEXT %n
\   60 LAYER AT 0,0: LAYER 0

\ --- the translation

\ 17-time-and-motion.md:536
NEEDS RND
: QUAKE  ( -- )
    50 0 DO  8 RND $26 REG!  8 RND $27 REG!  1FRAME  LOOP
    0 $26 REG!  0 $27 REG! ;
QUAKE  $26 REG@ .  $27 REG@ .   \ => 0 0
