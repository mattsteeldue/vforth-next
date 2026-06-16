\
\ 037-layer2.f
\ Layer 2 graphics: 256x192 pixels with 256 palette colors.
\
\ Layer 2 is a 256x192 full-color frame buffer, one byte per pixel,
\ giving 256 indexed colors.  It lives in dedicated RAM pages (page
\ numbers depend on the Next hardware revision).  vForth provides
\ the GRAPHICS library with LAYER2 mode support: LAYER2 activates the
\ vectored primitives for this mode; PLOT, DRAW-LINE, CIRCLE, and
\ XPLOT all work in Layer 2 the same way as in Standard Spectrum  mode.
\
\ See also tutorial 052 (modular graphics): to save dictionary space
\ you can load only this mode with  NEEDS LAYER2-GRAPHICS  instead of
\ the whole library, getting the same PLOT/DRAW-LINE/CIRCLE here.
\
\ Coordinate convention (same as GRAPHICS.f throughout):
\   x = vertical   (row 0 = top,   191 = bottom)
\   y = horizontal (col 0 = left,  255 = right)
\
\ Reference: sec.3.2
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   037 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 037 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 037: Layer 2 graphics loaded. ) CR
.(     Type NEWTASK to unload.              ) CR

NEEDS GRAPHICS
NEEDS .BORDER
NEEDS J
NEEDS TO
NEEDS WAIT-KEY
NEEDS FLIP

\ ===========================================================================
\ 1. Activating Layer 2
\ ===========================================================================
\
\   LAYER2  ( -- )   switch to Layer 2 mode
\
\ LAYER2 is defined in GRAPHICS.f.  It:
\   - sets all vectored primitives (PLOT, XPLOT, etc.) to Layer2 variants
\   - calls  LAYER! 20  which programs the Next hardware display register
\   - sets ATTRIB to the Layer2 default color (L20-ATTRIB)
\   - sets the character size to 4 (64 chars per row)
\
\ After LAYER2, text output via EMIT/TYPE still appears, but on top
\ of the Layer2 image in the ULA attribute plane.
\
\ To return to ULA mode:
\   LAYER0    \ or  LAYER! 0

\ ===========================================================================
\ 2. Setting the drawing color (ATTRIB)
\ ===========================================================================
\
\ In Layer2 mode, ATTRIB holds a palette index 0-255.
\ The default palette maps index to color:
\
\   RRRGGGBB format (3 bits red, 3 bits green, 2 bits blue)
\   Index   0 : black
\   Index   3 : blue    ( %00000011 )
\   Index  28 : green   ( %00011100 )
\   Index 224 : red     ( %11100000 )
\   Index 255 : white   ( %11111111 )
\
\ Common palette values:
\   
\   1   dark blue    3   blue       0   black
\   8   dark green   28  green          
\   64  dark red     224 red      
\   37  dark grey    109 grey      255 white
\
\ To change the drawing color:
\   color-index  .INK
\
\ Example: draw in red (palette index 224):
\   LAYER2
\     1 .PAPER
\   218 .INK
\   224 TO ATRIB
\   96 128 40 CIRCLE

\ ===========================================================================
\ 3. PLOT in Layer 2
\ ===========================================================================
\
\   PLOT ( x y -- )   plot one pixel using current ATTRIB
\
\ Layer2 PLOT is implemented in machine code for speed.  It maps the
\ correct 8K RAM page into MMU slot 7 ($E000-$FFFF) for each write.
\
\ Coordinates: x=row 0..191, y=column 0..255.
\ Coordinates outside range are silently ignored (ULA PLOT) or may
\ wrap (Layer2 raw PLOT) -- keep values in range.

\ ===========================================================================
\ 4. DRAW-LINE and CIRCLE in Layer 2
\ ===========================================================================
\
\   DRAW-LINE ( x2 y2 x1 y1 -- )   Bresenham line, ATTRIB color
\   CIRCLE    ( x y r -- )         Bresenham circle, ATTRIB color
\   XPLOT     ( x y -- )           invert pixel (store NOT current)
\
\ These work identically to ULA mode; the mode-specific primitives
\ are selected automatically after calling LAYER2.

: UNSETUP
    LAYER12
    _BLUE .PAPER
;

UNSETUP

: SETUP
    LAYER2
    _BLUE .BORDER
    %00000001   .PAPER    \ dark-blue
    %11011011   .INK      \ white
    CLS
    CR .(     press a key to return.)
;

\ ===========================================================================
\ 5. Demo: color gradient fill
\ ===========================================================================

: L2-GRADIENT  ( -- )
    SETUP
    256 0 DO              \ horizontal
        192 0 DO          \ vertical
            I 5 RSHIFT 7 AND 2 LSHIFT \ red
            J 3 RSHIFT 7 AND 5 LSHIFT \ green
            J 6 RSHIFT 3 AND          \ blue
            + + TO ATTRIB
            I J PLOT
        LOOP
    LOOP
    WAIT-KEY
    UNSETUP
;

\ ===========================================================================
\ 6. Demo: colored circles
\ ===========================================================================

: L2-CIRCLES  ( -- )
    SETUP
    8 1 DO
        I 32 * TO ATTRIB
        96  128  I 20 *  CIRCLE
    LOOP
    WAIT-KEY
    UNSETUP
;

\ ===========================================================================
\ 7. Demo: diagonal color bars
\ ===========================================================================

: L2-BARS  ( -- )
    SETUP
    256 0 DO
        192 0 DO
            J I + 32 / 32 * TO ATTRIB
            I J PLOT
        LOOP
        ?TERMINAL IF LEAVE THEN
    LOOP
    WAIT-KEY
    UNSETUP
;


: DEMO 
    L2-GRADIENT
    L2-CIRCLES
    L2-BARS
;

.( Try DEMO for cumulative demo )

\ ===========================================================================
\ 8. Loading a BMP into Layer 2
\ ===========================================================================
\
\ The word BMP-LOAD (NEEDS BMP-LOAD requires lib/bmp-load.f) loads
\ a 256x192 256-color BMP file directly into Layer 2 memory.
\
\ Usage:
\   LAYER2                          \ activate Layer 2 display
\   CREATE MY-FILE ," C:/image.bmp" \ create a counted-z filename
\   MY-FILE BMP-LOAD                \ load the file
\
\ BMP-LOAD handles page mapping automatically.  The BMP must be
\ exactly 256 pixels wide and 192 pixels tall, 8bpp (256 colors).
\
\ See tutorial 046 for full BMP loading details.

\ ===========================================================================
\ 9. Switching back to ULA mode
\ ===========================================================================
\
\   LAYER0   \ switch back to standard ULA 256x192 8-color mode
\   CLS      \ clear screen (reset attributes)
\
\ Example full cycle:
\   LAYER2  L2-GRADIENT   \ draw in Layer 2
\   WAIT-KEY              \ wait for keypress
\   LAYER0                \ return to ULA mode
\   CLS

\ ===========================================================================
\ 10. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ NEEDS TESTING
\ T{  LAYER2  ATTRIB  ->  ATTRIB  }T   \ ATTRIB is readable
