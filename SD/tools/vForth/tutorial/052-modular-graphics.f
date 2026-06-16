\
\ 052-modular-graphics.f
\ Modular graphics: load just ONE display mode with LAYERxx-GRAPHICS.
\
\ The classic GRAPHICS library (NEEDS GRAPHICS, used by tutorials 036
\ and 037) compiles EVERY display mode at once: all the LAYERx words
\ plus the machine-code primitives for Layer 0, 1,0, 1,1, 1,2, 1,3 and
\ Layer 2.  That is convenient but spends a lot of dictionary space on
\ modes you may never use.
\
\ The modular variant splits the same code in two parts:
\   GRAPHICS-COMMON   the shared core: colour constants, LAYER!,
\                     COORD-CHECK, the vectored primitives (PLOT,
\                     XPLOT, POINT, PIXELADD, PIXELATT, XY-RATIO,
\                     EDGE), the LAYER: defining word and the layer-
\                     independent DRAW-LINE, CIRCLE, PAINT, .INK ...
\   LAYERxx-GRAPHICS  ONE module per mode; it pulls in GRAPHICS-COMMON,
\                     defines only the primitives that mode needs and
\                     activates the mode at once.
\
\ You load exactly the mode you want, e.g.  NEEDS LAYER11-GRAPHICS ,
\ and pay for only that mode plus the shared core.  The original
\ lib/GRAPHICS.f is left untouched, so old code keeps working.
\
\ Coordinate convention (same as GRAPHICS.f throughout):
\   x = vertical   (row 0 = top,   191 = bottom)
\   y = horizontal (col 0 = left,  255 = right)
\
\ Reference: sec.3.2
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   052 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 052 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 052: modular graphics loaded. ) CR
.(     Type NEWTASK to unload.                ) CR

\ NEEDS LAYER11-GRAPHICS loads GRAPHICS-COMMON and activates Layer 1,1
\ (Standard Res, equivalent to the legacy ULA Layer 0).  Activating a
\ mode switches the real display, so we restore the default 64-column
\ text mode (LAYER12) right after, for a clean prompt.  The lightweight
\ inc/ word LAYER12 (not the graphics one) is the recommended way back.
NEEDS LAYER11-GRAPHICS
NEEDS LAYER12
NEEDS .BORDER
NEEDS WAIT-KEY

LAYER12              \ back to the normal text prompt after load

\ ===========================================================================
\ 1. What NEEDS LAYER11-GRAPHICS gives you
\ ===========================================================================
\
\ After the NEEDS above the dictionary holds:
\   - the shared core GRAPHICS-COMMON (try  HELP GRAPHICS-COMMON )
\   - the Layer 1,1 primitives and the product word LAYER11
\
\ The vectored words below behave exactly like in tutorials 036/037,
\ because they live in GRAPHICS-COMMON and are common to every mode:
\
\   PLOT      ( x y -- )           plot a pixel with current ATTRIB
\   XPLOT     ( x y -- )           XOR (toggle) a pixel
\   POINT     ( x y -- c )         read a pixel / attribute
\   DRAW-LINE ( x2 y2 x1 y1 -- )   Bresenham line
\   CIRCLE    ( x y r -- )         Bresenham circle
\   PAINT     ( x y -- )           flood fill
\   .INK .PAPER .BRIGHT .FLASH .INVERSE .OVER     ( b -- )
\
\ Only PIXELADD/PIXELATT/PLOT/XPLOT/POINT differ per mode, and those
\ are re-vectored by the LAYERxx product word (here LAYER11).

\ ===========================================================================
\ 2. The available modules
\ ===========================================================================
\
\ Load one of these instead of NEEDS GRAPHICS:
\
\   NEEDS LAYER0-GRAPHICS    Layer 0   ULA          256x192  8 col cells
\   NEEDS LAYER11-GRAPHICS   Layer 1,1 Std Res      256x192  256 col cells
\   NEEDS LAYER13-GRAPHICS   Layer 1,3 HiColour     256x192  32x192 cells
\   NEEDS LAYER12-GRAPHICS   Layer 1,2 Timex HiRes  512x192  2 colours
\   NEEDS LAYER10-GRAPHICS   Layer 1,0 LoRes        128x96   1 col/pixel
\   NEEDS LAYER2-GRAPHICS    Layer 2                256x192  1 col/pixel
\
\ To try a different mode, change the single NEEDS line at the top of
\ this file and reload with  NEWTASK 052 TUTORIAL .

\ ===========================================================================
\ 3. ATTRIB -- the current drawing colour
\ ===========================================================================
\
\ ATTRIB is a VALUE holding the colour/attribute used by PLOT.  In the
\ cell-attribute modes (0, 1,1, 1,3) set it with .INK / .PAPER:
\
\   _WHITE .INK  _BLUE .PAPER   ATTRIB .    => 15
\
\ white ink (7) + blue paper (1<<3 = 8) = 15

\ ===========================================================================
\ 4. Switch in / restore out
\ ===========================================================================
\
\ A tutorial that changes the display mode must restore the default
\ text mode afterwards (see tutorial conventions).  We open with the
\ graphics product word LAYER11 and close with the lightweight LAYER12.

: SETUP
    LAYER11                 \ select Layer 1,1 + ULA-style primitives
    _BLUE  .PAPER
    _BLUE  .BORDER
    _WHITE .INK
    CLS
;

: UNSETUP
    LAYER12                 \ back to default 64-column text mode
    _BLUE .PAPER
    CR .( Try STAR )
    CR .( Try RINGS )
    CR .( Try DEMO for both )
    CR .(     press a key to return.)
;

\ ===========================================================================
\ 5. Demo: a star of lines from the centre
\ ===========================================================================

: STAR  ( -- )
    SETUP
    256 0 DO
        96 128  0   I  DRAW-LINE      \ centre to top edge, sweeping cols
    32 +LOOP
    256 0 DO
        96 128  191 I  DRAW-LINE      \ centre to bottom edge
    32 +LOOP
    WAIT-KEY
    UNSETUP
;

\ ===========================================================================
\ 6. Demo: concentric circles
\ ===========================================================================

: RINGS  ( -- )
    SETUP
    _YELLOW .INK
    90 10 DO
        96 128 I CIRCLE
    16 +LOOP
    WAIT-KEY
    UNSETUP
;

UNSETUP

: DEMO
    STAR
    RINGS
;

\ ===========================================================================
\ 7. Unloading
\ ===========================================================================
\
\ NEWTASK removes this tutorial only.  To drop the graphics modules
\ themselves use their own markers (defined by the lib files):
\
\   NO-LAYER11-GRAPHICS   forget just the Layer 1,1 module
\   NO-GRAPHICS-COMMON    forget the whole modular graphics package
\
\ Either one leaves the display in graphics mode, so follow it with
\ LAYER12 to get the text prompt back.

\ ===========================================================================
\ 8. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ PLOT / CIRCLE have visual side effects only; ATTRIB is a readable VALUE.
\
\ NEEDS TESTING
\ T{  _WHITE _BLUE 3 LSHIFT +  ->  15  }T   \ white ink + blue paper
\ T{  ATTRIB 255 AND  ->  ATTRIB 255 AND  }T
