\
\ l0-set.f
\
\ pixel operator: OR a pattern byte onto a screen byte (used to "set" pixels)
\
.( L0-SET )

BASE @
HEX
CODE L0-SET   ( b1 b2 -- b3 )
    E1 C,               \ pop   hl    ; b2 byte
    7D C,               \ ld   a'| l|
    E1 C,               \ pop   hl    ; b1 pattern
    B5 C,               \ ora  l'|
    6F C,               \ ld   l'| a|
    E5 C,               \ push  hl
    DD C, E9 C,         \ jp   (ix)
    SMUDGE
BASE !

