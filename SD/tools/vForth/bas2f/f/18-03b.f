\ 18-03b.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/18-sound-and-music-03.txt
\ guide: doc/basic-to-vforth/18-sound-and-music.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 PLAY "c","e","g"

\ --- words defined earlier in the guide

\ 18-sound-and-music.md:150
NEEDS AY
NEEDS MS
: PERIOD  ( hz -- p )  16 * >R  1750000. R> UM/MOD NIP ;
440 PERIOD .                    \ => 248

\ --- the translation

\ 18-sound-and-music.md:295
: CHORD  ( -- )
    1 AYSELECT
    262 PERIOD 0 AY!!  330 PERIOD 2 AY!!  392 PERIOD 4 AY!!
    15 8 AY!  15 9 AY!  15 10 AY!
    %00111000 7 AY!
    500 MS  SHH ;
CHORD
