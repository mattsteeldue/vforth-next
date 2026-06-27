\
\ l0-xor.f
\
\ pixel operator: XOR a pattern byte onto a screen byte (used to "xor" pixels)
\
.( L0-XOR )

BASE @
HEX
CODE L0-XOR   ( b1 b2 -- b3 )
    E1 C,               \ pop   hl    ; byte
    7D C,               \ ld   a'| l|
    E1 C,               \ pop   hl    ; pattern
    AD C,               \ xora l'|
    6F C,               \ ld   l'| a|
    E5 C,               \ push  hl
    DD C, E9 C,         \ jp   (ix)
    SMUDGE
BASE !

