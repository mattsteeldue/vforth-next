\
\ LAYER22-GRAPHICS.f
\
\ Layer 2 high resolution - 320 w x 256 h pixels, 256 colors total,
\ one colour per pixel.  Uses 80K of RAM (five 16K banks = ten 8K MMU7
\ pages) laid out in VERTICAL bands of 32 columns each, as opposed to
\ the horizontal layout of the 256x192 Layer 2 mode.
\
\ Load with:  NEEDS LAYER22-GRAPHICS
\ It pulls in GRAPHICS-COMMON and activates Layer 2 320x256 immediately.
\
\ N.B. the coordinate convention is preserved:  x = vertical (0..255),
\      y = horizontal (0..319).  PLOT/POINT/... take ( x y ).
\
\ WARNING: this mode assumes the five 16K banks starting at the Layer 2
\ active bank (NextReg $12) are reserved for the framebuffer.  NextZXOS
\ allocates only three banks (48K) for the standard 256x192 Layer 2, so
\ the two extra banks must be free.  Validate on real hardware / CSpect
\ before relying on it.
\
.( LAYER22-GRAPHICS )

NEEDS GRAPHICS-COMMON

MARKER NO-LAYER22-GRAPHICS      \ unload only this mode (keeps GRAPHICS-COMMON)

\ NEEDS guard word for this module
: LAYER22-GRAPHICS
    NOOP
;

\ shared words extracted to inc/ (deduplicated via NEEDS)
NEEDS L1-POINT
NEEDS L1-PLOT
NEEDS L1-XPLOT
NEEDS L1-EDGE
NEEDS L2-RAM-PAGE
NEEDS MMU7@
NEEDS .BORDER

BASE @

\ ____________________________________________________________________
\
\ Layer 2 320x256 PIXELADD
\ Vertical-band layout: page = y >> 5 (one 8K page per 32-column band),
\ address = $E000 + (y & 31)*256 + x.  x is the vertical coordinate
\ (low byte L), y the horizontal one (0..319, full DE).
\ The high bits of y land on bits already set in $E0, so no masking of
\ the low byte is needed before OR-ing it into H.
HEX
CODE L22-PIXELADD  ( x y -- a )
    D9 C,             \ exx
    D1 C,             \ pop  de     \ horizontal y-coord (lsb of D and E significant)
    E1 C,             \ pop  hl     \ vertical   x-coord (only L significant)
    4B C,             \ ld   c, e   \ keep low byte of y
    06 C, 05 C,       \ ld   b, 5
    ED C, 2A C,       \ bsrl de, b  \ e = y >> 5 = which 8K page
    7B C,             \ ld   a, e
    27 C,             \ daa
    E6 C, 0F C,       \ and  0F
    C6 C, L2-RAM-PAGE C, \ add  L2-RAM-PAGE
    ED C, 92 C, 57 C, \ nextreg 57, a   \ map the page onto MMU7
    3E C, E0 C,       \ ld   a, E0
    B1 C,             \ or   c
    67 C,             \ ld   h, a
    E5 C,             \ push hl
    D9 C,             \ exx
    DD C, E9 C,       \ next
    SMUDGE            \ c;

\ ____________________________________________________________________
\
\ Layer 2 320x256 INITIALIZE
\ Switch the active Layer 2 to 320x256, set its clip window, install the
\ RGB colour profile and clear the whole 80K framebuffer to BACKGROUND.
HEX
: L22-CLEAR     ( -- )          \ fill all ten 8K pages with BACKGROUND
    MMU7@ >R
    L2-RAM-PAGE #10 +  L2-RAM-PAGE DO
        I MMU7!
        E000 2000 BACKGROUND FILL
    LOOP
    R> MMU7!                     \ restore MMU7 (heap stays consistent)
;

: L22-INITIALIZE
    10  70 REG!                 \ Layer 2 Control: 320x256 resolution
    0   1C REG!                 \ reset clip-window index
    0   18 REG!  #159 18 REG!   \ X clip 0..159  (=> 0..319, 2-pixel units)
    0   18 REG!  #255 18 REG!   \ Y clip 0..255
    RGB-COLORS
    ATTRIB     .INK
    BACKGROUND .PAPER
    BACKGROUND .BORDER
    L22-CLEAR
;

\ ____________________________________________________________________
\
\ Build LAYER22 and activate it.
\ The layer-mode byte is 20 (base Layer 2); L22-INITIALIZE then switches
\ the resolution to 320x256 via NextReg $70.
\ PIXELATT has no meaning for one-colour-per-pixel modes -> L1-PLOT stub.
HEX
    04  20          \ 04 char-size to allow 64 chars per row
    1 0FF           \ Attribute masks
    0100 0140       \ V-RANGE (256) and H-RANGE (320)
    ' L22-PIXELADD  \ PIXELADD
    ' L1-POINT      \ POINT
    ' L1-PLOT       \ PLOT
    ' L1-XPLOT      \ XPLOT
    ' L1-PLOT       \ PIXELATT  (placeholder; never called in this mode)
    ' NOOP          \ XY-RATIO
    ' L1-EDGE       \ EDGE
    ' L22-INITIALIZE \ INITIALIZE
    _BLUE           \ BACKGROUND
    0D8             \ ATTRIB (L20-ATTRIB)

LAYER: LAYER22

LAYER22

BASE !
