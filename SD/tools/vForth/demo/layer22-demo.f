\
\ layer22-demo.f
\ Layer 2 high resolution demo: 320 x 256 pixels, 256 colours,
\ one colour per pixel (NEEDS LAYER22-GRAPHICS).
\
\ This shows the wide 320x256 Layer 2 mode (the vertical-band, 80K
\ variant) driven through the SAME vectored primitives as every other
\ graphics mode: PLOT, DRAW-LINE, CIRCLE.  Only the resolution and the
\ memory layout differ; the drawing code is identical to LAYER2 / LAYER0.
\
\ Coordinate convention (as in GRAPHICS.f throughout):
\   x = vertical   (row 0 = top,    255 = bottom)
\   y = horizontal (col 0 = left,   319 = right)
\
\ Colours are 8-bit RGB332 palette indices (RRRGGGBB), set with .INK.
\
\ WARNING: LAYER22 needs five contiguous 16K banks for its framebuffer;
\ NextZXOS reserves only three for the standard 256x192 Layer 2.  Run on
\ real hardware / CSpect and make sure the two extra banks are free.
\
\ Load from a clean session:
\   INCLUDE demo/layer22-demo.f
\ then type   DEMO   (or FRAME / GRADIENT / RAYS / RINGS individually).
\ TASK unloads the demo words.
\

NEEDS LAYER22-GRAPHICS
NEEDS LAYER12

\ NEEDS LAYER22-GRAPHICS auto-activates the 320x256 vertical-band mode,
\ so return to the normal blue 64-column text prompt IMMEDIATELY -- before
\ the modules below load.  In vertical-band mode text runs top-to-bottom
\ and wraps to the right, so any banner printed while still in LAYER22
\ comes out rotated and unreadable.
LAYER12  _BLUE .PAPER    \ _BLUE (=1) from GRAPHICS-COMMON

NEEDS .BORDER
NEEDS WAIT-KEY
NEEDS TO
NEEDS J

MARKER TASK

DECIMAL

\ ===========================================================================
\ 1. Switch in / restore out
\ ===========================================================================
\
\ SETUP selects the 320x256 mode (LAYER22 also clears the framebuffer to
\ its background colour).  UNSETUP returns to the default 64-column text
\ prompt with a blue background, as the graphics conventions require.

: SETUP
    LAYER22                      \ 320x256; clears screen to background
    _BLUE      .BORDER
    _BLUE      .PAPER
    %11111111  .INK              \ white drawing colour
;

: UNSETUP
    LAYER12                      \ default 64-column text mode
    _BLUE .PAPER
;

\ ===========================================================================
\ 2. FRAME -- outline the full 320 x 256 extent
\ ===========================================================================
\
\   DRAW-LINE ( x2 y2 x1 y1 -- )   draws between the two endpoints.

: FRAME  ( -- )
    SETUP
      0 319   0   0  DRAW-LINE    \ top    edge (x = 0)
    255 319 255   0  DRAW-LINE    \ bottom edge (x = 255)
    255   0   0   0  DRAW-LINE    \ left   edge (y = 0)
    255 319   0 319  DRAW-LINE    \ right  edge (y = 319)
    WAIT-KEY
    UNSETUP
;

\ ===========================================================================
\ 3. GRADIENT -- per-pixel RGB332 wash across the whole screen
\ ===========================================================================
\
\ Outer loop sweeps y (horizontal, 0..319), inner loop x (vertical,
\ 0..255).  Inside the inner loop  I = x  and  J = y.  Press any key to
\ BREAK out early via ?TERMINAL (the full screen is 81920 pixels).

: GRADIENT  ( -- )
    SETUP
    320 0 DO                         \ J = y horizontal
        256 0 DO                     \ I = x vertical
            I 5 RSHIFT 7 AND 5 LSHIFT    \ red   from x
            J 6 RSHIFT 7 AND 2 LSHIFT    \ green from y
            J 5 RSHIFT 3 AND             \ blue  from y
            + + TO ATTRIB
            I J PLOT                     \ x y
        LOOP
        ?TERMINAL IF LEAVE THEN
    LOOP
    WAIT-KEY
    UNSETUP
;

\ ===========================================================================
\ 4. RAYS -- a fan of lines from the centre, sweeping the 320 width
\ ===========================================================================

: RAYS  ( -- )
    SETUP
    %11100000 .INK                   \ red rays to the top edge
    320 0 DO
        128 160  0    I  DRAW-LINE    \ centre (128,160) -> (0,I)
    32 +LOOP
    %00011100 .INK                   \ green rays to the bottom edge
    320 0 DO
        128 160  255  I  DRAW-LINE    \ centre (128,160) -> (255,I)
    32 +LOOP
    WAIT-KEY
    UNSETUP
;

\ ===========================================================================
\ 5. RINGS -- concentric circles about the screen centre
\ ===========================================================================

: RINGS  ( -- )
    SETUP
    %11111100 .INK                   \ yellow
    128 10 DO
        128 160 I CIRCLE             \ centre x=128 y=160, radius I
    16 +LOOP
    WAIT-KEY
    UNSETUP
;

\ ===========================================================================
\ 6. DEMO -- run them all in sequence
\ ===========================================================================

: DEMO  ( -- )
    FRAME
    GRADIENT
    RAYS
    RINGS
;

CR
.( layer22-demo loaded. Try DEMO ) CR
.(   or FRAME / GRADIENT / RAYS / RINGS.  TASK unloads. ) CR
