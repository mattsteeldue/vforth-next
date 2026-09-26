\
\ 039-sprites.f
\ Hardware sprites: setup, pattern upload, and positioning.
\
\ The ZX Next supports up to 128 hardware sprites.  Each sprite is
\ 16x16 pixels (one byte per pixel, 256-color palette).  Sprites are
\ composited in hardware over the display layer.  Pattern data is
\ written via port $005B; attribute data (position, visibility, slot)
\ is written via port $0057.  The MOUSE library (lib/MOUSE.f) shows
\ a working example of sprite use for the mouse cursor.
\ This tutorial just show a motion-less arrow.
\
\ Reference: sec.3.4
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   039 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 039 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 039: Hardware sprites loaded. ) CR
.(     Type NEWTASK to unload.             ) CR

NEEDS SPLIT


\ ===========================================================================
\ 1. Sprite hardware overview
\ ===========================================================================
\
\ Registers and ports:
\   Next reg $15  : sprite/layer control
\                   bit 1 = sprites visible over border
\                   bit 0 = sprites enabled
\   Port $303B    : SPRITE-SLOT-PORT
\                   write n to select sprite slot 0-127
\   Port $0057    : SPRITE-ATTR-PORT
\                   write 4 bytes for position and flags
\   Port $005B    : SPRITE-PAT-PORT
\                   write 256 bytes of pattern data for current slot
\
\ Sprite attribute bytes (4 bytes per sprite):
\   byte 0 : X position bits 7-0
\   byte 1 : Y position bits 7-0
\   byte 2 : %PPPPXYRx  palette offset bits 7-4, X mirror (3),
\             Y mirror (2), rotate (1), X bit 8 (0, for X 256-319)
\   byte 3 : %VEnnnnnn  V=visible (7), E=enable attribute byte 4 (6),
\             pattern number bits 5-0
\
\ The sprite SLOT is chosen only by the write to port $303B; byte 3
\ selects the PATTERN the slot shows (see tutorial 053).
\
\ Pattern data: 16*16 = 256 bytes, one byte per pixel.
\ The global transparency color byte is read from Next reg $14
\ (default $E3): pixels of that color are not drawn.

\ ===========================================================================
\ 2. Port constants
\ ===========================================================================

$303B  CONSTANT  SPRITE-SLOT-PORT      \ write: select slot 0-127
$0057  CONSTANT  SPRITE-ATTR-PORT      \ write: 4-byte attribute
$005B  CONSTANT  SPRITE-PAT-PORT       \ write: 256-byte pattern


\ ===========================================================================
\ 3. Sprite global control
\ ===========================================================================
\
\ Enable sprites:
\   3 $15 REG!    \ bit1=visible-over-border, bit0=sprites-on
\
\ Disable sprites:
\   0 $15 REG!

: SPRITES-ON   ( -- )  3 $15 REG!   ;
: SPRITES-OFF  ( -- )  0 $15 REG!   ;

\ ===========================================================================
\ 4. Upload pattern data to a sprite slot
\ ===========================================================================
\
\ SPRITE-PAT-UPLOAD  ( a n -- )
\   a : address of 256-byte pattern data
\   n : sprite slot number 0-127
\
\ Select the slot, then write 256 bytes to SPRITE-PAT-PORT.

$14 REG@ CONSTANT E3 \ Global Transparency Colour
: " $00 C, ; \ Black
: | $6D C, ; \ Dark-Grey
: v $B6 C, ; \ Light-Gray
: M $FF C, ; \ White
: _ $E3 C, ; \ Transparency


\ Semi-graphical mouse-face definition 
CREATE MOUSE-FACE

