\ 18-04b.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/18-sound-and-music-04.txt
\ guide: doc/basic-to-vforth/18-sound-and-music.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 PLAY "UX1000W0c"

\ --- words defined earlier in the guide

\ 18-sound-and-music.md:150
NEEDS AY
NEEDS MS
: PERIOD  ( hz -- p )  16 * >R  1750000. R> UM/MOD NIP ;
440 PERIOD .                    \ => 248

\ --- the translation

\ 18-sound-and-music.md:325
: PLUCK  ( -- )
    1 AYSELECT
    262 PERIOD 0 AY!!
    1000 11 AY!!                \ X1000: the envelope period
    16 8 AY!                    \ U: channel A follows the envelope
    %00111110 7 AY!             \ M1: tone on A only
    0 13 AY! ;                  \ W0: decay, then silence
PLUCK
