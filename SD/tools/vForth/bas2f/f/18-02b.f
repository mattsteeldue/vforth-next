\ 18-02b.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/18-02.txt
\ guide: doc/basic-to-vforth/18-sound-and-music.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 LET k=0: LET c=.4
\   20 FOR r=1 TO 2
\   30   BEEP c,k: BEEP c,k: BEEP c,k+7: BEEP c,k+7
\   40   BEEP c,k+9: BEEP c,k+9: BEEP 2*c,k+7
\   50 NEXT r

\ --- words defined earlier in the guide

\ 18-sound-and-music.md:93
NEEDS VALUE
0 VALUE KEY#
400 VALUE CROTCHET
: Q  ( pitch -- )  CROTCHET  SWAP KEY# +  BEEP ;
: H  ( pitch -- )  CROTCHET 2*  SWAP KEY# +  BEEP ;

\ 18-sound-and-music.md:267
: TWINKLE  ( -- )  0 Q 0 Q 7 Q 7 Q 9 Q 9 Q 7 H ;
: TUNE  ( -- )  2 0 DO  TWINKLE  LOOP ;

\ --- the translation

\ 18-sound-and-music.md:276
\ no-test in the guide: it waits for keys, never ends or
\ needs hardware the emulator lacks
2 TO KEY#  300 TO CROTCHET  TUNE
