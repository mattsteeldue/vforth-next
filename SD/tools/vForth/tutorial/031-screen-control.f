\
\ 031-screen-control.f
\ Screen control: INVERSE, OVER, PAGE, and direct attribute memory.
\
\ INVERSE video swaps ink and paper colors, making text appear
\ highlighted.  OVER (XOR) mode overlays text onto existing content
\ by XOR-ing new pixels with what is already on screen.  Together
\ these modes enable visual effects without changing the display buffer
\ contents directly.
\
\ Reference: sec.3.2
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   031 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 031 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 031: Screen control loaded. ) CR
.(     Type NEWTASK to unload.    ) CR

NEEDS .INVERSE
NEEDS .OVER
NEEDS .AT
NEEDS .INK
NEEDS .PAPER
NEEDS J
NEEDS ms
NEEDS LAYER0
NEEDS LAYER12    
NEEDS WAIT-KEY


\ ===========================================================================
\ 1. INVERSE mode
\ ===========================================================================
\
\   .INVERSE ( b -- )   b=1 enables, b=0 disables inverse video
\
\ In inverse mode the ULA swaps ink and paper for each character
\ cell as it is drawn.  Text printed with .INVERSE 1 will appear
\ with paper and ink colors exchanged compared to normal output.
\
\ Example:
\   7 .INK  1 .PAPER      \ white ink on blue paper
\   ." normal "
\   1 .INVERSE
\   ." inverse "           \ now shows blue on white
\   0 .INVERSE
\   ." normal again"
\
\ INVERSE 1 does not alter the permanent attribute byte color fields;
\ it only swaps rendering for the duration of the mode.

\ ===========================================================================
\ 2. OVER mode (XOR)
\ ===========================================================================
\
\   .OVER ( b -- )   b=1 enables, b=0 disables XOR overlay mode
\
\ In OVER mode each character is XOR-ed with whatever is already on
\ screen.  Writing the same character twice restores the original
\ content.  Useful for rubber-band cursors and simple animation.
\
\ Example: toggle a marker on and off without erasing the background
\   1 .OVER
\   5 10 .AT  ." [X]"   \ draw marker
\   500 ms               \ wait
\   5 10 .AT  ." [X]"   \ erase marker (XOR restores original)
\   0 .OVER

\ ===========================================================================
\ 3. PAGE / CLS
\ ===========================================================================
\
\ CLS (core, no NEEDS) clears the screen and resets all attributes
\ to their defaults (white paper, black ink, no bright, no flash).
\
\ After CLS the cursor is at row 0, col 0.
\
\ NEEDS PAGE loads PAGE which is an alias for CLS.

\ ===========================================================================
\ 4. Reading and writing attribute memory directly
\ ===========================================================================
\
\ Attribute area: $5800 .. $5AFF  (768 bytes = 32*24 cells)
\ Address for cell at (row, col):  $5800 + row * 32 + col
\
\ Attribute byte layout:
\   bit 7  : flash  (1 = flashing)
\   bit 6  : bright (1 = bright)
\   bits 5-3 : paper color 0-7
\   bits 2-0 : ink color 0-7
\
\ Compose an attribute byte from colors:
\   ink  +  paper * 8  +  bright * 64  +  flash * 128
\
\ Example: bright cyan paper (5), red ink (2), no flash:
\   2  5 8 * +  64 +    ( = 2 + 40 + 64 = 106 = $6A )

HEX
: >ATTRIB   ( row col -- a )   SWAP 20 * + 5800 +  ;
DECIMAL

: CELL-ATTR@  ( row col -- b )   >ATTRIB C@  ;
: CELL-ATTR!  ( b row col -- )   >ATTRIB C!  ;

\ Compose an attribute byte.
: ATTR-BYTE  ( ink paper bright flash -- b )
    7 LSHIFT          \ flash -> bit 7
    SWAP 6 LSHIFT OR  \ bright -> bit 6
    SWAP 3 LSHIFT OR  \ paper -> bits 5-3
    SWAP 7 AND OR     \ ink -> bits 2-0
;

\ ===========================================================================
\ 5. Demo: color grid by direct attribute write
\ ===========================================================================
\
\ Fill the attribute area with a pattern:
\ each row uses a different paper color, ink stays at 7 (white).

: COLOR-GRID  ( -- )
    24 0 DO
        32 0 DO
            7                   \ ink
            I 7 AND             \ paper: 0-7 cycling every 8 rows
            0 0 ATTR-BYTE       \ bright=0 flash=0
            J I CELL-ATTR!      \ write directly to attribute memory
        LOOP
    LOOP
;

\ ===========================================================================
\ 6. Demo: INVERSE mode highlight
\ ===========================================================================

: INVERSE-DEMO  ( -- )
    5 4 .AT  7 .INK  0 .PAPER
    ." This line is normal.  "
    6 4 .AT
    1 .INVERSE
    ." This line is inverse. "
    0 .INVERSE
    7 4 .AT
    ." Back to normal again. "
;

\ ===========================================================================
\ 7. Demo: OVER mode toggle cursor
\ ===========================================================================

: OVER-DEMO  ( -- )
    CR
    ." Background text on the screen." CR
    1 .OVER
    5 0 DO
        10 5 .AT  ." [***]"   \ draw
        250 ms
        10 5 .AT  ." [***]"   \ erase (XOR)
        250 ms
    LOOP
    0 .OVER
;

: DEMO
    LAYER0 CLS
    INVERSE-DEMO    WAIT-KEY
    OVER-DEMO       
    COLOR-GRID      WAIT-KEY
    LAYER12 1 .PAPER
;

CR
.( Try: DEMO ) CR


\ ===========================================================================
\ 8. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ NEEDS TESTING
\ T{  7 0 0 0 ATTR-BYTE  ->  7    }T
\ T{  0 7 0 0 ATTR-BYTE  ->  56   }T
\ T{  0 0 1 0 ATTR-BYTE  ->  64   }T
\ T{  0 0 0 1 ATTR-BYTE  ->  128  }T
\ T{  2 5 0 0 ATTR-BYTE  ->  42   }T
\ T{  0  0 >ATTRIB  ->  22528     }T
\ T{  1  0 >ATTRIB  ->  22560     }T
\ T{  0 31 >ATTRIB  ->  22559     }T
