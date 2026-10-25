\ 17-01.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/17-01.txt
\ guide: doc/basic-to-vforth/17-time-and-motion.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 INPUT "A number: ";%N
\   20 TIME : ;Reset timer
\   30 PROC display()
\   40 PAUSE %N
\   50 PROC display()
\   60 STOP
\   70 ;
\   100 DEFPROC display()
\   110 T1,T2= DPEEK 23672, TIME
\   120 PRINT T1,T2
\   130 ENDPROC

\ --- words defined earlier in the guide

\ 17-time-and-motion.md:76
: RESET-TIMER  ( -- )  0 23672 !  0 23674 C! ;
: TIMER  ( -- u )  23672 @ ;
RESET-TIMER

\ --- the translation

\ 17-time-and-motion.md:266
: DISPLAY  ( -- )  CR  23672 @ .  TIMER . ;
