\ 17-03b.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/17-time-and-motion-03.txt
\ guide: doc/basic-to-vforth/17-time-and-motion.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 SPRITE PRINT 1
\   20 FOR %x=32 TO 288 STEP 2
\   30 SPRITE 0,%x,128,%x/8&1,1
\   40 PAUSE 2
\   50 NEXT %x
\   60 SPRITE 0,0,0,0,0

\ --- the translation

\ 17-time-and-motion.md:446
\ no-test in the guide: it waits for keys, never ends or
\ needs hardware the emulator lacks
: MOVE-ALL  ( -- )
    1FRAME
    SPRITE 0 SPRITE-UPDATE  \ ... one per sprite
    ;
