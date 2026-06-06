\
\ 038-graphics-advanced.f
\ Advanced GRAPHICS.f: LAYER modes, PAINT, XPLOT, and POINT.
\
\ The GRAPHICS library supports six display modes: LAYER0 (classic
\ ULA), LAYER10 (128x96 LoRes 256-color), LAYER11 (Enhanced ULA),
\ LAYER12 (Timex HiRes 512x192), LAYER13 (Timex HiColor), and
\ LAYER2 (256x192 256-color).  Each mode uses the same interface
\ (PLOT, XPLOT, POINT, DRAW-LINE, CIRCLE, PAINT) but different
\ hardware implementations selected via DEFER/IS.
\
\ Reference: sec.7.2
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   038 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 038 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 038: Advanced graphics loaded. ) CR
.(     Type NEWTASK to unload.    ) CR

NEEDS GRAPHICS
NEEDS J
NEEDS TO

\ ===========================================================================
\ 1. Mode summary
\ ===========================================================================
\
\ Mode       Word      Resolution  Colors  Notes
\ -------    ------    ----------  ------  ------
\ Layer 0    LAYER0    256 x 192    8      Classic ULA
\ Layer 1,0  LAYER10   128 x 96   256      LoRes 256-color
\ Layer 1,1  LAYER11   256 x 192  256      Enhanced ULA, 64 cols
\ Layer 1,2  LAYER12   512 x 192    2      Timex HiRes, 8-char wide
\ Layer 1,3  LAYER13   256 x 192  256      Timex HiColor, 64 cols
\ Layer 2    LAYER2    256 x 192  256      Full-color frame buffer
\
\ Select mode by calling the word (e.g. LAYER2).
\ LAYER! n  is the low-level call (n in a mixed hex/decimal encoding).
\
\ Coordinate convention throughout:
\   x = vertical   (row,  0 = top)
\   y = horizontal (col,  0 = left)
\
\ After switching mode, all deferred words (PLOT, XPLOT, POINT,
\ PIXELADD, PIXELATT, EDGE, XY-RATIO) are updated automatically.

\ ===========================================================================
\ 2. ATTRIB -- current drawing color / attribute
\ ===========================================================================
\
\ ATTRIB is a VALUE holding the current color used by PLOT and PAINT.
\ Its meaning depends on the active mode:
\
\   LAYER0, LAYER11, LAYER12, LAYER13:
\     standard ULA attribute byte (paper*8 + ink + bright*64 ...)
\
\   LAYER10, LAYER2:
\     palette index 0-255
\
\ Change ATTRIB with:   value  TO ATTRIB
\
\ L0-ATTRIB, L10-ATTRIB ... L20-ATTRIB are VALUEs holding the
\ default ATTRIB for each mode.  They are set automatically when
\ calling the LAYER word.

\ ===========================================================================
\ 3. XPLOT -- toggle / invert a pixel
\ ===========================================================================
\
\   XPLOT ( x y -- )
\
\ In LAYER0/LAYER11/LAYER12/LAYER13 (bit-mapped ULA modes):
\   XPLOT XOR-toggles the pixel bit.  The pixel is set if it was
\   clear, or cleared if it was set.  Calling XPLOT twice on the
\   same coordinate restores the original content.
\
\ In LAYER10 and LAYER2 (byte-per-pixel modes):
\   XPLOT XOR-inverts all 8 bits of the color byte, effectively
\   complementing the palette index.
\
\ Example: draw a temporary cursor using XPLOT
\   1 .OVER
\   LAYER0
\   50 100 XPLOT   \ mark pixel
\   500 ms
\   50 100 XPLOT   \ unmark pixel
\   0 .OVER

\ ===========================================================================
\ 4. POINT -- read the color/state of a pixel
\ ===========================================================================
\
\   POINT ( x y -- c )
\
\ In ULA modes (LAYER0, LAYER11, LAYER12, LAYER13):
\   Returns a non-zero value ($80) if the pixel at (x,y) is set,
\   0 if it is clear.
\
\ In LAYER10 and LAYER2:
\   Returns the palette index stored at (x,y) (0-255).
\
\ Example: read pixel at (96, 128)
\   96 128 POINT .   \ prints 0 or 128 (ULA) or palette index (L2)

\ ===========================================================================
\ 5. COORD-CHECK -- bounds check before plotting
\ ===========================================================================
\
\   COORD-CHECK ( x y -- x y f )
\
\ Returns true if (x, y) is within the current mode's pixel range.
\ L0-PLOT calls COORD-CHECK automatically before writing.
\ Layer2 PLOT does not (for speed); use COORD-CHECK manually if
\ plotting from user input.

\ ===========================================================================
\ 6. PAINT -- flood fill
\ ===========================================================================
\
\   PAINT ( x y -- )
\
\ PAINT flood-fills the region containing (x, y) using the current
\ ATTRIB color.  It starts from (x, y) and expands in the vertical
\ direction (using PAINT-HITX) then horizontal (PAINT-HIT).
\
\ The fill boundary is determined by the EDGE deferred word:
\   In ULA modes: any non-zero pixel is treated as a boundary.
\   In LAYER10/LAYER2: a pixel matching the current ATTRIB is a
\   boundary (same-color stop).
\
\ Warning: PAINT can be slow on large areas and may overflow the
\ return stack on complex shapes.  Use with care.
\
\ Example: fill a circle with red (LAYER2)
\   LAYER2
\   224 TO ATTRIB   \ red
\   96 128 40 CIRCLE
\   7 TO ATTRIB     \ blue
\   96 128 PAINT    \ fill interior

\ ===========================================================================
\ 7. Demo: LAYER10 LoRes 256-color plot
\ ===========================================================================

: L10-DEMO  ( -- )
    LAYER10
    CLS
    96 0 DO               \ rows 0..95
        128 0 DO          \ cols 0..127
            I J +  TO ATTRIB
            I J PLOT
        LOOP
    LOOP
;

\ ===========================================================================
\ 8. Demo: rubber-band box using XPLOT
\ ===========================================================================

NEEDS ms

: RUBBER-BOX  ( x1 y1 x2 y2 -- )
    2OVER 2OVER               \ x1 y1 x2 y2  x1 y1 x2 y2
    \ top side: (x1,y1)..(x1,y2)
    OVER ROT SWAP DRAW-LINE
    \ TODO: full box for demo purposes we just draw two sides
    2DROP 2DROP
;

\ ===========================================================================
\ 9. Demo: mode switching sequence
\ ===========================================================================

NEEDS WAIT-KEY

: MODE-TOUR  ( -- )
    LAYER0   CLS  ." Layer 0  (ULA)      " 500 ms  WAIT-KEY
    LAYER11  CLS  ." Layer 11 (Enh ULA)  " 500 ms  WAIT-KEY
    LAYER2   CLS  ." Layer 2  (256-color)" 500 ms  WAIT-KEY
    LAYER0   CLS
;

\ ===========================================================================
\ 10. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ NEEDS TESTING
\ T{  0 0 COORD-CHECK  ->  0 0 -1  }T   \ top-left is in range
\ T{  191 255 COORD-CHECK  ->  191 255 -1  }T
\ T{  192 0 COORD-CHECK  ->  192 0  0  }T   \ row 192 out of range
