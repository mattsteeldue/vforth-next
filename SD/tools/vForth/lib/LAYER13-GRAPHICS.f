\
\ LAYER13-GRAPHICS.f
\
\ Layer 1,3 - Timex HiColour (Enhanced ULA) mode.
\ 256 w x 192 h pixels, 256 colors total,
\ 32 x 192 cells, 2 colors per cell.
\
\ Load with:  NEEDS LAYER13-GRAPHICS
\ It pulls in GRAPHICS-COMMON and activates Layer 1,3 immediately.
\
.( LAYER13-GRAPHICS )

NEEDS GRAPHICS-COMMON

MARKER NO-LAYER13-GRAPHICS      \ unload only this mode (keeps GRAPHICS-COMMON)

\ NEEDS guard word for this module
: LAYER13-GRAPHICS
    NOOP
;

\ shared words extracted to inc/ (deduplicated via NEEDS)
NEEDS L0-PIXELADD
NEEDS L0-POINT
NEEDS L0-PLOT
NEEDS L0-XPLOT
NEEDS .BORDER

BASE @

\ ____________________________________________________________________
\
\ Layer 1,3 INITIALIZE
: L13-INITIALIZE
    ATTR-COLORS
    ATTRIB     .INK
    BACKGROUND .PAPER
    BACKGROUND .BORDER
;

\ ____________________________________________________________________
\
\ Layer 1,3 PIXELATT
\ convert Display File address into Attribute address
\ it fits the correct 8k page on MMU7 and leaves the address from $E000
HEX
: L13-PIXELATT   ( b a -- )
    0B MMU7!
    E000 OR C!
;

\ ____________________________________________________________________
\
\ Build LAYER13 and activate it
HEX
    04  13          \ 04 char-size to allow 64 chars per row
    1 7             \ Attribute masks
    0C0 100         \ V-RANGE and H-RANGE
    ' L0-PIXELADD   \ PIXELADD
    ' L0-POINT      \ POINT
    ' L0-PLOT       \ PLOT
    ' L0-XPLOT      \ XPLOT
    ' L13-PIXELATT  \ PIXELATT
    ' NOOP          \ XY-RATIO
    ' NOOP          \ EDGE
    ' L13-INITIALIZE \ INITIALIZE
    _BLUE           \ BACKGROUND
    _BLUE 3 LSHIFT _YELLOW +    \ ATTRIB (L13-ATTRIB)

LAYER: LAYER13

LAYER13

BASE !
