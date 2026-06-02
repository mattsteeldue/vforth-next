\
\ 030-ula-display.f
\ ULA display attributes: ink, paper, border, bright, flash
\ and cursor positioning on the ZX Spectrum character grid.
\
\ The ZX Spectrum ULA manages a 32x24 grid of 8x8-pixel cells.
\ Each cell has one attribute byte: bit7=flash, bit6=bright,
\ bits5-3=paper color, bits2-0=ink color.  Colors 0-7:
\ 0=black 1=blue 2=red 3=magenta 4=green 5=cyan 6=yellow 7=white
\
\ Reference: sec.3.2
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   030 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 030 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 030: ULA display attributes loaded. ) CR
.(     Type NEWTASK to unload.               ) CR

NEEDS .INK
NEEDS .PAPER
NEEDS .BORDER
NEEDS .BRIGHT
NEEDS .FLASH
NEEDS .AT
NEEDS .TAB
NEEDS CASE
NEEDS LAYER0
NEEDS LAYER12    


\ ===========================================================================
\ 1. The attribute byte
\ ===========================================================================
\
\ Every character cell (8x8 pixels) on the 32x24 ULA grid has one byte
\ in the attribute area at $5800-$5AFF (768 bytes, 32*24).
\
\   bit 7 : FLASH  - alternates ink/paper every ~0.6 s
\   bit 6 : BRIGHT - doubles the intensity of ink and paper
\   bits 5-3 : PAPER color 0-7
\   bits 2-0 : INK   color 0-7
\
\ Color numbers:
\   0=black  1=blue  2=red  3=magenta
\   4=green  5=cyan  6=yellow  7=white
\
\ Address of the attribute byte for cell (row, col):
\   $5800 + row * 32 + col
\
\ Example: attribute byte for blue paper, white ink, bright on:
\   1 paper=1, shift 3 => %00001000
\   7 ink              => %00000111
\   1 bright, shift 6  => %01000000
\   result             => %01001111  = $4F

\ Build an attribute byte from components.
\ Usage: ink paper bright flash MAKE-ATTRIB ( -- b )
: MAKE-ATTRIB  ( ink paper bright flash -- b )
    7 LSHIFT           \ flash bit
    SWAP 6 LSHIFT OR   \ bright bit
    SWAP 3 LSHIFT OR   \ paper bits 5-3
    SWAP 7 AND OR      \ ink bits 2-0
;

\ ===========================================================================
\ 2. Setting colors via emit-control sequences
\ ===========================================================================
\
\ vForth provides words that emit ZX Spectrum control codes:
\
\   .INK   ( b -- )   set ink color   0-7  (ctrl 16 + color)
\   .PAPER ( b -- )   set paper color 0-7  (ctrl 17 + color)
\   .BRIGHT( b -- )   set bright 0|1       (ctrl 19 + flag)
\   .FLASH ( b -- )   set flash  0|1       (ctrl 18 + flag)
\
\ These affect text printed AFTER the call.
\ Color changes remain active until changed again or CLS is called.
\
\ Example: print "Hello" in bright yellow on blue background
\   CLS
\   6 .INK  1 .PAPER  1 .BRIGHT
\   ." Hello"  0 .BRIGHT
\
\ ATTRIB-MASK: in Layer2 mode, .INK and .PAPER have no effect on
\ Layer2 pixels; ATTRIB-MASK filters the color to 0 in that mode.

\ ===========================================================================
\ 3. Border color
\ ===========================================================================
\
\   .BORDER ( b -- )  set border color 0-7 via port $FE
\
\ The border is the area outside the 256x192 pixel display.
\ It is not part of the attribute grid; it has a single color.
\
\ Example:
\   2 .BORDER     \ red border
\   0 .BORDER     \ black border

\ ===========================================================================
\ 4. Cursor positioning: .AT and .TAB
\ ===========================================================================
\
\   .AT ( row col -- )   position cursor at row 0-23, col 0-31
\                        emits ctrl-22 + row + col
\   .TAB ( n -- )        tab to column n
\                        emits ctrl-23 + split(n)
\
\ Row 0 is the top line; col 0 is the leftmost column.
\ Row 23 is the bottom line used for system messages.
\
\ Example: print "ZX" at row 5, column 10
\   5 10 .AT  ." ZX"
\
\ Example: tab to column 16 then print a label
\   16 .TAB  ." <-- here"

