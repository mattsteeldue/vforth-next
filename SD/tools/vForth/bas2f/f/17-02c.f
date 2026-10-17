\ 17-02c.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/17-time-and-motion-02.txt
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

\ --- the translation

\ 17-time-and-motion.md:324
: ROW!  ( n1 ... n16 a -- )
    15 +  16 0 DO  SWAP OVER C!  1-  LOOP  DROP ;
: ROW,  ( n1 ... n16 -- )  HERE ROW!  16 ALLOT ;
CREATE PROBE  1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 ROW,
PROBE C@ .  PROBE 15 + C@ .     \ => 1 16