\ 0 1 2 3 4 5 6 7 8 9 A B C D E F \
\ ------------------------------- \
M | " " _ _ _ _ _ _ _ _ _ _ _ _ \ 0
M M | " " _ _ _ _ _ _ _ _ _ _ _ \ 1
M M M | " " _ _ _ _ _ _ _ _ _ _ \ 2
M M M M | " " _ _ _ _ _ _ _ _ _ \ 3
M M M M M | " " _ _ _ _ _ _ _ _ \ 4
M M M M M M | " " _ _ _ _ _ _ _ \ 5
M M M M M M M | " " _ _ _ _ _ _ \ 6
M M M M M M M M | " " _ _ _ _ _ \ 7
M M M M M M M M M | " " _ _ _ _ \ 8
M M M M M M | " " " " " " _ _ _ \ 9
M M | v M M | " " " _ _ _ _ _ _ \ A
M | " v M M v | " " _ _ _ _ _ _ \ B
| " _ _ v M M | " " _ _ _ _ _ _ \ C
_ _ _ _ v M M v | " " _ _ _ _ _ \ D
_ _ _ _ _ M M v | " " _ _ _ _ _ \ E
_ _ _ _ _ v v | " " " _ _ _ _ _ \ F


: SPRITE-PAT-UPLOAD ( a n -- )
    SPRITE-SLOT-PORT   P!    \ a 
    256 OVER + SWAP          \ a+80 a 
    DO
        16 I + I 
        DO
            I C@  SPRITE-PAT-PORT P!
        LOOP
    16 +LOOP
;    

\ ===========================================================================
\ 5. Set sprite position and visibility
\ ===========================================================================
\
\ SPRITE-MOVE ( x y slot -- )
\   x    : horizontal position (0 = leftmost visible pixel)
\   y    : vertical position
\   slot : sprite number 0-127
\
\ Sprite coordinates include the border: their origin is 32 pixels up
\ and 32 pixels left of the top-left corner of the 256x192 screen.
\ X=32 is the left edge of the screen, Y=32 its top edge; smaller
\ values place the sprite over the border (visible only with bit 1 of
\ Next reg $15 set, as SPRITES-ON does).

: SPRITE-SHOW  ( x y slot -- )
    SPRITE-SLOT-PORT P!         \ select slot
    SWAP SPLIT SWAP             \ y x_hi x_lo
    SPRITE-ATTR-PORT P!         \ byte 0 : x low byte
    SWAP SPRITE-ATTR-PORT P!    \ byte 1 : y low byte
    01 AND SPRITE-ATTR-PORT P!  \ byte 2 : x hi bit + palette
    $C0 SPRITE-ATTR-PORT P!     \ byte 3 : $C0 = visible
;

\ Hide a sprite by writing 0 to byte 3 (disabled).
: SPRITE-HIDE  ( slot -- )
    SPRITE-SLOT-PORT P!
    0 SPRITE-ATTR-PORT P!   \ x
    0 SPRITE-ATTR-PORT P!   \ y
    0 SPRITE-ATTR-PORT P!   \ flags
    0 SPRITE-ATTR-PORT P!   \ byte 3 = 0 -> disabled
;

\ ===========================================================================
\ 6. Demo: create a simple sprite 
\ ===========================================================================
\
\ This example uses sprite slot 0.  The pattern is a 16x16 mouse-arrow.
\ Pixel color 255 = white in the default palette.
\ Pixel color $E3 = the default global transparency color.

\ directly change Sprite #0

: SPRITE-DEMO  ( -- )
    MOUSE-FACE  0  SPRITE-PAT-UPLOAD   \ upload pattern to slot 0
    SPRITES-ON
    5120 0 DO    
        I 20 / DUP 2/
        0 SPRITE-SHOW    
    LOOP
    0 SPRITE-HIDE
    SPRITES-OFF
;

.( Try SPRITE-DEMO )

\ ===========================================================================
\ 7. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ Sprite words write to hardware ports and cannot be verified
\ automatically.  Only the port constants are testable.
\
\ NEEDS TESTING
\ T{  SPRITE-SLOT-PORT  ->  12347  }T   \ $303B
\ T{  SPRITE-ATTR-PORT  ->    87   }T   \ $0057
