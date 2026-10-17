\ 14-03.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/14-more-about-print-and-input-03.txt
\ guide: doc/basic-to-vforth/14-more-about-print-and-input.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 PAUSE 0: LET k$=INKEY$
\   20 IF k$=CHR$ 13 THEN STOP
\   30 PRINT k$;: GO TO 10

\ --- the translation

\ 14-more-about-print-and-input.md:276
\ no-test in the guide: it waits for keys, never ends or
\ needs hardware the emulator lacks
: TYPEWRITER  ( -- )
    BEGIN  KEY DUP 13 <>  WHILE  EMIT  REPEAT  DROP ;
