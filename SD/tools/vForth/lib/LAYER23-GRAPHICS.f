\
\ LAYER23-GRAPHICS.f
\
\ Layer 2 high resolution - 640 w x 256 h pixels, 16 colours, 4 bits per
\ pixel (two pixels packed per byte).  Uses the same 80K of RAM as the
\ 320x256 mode (five 16K banks = ten 8K MMU7 pages): 640*256/2 = 81920
\ bytes.  In bytes the layout is IDENTICAL to LAYER22 (vertical bands of
\ 32 byte-columns each); only the pixel addressing halves the horizontal
\ coordinate (byteX = y >> 1) and PLOT/POINT/XPLOT work on a single
\ nibble.  The name follows the official manual, which calls this mode
\ "Layer 2,3" (and 320x256 "Layer 2,2", hence LAYER22).
\
\ Load with:  NEEDS LAYER23-GRAPHICS
\ It pulls in GRAPHICS-COMMON and activates Layer 2 640x256 immediately.
\
\ N.B. the coordinate convention is preserved:  x = vertical (0..255),
\      y = horizontal (0..639).  PLOT/POINT/... take ( x y ).
\
\ WARNING: this mode assumes the five 16K banks starting at the Layer 2
\ active bank (NextReg $12) are reserved for the framebuffer.  NextZXOS
\ allocates only three banks (48K) for the standard 256x192 Layer 2, so
\ the two extra banks must be free.  Checked on the real Next 2026-11-18
\ with demo/layer23-check.f.
\
.( LAYER23-GRAPHICS )

NEEDS GRAPHICS-COMMON

MARKER NO-LAYER23-GRAPHICS      \ unload only this mode (keeps GRAPHICS-COMMON)

\ NEEDS guard word for this module
: LAYER23-GRAPHICS
    NOOP
;

\ shared / mode-specific words extracted to inc/ (deduplicated via NEEDS)
NEEDS L23-POINT
NEEDS L23-PLOT
NEEDS L23-XPLOT
NEEDS L23-EDGE
NEEDS L23-PIXELADD
NEEDS L2-RAM-PAGE
NEEDS .BORDER

BASE @

\ ____________________________________________________________________
\
\ Layer 2 640x256 CLEAR
\ Same ten-8K-page sweep as L22-CLEAR, but the fill byte must carry the
\ BACKGROUND colour in BOTH nibbles (b<<4 | b); filling with the raw
\ nibble would paint colour-0/colour-b stripes.
HEX
: L23-CLEAR    ( -- )           \ fill all ten 8K pages with BACKGROUND
    MMU7@ >R
    L2-RAM-PAGE #10 +  L2-RAM-PAGE DO
        I MMU7!
        E000 2000 BACKGROUND 0F AND DUP 4 LSHIFT OR FILL
    LOOP
    R> MMU7!                     \ restore MMU7 (heap stays consistent)
;

\ ____________________________________________________________________
\
\ Layer 2 640x256 INITIALIZE
\ Switch the active Layer 2 to 640x256 4bpp, set its clip window, install
\ the RGB colour profile and clear the whole 80K framebuffer.
HEX
: L23-INITIALIZE
    20  70 REG!                 \ Layer 2 Control: 640x256 4bpp (%00100000)
    1   1C REG!                 \ bit 0: reset Layer 2 clip-window index
    0   18 REG!  #159 18 REG!   \ X clip 0..159  (=> 0..639, 4-pixel units)
    0   18 REG!  #255 18 REG!   \ Y clip 0..255
    RGB-COLORS
    ATTRIB     .INK
    BACKGROUND .PAPER
    BACKGROUND .BORDER
    L23-CLEAR
;

\ ____________________________________________________________________
\
\ Build LAYER23 and activate it.
\ The layer-mode byte is 20 (base Layer 2); L23-INITIALIZE then switches
\ the resolution to 640x256 4bpp via NextReg $70.
\ Colour is a 4-bit index (0..15); ATTRIB is masked to its low nibble at
\ plot time.  PIXELATT has no meaning here -> L23-PLOT stub.
HEX
    04  20          \ 04 char-size to allow 64 chars per row
    1 0FF           \ Attribute masks
    0100 0280       \ V-RANGE (256) and H-RANGE (640)
    ' L23-PIXELADD  \ PIXELADD
    ' L23-POINT     \ POINT
    ' L23-PLOT      \ PLOT
    ' L23-XPLOT     \ XPLOT
    ' L23-PLOT      \ PIXELATT  (placeholder; never called in this mode)
    ' 2/            \ XY-RATIO
    ' L23-EDGE      \ EDGE
    ' L23-INITIALIZE \ INITIALIZE
    _BLUE           \ BACKGROUND
    0F              \ ATTRIB (white-ish; 4-bit index into Layer 2 palette)

LAYER: LAYER23

LAYER23

BASE !
