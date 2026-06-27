\
\ LAYER0-GRAPHICS.f
\
\ Layer 0 - Standard Spectrum (ULA) mode.
\ 256 w x 192 h pixels, 8 colors total (2 intensities),
\ 32 x 24 cells, 2 colors per cell.
\
\ Load with:  NEEDS LAYER0-GRAPHICS
\ It pulls in GRAPHICS-COMMON and activates Layer 0 immediately.
\
.( LAYER0-GRAPHICS )

NEEDS GRAPHICS-COMMON

MARKER NO-LAYER0-GRAPHICS       \ unload only this mode (keeps GRAPHICS-COMMON)

\ NEEDS guard word for this module
: LAYER0-GRAPHICS
    NOOP
;

\ shared words extracted to inc/ (deduplicated via NEEDS)
NEEDS L0-PIXELADD
NEEDS L0-PIXELATT
NEEDS L0-POINT
NEEDS L0-PLOT
NEEDS L0-XPLOT
NEEDS .BORDER
NEEDS .PERM

BASE @

\ ____________________________________________________________________
\
\ Layer 0 INITIALIZE
: L0-INITIALIZE
    ATTR-COLORS
    ATTRIB     .INK
    BACKGROUND .PAPER
    BACKGROUND .BORDER
    .PERM                       \ make Layer 0 attribute choice permanent
;

\ ____________________________________________________________________
\
\ Build LAYER0 and activate it
HEX
    00  00          \ 00 char-size means no effect.
    1 7             \ Attribute masks
    0C0 100         \ V-RANGE and H-RANGE
    ' L0-PIXELADD   \ PIXELADD
    ' L0-POINT      \ POINT
    ' L0-PLOT       \ PLOT
    ' L0-XPLOT      \ XPLOT
    ' L0-PIXELATT   \ PIXELATT
    ' NOOP          \ XY-RATIO
    ' NOOP          \ EDGE
    ' L0-INITIALIZE \ INITIALIZE
    _BLUE           \ BACKGROUND
    _BLUE 3 LSHIFT _YELLOW +    \ ATTRIB (L0-ATTRIB)

LAYER: LAYER0

LAYER0

BASE !
