\ 13-02.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/13-the-character-set-02.txt
\ guide: doc/basic-to-vforth/13-the-character-set.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 FOR n=0 TO 15
\   20   READ r: POKE USR "a"+n,r
\   30 NEXT n
\   40 PRINT CHR$ 144;CHR$ 145
\   50 DATA 0,108,254,254,124,56,16,0
\   60 DATA 16,56,124,254,124,56,16,0

\ --- the translation

\ 13-the-character-set.md:93
23675 @ CONSTANT BASIC-UDG
CREATE SHAPES
  %00000000 C, %01101100 C, %11111110 C, %11111110 C,
  %01111100 C, %00111000 C, %00010000 C, %00000000 C,
  %00010000 C, %00111000 C, %01111100 C, %11111110 C,
  %01111100 C, %00111000 C, %00010000 C, %00000000 C,
SHAPES 23675 !
144 EMITC 145 EMITC
