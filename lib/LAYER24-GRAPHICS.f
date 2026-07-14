\
\ LAYER24-GRAPHICS.f
\
\ Layer 2 high resolution - 640 w x 256 h pixels, 16 colours, 4 bits per
\ pixel (two pixels packed per byte).  Uses the same 80K of RAM as the
\ 320x256 mode (five 16K banks = ten 8K MMU7 pages): 640*256/2 = 81920
\ bytes.  In bytes the layout is IDENTICAL to LAYER22 (vertical bands of
\ 32 byte-columns each); only the pixel addressing halves the horizontal
\ coordinate (byteX = y >> 1) and PLOT/POINT/XPLOT work on a single
\ nibble.  The "4" in the name recalls 4bpp / 16 colours.
\
\ Load with:  NEEDS LAYER24-GRAPHICS
\ It pulls in GRAPHICS-COMMON and activates Layer 2 640x256 immediately.
\
\ N.B. the coordinate convention is preserved:  x = vertical (0..255),
\      y = horizontal (0..639).  PLOT/POINT/... take ( x y ).
\
\ WARNING: this mode assumes the five 16K banks starting at the Layer 2
\ active bank (NextReg $12) are reserved for the framebuffer.  NextZXOS
\ allocates only three banks (48K) for the standard 256x192 Layer 2, so
\ the two extra banks must be free.  Validate on real hardware / CSpect
\ before relying on it.
\
.( LAYER24-GRAPHICS )

NEEDS GRAPHICS-COMMON

MARKER NO-LAYER24-GRAPHICS      \ unload only this mode (keeps GRAPHICS-COMMON)

\ NEEDS guard word for this module
: LAYER24-GRAPHICS
    NOOP
;

\ shared / mode-specific words extracted to inc/ (deduplicated via NEEDS)
NEEDS L4-POINT
NEEDS L4-PLOT
NEEDS L4-XPLOT
NEEDS L4-EDGE
NEEDS L4-PIXELADD
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
: L4-CLEAR     ( -- )           \ fill all ten 8K pages with BACKGROUND
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
: L4-INITIALIZE
    20  70 REG!                 \ Layer 2 Control: 640x256 4bpp (%00100000)
    0   1C REG!                 \ reset clip-window index
    0   18 REG!  #159 18 REG!   \ X clip 0..159  (=> 0..639, 4-pixel units)
    0   18 REG!  #255 18 REG!   \ Y clip 0..255
    RGB-COLORS
    ATTRIB     .INK
    BACKGROUND .PAPER
    BACKGROUND .BORDER
    L4-CLEAR
;

\ ____________________________________________________________________
\
\ Build LAYER24 and activate it.
\ The layer-mode byte is 20 (base Layer 2); L4-INITIALIZE then switches
\ the resolution to 640x256 4bpp via NextReg $70.
\ Colour is a 4-bit index (0..15); ATTRIB is masked to its low nibble at
\ plot time.  PIXELATT has no meaning here -> L4-PLOT stub.
HEX
    04  20          \ 04 char-size to allow 64 chars per row
    1 0FF           \ Attribute masks
    0100 0280       \ V-RANGE (256) and H-RANGE (640)
    ' L4-PIXELADD   \ PIXELADD
    ' L4-POINT      \ POINT
    ' L4-PLOT       \ PLOT
    ' L4-XPLOT      \ XPLOT
    ' L4-PLOT       \ PIXELATT  (placeholder; never called in this mode)
    ' 2/            \ XY-RATIO
    ' L4-EDGE       \ EDGE
    ' L4-INITIALIZE \ INITIALIZE
    _BLUE           \ BACKGROUND
    0F              \ ATTRIB (white-ish; 4-bit index into Layer 2 palette)

LAYER: LAYER24

LAYER24

BASE !
