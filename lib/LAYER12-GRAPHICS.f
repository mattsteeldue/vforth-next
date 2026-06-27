\
\ LAYER12-GRAPHICS.f
\
\ Layer 1,2 - Timex HiRes (Enhanced ULA) mode.
\ 512 w x 192 h pixels, 256 colors total,
\ only 2 colors on whole screen.
\
\ Load with:  NEEDS LAYER12-GRAPHICS
\ It pulls in GRAPHICS-COMMON and activates Layer 1,2 immediately.
\
.( LAYER12-GRAPHICS )

NEEDS GRAPHICS-COMMON

MARKER NO-LAYER12-GRAPHICS      \ unload only this mode (keeps GRAPHICS-COMMON)

\ NEEDS guard word for this module
: LAYER12-GRAPHICS
    NOOP
;

\ shared words extracted to inc/ (deduplicated via NEEDS)
NEEDS L0-POINT
NEEDS L0-PLOT
NEEDS L0-XPLOT

BASE @

\ ____________________________________________________________________

: L12-INITIALIZE
    ATTR-COLORS
    BACKGROUND .PAPER
;

\ ____________________________________________________________________
\
\ Layer 1,2 PIXELADD
\ fit the correct 8k page on MMU7 and leaves the address from $E000
HEX
CODE L12-PIXELADD   ( x y -- a )
    D9 C,               \ exx
    D1 C,               \ pop   de      ; y
    E1 C,               \ pop   hl      ; x
    CB C, 3A C,         \ srl   d
    CB C, 1B C,         \ rr    e       ; half y
    7B C,               \ ld   a'| e|
    0F C,               \ rrca
    0F C,               \ rrca
    0F C,               \ rrca          ; carry has bit 3
    3E C, 0A C,         \ ldn  a'| hex 0A n,
    CE C, 00 C,         \ adcn 0 n,
    ED C, 92 C, 57 C,   \ nextrega hex 57 p,
    55 C,               \ ld    d,l     ; de is vert,horiz
    ED C, 94 C,         \ pixelad
    3E C, E0 C,         \ ldn  a'| hex E0 n,
    B4 C,               \ ora  h|
    67 C,               \ ld   h'| a|
    E5 C,               \ push  hl
    D9 C,               \ exx
    DD C, E9 C,         \ jp   (ix)
    SMUDGE

\ ____________________________________________________________________
\
\ Build LAYER12 and activate it
\ PIXELATT has no meaning for Layer 1,2 -> 2DROP
\ XY-RATIO halves the horizontal coordinate -> 2/
HEX
    08  12          \ 08 char-size is normal 64 chars per row
    1 7             \ Attribute masks
    0C0 200         \ V-RANGE and H-RANGE
    ' L12-PIXELADD  \ PIXELADD
    ' L0-POINT      \ POINT
    ' L0-PLOT       \ PLOT
    ' L0-XPLOT      \ XPLOT
    ' 2DROP         \ PIXELATT  (has no meaning on Layer 1,2)
    ' 2/            \ XY-RATIO
    ' NOOP          \ EDGE
    ' L12-INITIALIZE \ INITIALIZE
    _BLUE           \ BACKGROUND
    00              \ ATTRIB (L12-ATTRIB)

LAYER: LAYER12

LAYER12

BASE !
