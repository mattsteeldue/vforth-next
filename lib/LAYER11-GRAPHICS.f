\
\ LAYER11-GRAPHICS.f
\
\ Layer 1,1 - Standard Res (Enhanced ULA) mode.
\ 256 w x 192 h pixels, 256 colors total,
\ 32 x 24 cells, 2 colors per cell.
\
\ Load with:  NEEDS LAYER11-GRAPHICS
\ It pulls in GRAPHICS-COMMON and activates Layer 1,1 immediately.
\
.( LAYER11-GRAPHICS )

NEEDS GRAPHICS-COMMON

MARKER NO-LAYER11-GRAPHICS      \ unload only this mode (keeps GRAPHICS-COMMON)

\ NEEDS guard word for this module
: LAYER11-GRAPHICS
    NOOP
;

\ shared words extracted to inc/ (deduplicated via NEEDS)
NEEDS L0-PIXELADD
NEEDS L0-PIXELATT
NEEDS L0-POINT
NEEDS L0-PLOT
NEEDS L0-XPLOT
NEEDS .BORDER

BASE @

\ ____________________________________________________________________
\
\ Layer 1,1 INITIALIZE
: L11-INITIALIZE
    ATTR-COLORS
    ATTRIB     .INK
    BACKGROUND .PAPER
    BACKGROUND .BORDER
;

\ ____________________________________________________________________
\
\ Build LAYER11 and activate it
HEX
    04  11          \ 04 char-size to allow 64 chars per row
    1 7             \ Attribute masks
    0C0 100         \ V-RANGE and H-RANGE
    ' L0-PIXELADD   \ PIXELADD
    ' L0-POINT      \ POINT
    ' L0-PLOT       \ PLOT
    ' L0-XPLOT      \ XPLOT
    ' L0-PIXELATT   \ PIXELATT
    ' NOOP          \ XY-RATIO
    ' NOOP          \ EDGE
    ' L11-INITIALIZE \ INITIALIZE
    _BLUE           \ BACKGROUND
    _BLUE 3 LSHIFT _YELLOW +    \ ATTRIB (L11-ATTRIB)

LAYER: LAYER11

LAYER11

BASE !
