\ 14-04.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/14-04.txt
\ guide: doc/basic-to-vforth/14-more-about-print-and-input.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   5 POKE 23692,-1
\   10 FOR n=1 TO 100
\   20   PRINT n
\   30   IF n/20=INT (n/20) THEN PRINT "Press a key": PAUSE 0
\   40 NEXT n

\ --- the translation

\ 14-more-about-print-and-input.md:296
\ no-test in the guide: it waits for keys, never ends or
\ needs hardware the emulator lacks
: LISTING  ( -- )
    101 1 DO
        I . CR
        I 20 MOD 0= IF  ." Press a key"  KEY DROP CR  THEN
    LOOP ;
