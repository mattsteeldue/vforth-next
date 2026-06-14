\
\ 036-graphics-ula.f
\ ULA pixel graphics: PLOT, DRAW-LINE, and DRAW-CIRCLE.
\
\ The Standard Spectrum display area covers 256x192 pixels stored at
\ $4000-$57FF in a non-linear (third-by-third) layout.  In vForth,
\ the GRAPHICS library (NEEDS GRAPHICS) provides vectored primitives
\ PLOT, DRAW-LINE, and CIRCLE that work across all supported display
\ modes.  The Standard Spectrum ULA Layer 0 is kept just for legacy.
\ Here we use Layer 1,1 (LAYER11) which is equivalent to Layer 0.
\ Use LAYER12 to go back to default 64 column monochrome mode.
\
\ Coordinate convention in GRAPHICS.f:
\   x = vertical coordinate  (row from top, 0 = top, 191 = bottom)
\   y = horizontal coordinate (col from left, 0 = left, 255 = right)
\
\ Reference: sec.3.2    
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   036 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 036 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 036: ULA pixel graphics loaded. ) CR
.(     Type NEWTASK to unload.          ) CR

NEEDS GRAPHICS
NEEDS .BORDER
NEEDS J
NEEDS TO
NEEDS WAIT-KEY


\ ===========================================================================
\ 1. Switching to ULA (Layer 0) mode
\ ===========================================================================
\
\   LAYER11  ( -- )   switch to Standard Res (Enhanced ULA) mode: 
\       256x192 monochrome pixels, 8-color attributes per 8x8 cell
\
\ Call LAYER11 after loading GRAPHICS to set the vectored primitives
\ (PLOT, POINT, PIXELADD, etc.) to ULA behavior.
\
\ To return default momochrome mode from any other mode,
\ call LAYER12 or equivalently  12 LAYER!
\
\ The GRAPHICS library sets up the current mode automatically on
\ load by calling SETUP, which reads IDE_MODE@.

\ ===========================================================================
\ 2. ATTRIB -- the current drawing color
\ ===========================================================================
\
\ In Standard Spectrum (ULA) mode, ATTRIB is a VALUE that holds 
\ the attribute byte used by PLOT when setting the cell color.  
\ Set it before plotting:
\
\   _WHITE .INK  _BLUE .PAPER   ATTRIB  .   --> 15
\
\ white (7) + blue-paper (8) = 15
\
\ After changing ATTRIB, each subsequent PLOT call will use the new
\ color when writing the cell attribute byte.

\ ===========================================================================
\ 3. PLOT -- plot a single pixel
\ ===========================================================================
\
\   PLOT ( x y -- )
\
\   x : vertical   row (0 = top,  191 = bottom)
\   y : horizontal col (0 = left, 255 = right)
\
\ PLOT sets the pixel at (x, y) using the current ATTRIB for the
\ 8x8-cell attribute.  Coordinates outside 0..191, 0..255 are
\ silently ignored.
\
\ Example: plot a pixel at the centre of the screen
\   96 128 PLOT

\ ===========================================================================
\ 4. DRAW-LINE -- Bresenham line drawing
\ ===========================================================================
\
\   DRAW-LINE ( x2 y2 x1 y1 -- )
\
\ Draws a line from (x1, y1) to (x2, y2) using the current ATTRIB.
\ The coordinates follow the same x=vertical, y=horizontal convention.
\
\ Example: draw a diagonal from top-left to bottom-right
\   191 255 0 0 DRAW-LINE
\
\ DRAW-LINE is part of GRAPHICS.f and is available after NEEDS GRAPHICS.

\ ===========================================================================
\ 5. CIRCLE -- Bresenham circle
\ ===========================================================================
\
\   CIRCLE ( x y r -- )
\
\   x : centre row (vertical)
\   y : centre col (horizontal)
\   r : radius in pixels
\
\ Example: draw a circle centred at (96, 128) with radius 40
\   96 128 40 CIRCLE
\
\ CIRCLE is part of GRAPHICS.f.

\ ===========================================================================
\ 6. XPLOT -- XOR plot (toggle pixel)
\ ===========================================================================
\
\   XPLOT ( x y -- )
\
\ XPLOT toggles the pixel at (x, y) by XOR-ing the pixel bit.
\ Calling XPLOT twice on the same coordinate restores the original
\ content.  Useful for rubber-band lines and simple animation.

\ ===========================================================================
\ 7. Demo: switch to ULA and draw a star pattern
\ ===========================================================================

: SETUP
    LAYER11
    _BLUE  .PAPER 
    _BLUE  .BORDER
    _WHITE .INK  
    CLS
;

: UNSETUP
    LAYER12
    _BLUE .PAPER
    CR .( Try DOT-PATTERN )  
    CR .( Try DRAW-GRID )
    CR .( Try CONCENTRIC )
    CR .( Try CORNER-LINES )
    CR .( Try DEMO for cumulative demo )
    CR .(     press a key to return.)
;


: DOT-PATTERN  ( -- )
    SETUP
    192 0 DO              \ rows 0..191
        256 0 DO          \ cols 0..255
            I J AND       \ simple pattern condition
            IF  I J PLOT     THEN
        2 +LOOP
    2 +LOOP
    WAIT-KEY
    UNSETUP
;

\ ===========================================================================
\ 8. Demo: draw a grid of lines
\ ===========================================================================

: DRAW-GRID  ( -- )
    SETUP
    \ horizontal lines every 24 rows
    192 0 DO
        I 0 I 255 DRAW-LINE
    24 +LOOP
    \ vertical lines every 32 columns
    256 0 DO
        0 I 191 I DRAW-LINE
    32 +LOOP
    WAIT-KEY
    UNSETUP
;

\ ===========================================================================
\ 9. Demo: concentric circles
\ ===========================================================================

: CONCENTRIC  ( -- )
    SETUP
    7 1 8 * + TO ATTRIB
    90 0 DO
        96 128 I CIRCLE
    10 +LOOP
    WAIT-KEY
    UNSETUP
;

\ ===========================================================================
\ 10. Demo: diagonal lines from corner
\ ===========================================================================

: CORNER-LINES  ( -- )
    SETUP
    32 0 DO
        0 I 6 * 191 255 DRAW-LINE
    LOOP
    WAIT-KEY
    UNSETUP
;

UNSETUP

: DEMO 
    DOT-PATTERN
    DRAW-GRID 
    CONCENTRIC 
    CORNER-LINES 
;


\ ===========================================================================
\ 11. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ PLOT and CIRCLE have visual side effects only.
\ ATTRIB is a readable VALUE.
\
\ NEEDS TESTING
\ T{  ATTRIB 255 AND  ->  ATTRIB 255 AND  }T   \ ATTRIB is well-formed

