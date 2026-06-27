\
\ LAYER10-GRAPHICS.f
\
\ Layer 1,0 - LoRes (Enhanced ULA) mode.
\ 128 w x 96 h pixels, 256 colors total, 1 colour per pixel.
\
\ Load with:  NEEDS LAYER10-GRAPHICS
\ It pulls in GRAPHICS-COMMON and activates Layer 1,0 immediately.
\
.( LAYER10-GRAPHICS )

NEEDS GRAPHICS-COMMON

MARKER NO-LAYER10-GRAPHICS      \ unload only this mode (keeps GRAPHICS-COMMON)

\ NEEDS guard word for this module
: LAYER10-GRAPHICS
    NOOP
;

BASE @

\ ____________________________________________________________________
\
\ Layer 1,0 PIXELADD
HEX
CODE L10-PIXELADD ( x y -- a )
    D9 C,               \ exx
    E1 C,               \ pop  hl|  \ horizontal y-coord, only L is significant
    D1 C,               \ pop  de|  \ vertical x-coord, only E is significant
    7B C,               \ ld   a'| e|
    D6 C, 30 C,         \ suba hex 30 n,
    30 C, 02 C,         \ jrf  nc'| +2 d,
    C6 C, 30 C,         \ adda hex 30 n,
    5F C,               \ ld e'| a|
    3E C, 0B C,         \ ldn  a'| hex 0B n,
    DE C, 00 C,         \ sbcn 0 n,
    ED C, 92 C, 57 C,   \ nextrega hex 57 p,
    CB C, 25 C,         \ sla   l|
    CB C, 3B C,         \ srl   e|
    CB C, 1D C,         \ rr    l|
    3E C, E0 C,         \ ldn  a'| hex E0 n,
    B3 C,               \ ora  e'|
    67 C,               \ ld   h'| a|
    E5 C,               \ push hl|
    D9 C,               \ exx
    DD C, E9 C,         \ next
    SMUDGE              \ c;

\ ____________________________________________________________________
\
\ Layer 1,0 POINT (per-pixel attribute)
: L1-POINT  ( x y -- c )
    PIXELADD C@
;

\ ____________________________________________________________________
\
\ Layer 1,0 EDGE rule
: L1-EDGE  ( b -- f )
    ATTRIB =
;

\ ____________________________________________________________________
\
\ Layer 1,0 PLOT
\ COORD-CHECK and PIXELADD are vectorized via DEFER..IS
: L1-PLOT  ( x y -- )
    COORD-CHECK
    IF
        PIXELADD
        ATTRIB SWAP C!
    ELSE
        2DROP
    THEN
;

\ ____________________________________________________________________
\
\ Layer 1,0 XPLOT
\ COORD-CHECK and PIXELADD are vectorized via DEFER..IS
DECIMAL
: L1-XPLOT  ( x y -- )
    COORD-CHECK
    IF
        PIXELADD
        DUP C@ 255 XOR SWAP C!
    ELSE
        2DROP
    THEN
;

\ ____________________________________________________________________
\
\ Build LAYER10 and activate it
\ PIXELATT has no meaning for Layer 1,0 -> 2DROP
HEX
    04  10          \ 04 char-size to allow 64 chars per row
    1 0FF           \ Attribute masks
    60  80          \ V-RANGE and H-RANGE
    ' L10-PIXELADD  \ PIXELADD
    ' L1-POINT      \ POINT
    ' L1-PLOT       \ PLOT
    ' L1-XPLOT      \ XPLOT
    ' 2DROP         \ PIXELATT  (has no meaning for Layer 1,0)
    ' NOOP          \ XY-RATIO
    ' L1-EDGE       \ EDGE
    _WHITE 3 LSHIFT _BLACK +    \ ATTRIB (L10-ATTRIB)

LAYER: LAYER10

LAYER10

BASE !
