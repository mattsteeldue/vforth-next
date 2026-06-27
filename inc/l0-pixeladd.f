\
\ l0-pixeladd.f
\
\ Display File pixel address for Layer 0 / Layer 1,1 / Layer 1,3.
\ This word exploits the new "pixelad" Z80-N op-code.
\
.( L0-PIXELADD )

BASE @
HEX
CODE L0-PIXELADD   ( x y -- a )
    D9 C,           \ exx
    D1 C,           \ pop   de  ; y
    E1 C,           \ pop   hl  ; x
    55 C,           \ ld    d,l ; de is vert,horiz
    ED C, 94 C,     \ pixelad
    E5 C,           \ push  hl
    D9 C,           \ exx
    DD C, E9 C,     \ jp   (ix)
    SMUDGE
BASE !

