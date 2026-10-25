\ 17-02.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/17-02.txt
\ guide: doc/basic-to-vforth/17-time-and-motion.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 T$= TIME $
\   20 PRINT 't$
\   30 PROC now() TO h,m,s
\   40 PRINT "It's ";h;":";m
\   90 STOP
\   100 DEFPROC Now()
\   110 T$= TIME $
\   120 PRINT 't$
\   130 hh= VAL (T$(12)+T$(13))
\   140 mi= VAL (T$(15)+T$(16))
\   150 ss= VAL (T$(18)+T$(19))
\   160 ENDPROC =hh,mi,ss

\ --- words defined earlier in the guide

\ 17-time-and-motion.md:104
: HOURS    ( time -- h )  11 RSHIFT ;
: MINUTES  ( time -- m )  5 RSHIFT 63 AND ;
: SECONDS  ( time -- s )  31 AND 2* ;
34544 DUP HOURS .  DUP MINUTES .  SECONDS .   \ => 16 55 32

\ --- the translation

\ 17-time-and-motion.md:303
NEEDS IDE_RTC
: NOW  ( -- h m s )
    IDE_RTC DROP NIP
    DUP HOURS  OVER MINUTES  ROT SECONDS ;