\ ===========================================================================
\ 5. CLS: clear screen
\ ===========================================================================
\
\ CLS is a core word (no NEEDS required).
\ It clears the 32x24 text area, resets cursor to (0,0), and
\ resets ink/paper/bright/flash to default (white paper, black ink).
\
\ PAGE is equivalent to CLS but requires NEEDS PAGE.

\ ===========================================================================
\ 6. Demo words
\ ===========================================================================

\ Print a swatch of each color number as colored text.
: .COLOR-SWATCH  ( n -- )
    DUP .PAPER
    DUP .INK
    .  SPACE
;

: .COLOR-DEMO  ( -- )
    CLS
    0 2 .AT
    7 .PAPER  0 .INK
    ."  Color swatches (ink=paper): " CR
    8 0 DO
        I .COLOR-SWATCH
    LOOP
    CR
    7 .PAPER  0 .INK  0 .BRIGHT
;

\ Draw a title bar: row 0, white ink on blue paper, bright.
: TITLE-BAR  ( -- )
    0 0 .AT
    7 .INK  1 .PAPER  1 .BRIGHT
    32 0 DO  SPACE  LOOP   \ fill row with spaces
    0 0 .AT
    ." --- vForth Tutorial ---"
    0 .BRIGHT
    7 .PAPER  0 .INK
;

\ Helper: print color name for demo.

: .COLOR-NAME  ( n -- )
    CASE
        0 OF  ." black   " ENDOF
        1 OF  ." blue    " ENDOF
        2 OF  ." red     " ENDOF
        3 OF  ." magenta " ENDOF
        4 OF  ." green   " ENDOF
        5 OF  ." cyan    " ENDOF
        6 OF  ." yellow  " ENDOF
        7 OF  ." white   " ENDOF
        DROP ." ?       "
    ENDCASE
;

\ Demo: show colors at different screen positions.
: COLOR-POS-DEMO  ( -- )
    CLS
    TITLE-BAR
    8 0 DO
        2 I + I 3 * .AT
        I .INK  
        I IF 0 ELSE 7 THEN .PAPER 
        I .
        I .COLOR-NAME
    LOOP
    7 .PAPER  0 .INK
;


: DEMO
    LAYER0
    COLOR-POS-DEMO
    CURS KEY 
    .COLOR-DEMO
    CURS KEY 
    LAYER12 1 .PAPER
;

CR
.( Try: DEMO ) CR


\ ===========================================================================
\ 7. Attribute memory: direct access
\ ===========================================================================
\
\ The attribute area starts at $5800 (decimal 22528).
\ Each byte: bit7=flash bit6=bright bits5-3=paper bits2-0=ink
\
\ To read the attribute at row R, col C:
\   $5800 R 32 * + C + C@   ( -- b )
\
\ To write it directly:
\   b  $5800 R 32 * + C + C!
\
\ Example: make cell (2,4) have bright red ink on white paper:
\   HEX  0 3 LSHIFT 7 OR 40 OR  5800 2 20 * + 4 + C!
\   ( ink=2 red, paper=7 white, bright=1, flash=0 )
\   ( 0 flash, 1 bright=40, 7 paper=38, 2 ink => 40+38+2 = 7A )

HEX
: ATTRIB-ADDR  ( row col -- a )
    SWAP 20 * + 5800 +
;
DECIMAL

: ATTRIB@  ( row col -- b )  ATTRIB-ADDR C@  ;
: ATTRIB!  ( b row col -- )  ATTRIB-ADDR C!  ;

\ ===========================================================================
\ 8. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ These tests verify the MAKE-ATTRIB and ATTRIB-ADDR helpers.
\ The color control words have side effects (screen changes) and
\ cannot be verified automatically.
\
\ NEEDS TESTING
\ T{  0 0 0 0 MAKE-ATTRIB  ->  0  }T
\ T{  7 0 0 0 MAKE-ATTRIB  ->  7  }T
\ T{  0 7 0 0 MAKE-ATTRIB  ->  56 }T
\ T{  0 0 1 0 MAKE-ATTRIB  ->  64 }T
\ T{  0 0 0 1 MAKE-ATTRIB  ->  128 }T
\ T{  0 0 ATTRIB-ADDR  ->  22528  }T
\ T{  0 31 ATTRIB-ADDR  ->  22559  }T
\ T{  23 0 ATTRIB-ADDR  ->  23264  }T
