\
\ 071-characters-and-udg.f
\ Characters beyond ASCII: the block graphics, the user-defined graphics
\ (UDG) and the size of the characters.  A character is a number, and a
\ UDG is eight bytes: this tutorial builds the patterns as a table of its
\ own, points the ROM at it, and then computes new patterns from old ones
\ -- a mirror image, a pattern turned upside down, one rotated by 90
\ degrees -- so that one drawing gives an arrow for all four directions.
\
\ vForth-specific notes:
\   - EMIT is for text: from code 144 up it drops the top bit.  UDGs (144
\     to 164) and the BASIC tokens (165 to 255) need EMITC.
\   - The UDG table must stay BELOW $E000.  The top 8K of memory is the
\     MMU7 window where vForth pages its heap in and out, so the patterns
\     BASIC keeps at $FF58 are not reliably there while Forth runs.  The
\     table below lives in the dictionary; section 3 explains why.
\   - Codes 29 and 30 (height and width of the characters) work on the
\     layers other than 0; vForth's default display, LAYER12, is one.
\
\ Coming from BASIC: Ch.13, 14  |  doc/basic-to-vforth/
\ no Brodie counterpart (ZX Spectrum extension)
\ Reference: sec.2.12.4
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   071 TUTORIAL
\ To unload and reload interactively:
\   RESTORE-UDG NEWTASK 071 TUTORIAL   (RESTORE-UDG: see section 3)
\
\ Run it with:  DEMO
\

MARKER NEWTASK

CR
.( --- Tutorial 071: characters and UDG loaded. ) CR
.(     Type NEWTASK to unload.                  ) CR

NEEDS MS
NEEDS J                         \ J is not in the core: inc/J.f

\ =========================================================================
\ 1. A character is a number: EMIT and EMITC
\ =========================================================================
\
\ There is no character type: a character on the stack is its code.
\ CHAR (at the prompt) and [CHAR] (inside a definition) give the code
\ of a letter, EMIT prints a code.
\
\   CHAR A .                    => 65
\   65 EMIT                     => A
\
\ EMIT keeps seven bits from code 144 up: 193 EMIT prints A again, 65
\ being 193 minus 128.  For the codes above 143 use EMITC, which sends
\ all eight bits to the ROM.  The block graphics, 128 to 143, pass both.

\ =========================================================================
\ 2. The block graphics: four quadrants in one code
\ =========================================================================
\
\ Codes 128 to 143 divide the character cell into four squares.  The
\ low four bits of the code say which squares are ink:
\
\   bit 0 (1)  top right       bit 1 (2)  top left
\   bit 2 (4)  bottom right    bit 3 (8)  bottom left
\
\ So the code is not looked up, it is computed:

: QUADS  ( tl tr bl br -- c )       \ each flag 0 or not 0
    0= 0= 4 AND                     ( tl tr bl n )
    SWAP 0= 0= 8 AND OR             ( tl tr n )
    SWAP 0= 0= 1 AND OR             ( tl n )
    SWAP 0= 0= 2 AND OR
    128 + ;

\   1 0 0 1 QUADS .             => 134   (a diagonal)
\   1 1 1 1 QUADS EMIT          the full block, code 143
\
\ 0= 0= turns any non-zero number into -1, all bits set (and leaves 0
\ alone), and AND then keeps the one bit wanted.  Two of these "pixels"
\ across and two down per character make a 64x48 picture on Layer 0
\ with no graphics at all: that is how the ZX81 drew.

: .QUADS  ( -- )
    144 128 DO  I EMIT  LOOP ;

\   .QUADS                      the sixteen block graphics in order

\ =========================================================================
\ 3. User-defined graphics: a table of your own
\ =========================================================================
\
\ Codes 144 to 164 (the letters A to U in graphics mode) are drawn from
\ 8-byte patterns, one byte per row, the high bit on the left.  The ROM
\ finds them at the address held in the system variable UDG, 23675.
\
\ BASIC keeps its patterns at the top of memory, $FF58.  In vForth that
\ area is the MMU7 window, where heap pages come and go: what is there
\ when the ROM draws a UDG is whichever page vForth mapped last.  So the
\ patterns go in a table in the dictionary, below $E000, and UDG points
\ to it.  The old value is kept, to give BASIC its UDGs back.

23675 CONSTANT UDG
UDG @ CONSTANT BASIC-UDG

: RESTORE-UDG  ( -- )  BASIC-UDG UDG ! ;

\ Four patterns, A to D.  Only A is drawn by hand; the other three are
\ computed in section 5.

CREATE ARROWS
    %00011000 C,
    %00111100 C,
    %01111110 C,
    %11111111 C,
    %00011000 C,
    %00011000 C,
    %00011000 C,
    %00000000 C,
    24 ALLOT                    \ room for B, C, D

: GLYPH  ( n -- a )  8 * ARROWS + ;     \ pattern n, from 0

: USE-ARROWS  ( -- )  ARROWS UDG ! ;

\   USE-ARROWS  144 EMITC       the arrow, pointing up
\   RESTORE-UDG                 BASIC's UDGs again
\
\ CAVEAT: UDG is the ROM's, not vForth's.  NEWTASK forgets the table but
\ leaves UDG pointing at it: the next definition compiled there becomes
\ the "patterns" of every UDG.  Call RESTORE-UDG before NEWTASK.

\ =========================================================================
\ 4. Looking at a pattern
\ =========================================================================
\
\ A pattern is just bytes, and can be read back.  .GLYPH draws one with
\ # for ink and . for paper, one row per line.

: .ROW  ( b -- )
    8 0 DO
        DUP 128 AND IF  [CHAR] #  ELSE  [CHAR] .  THEN EMIT
        2*
    LOOP DROP ;

: .GLYPH  ( a -- )
    8 0 DO  CR DUP I + C@ .ROW  LOOP DROP CR ;

\   0 GLYPH .GLYPH
\   ...##...
\   ..####..
\   .######.
\   ########
\   ...##...
\   ...##...
\   ...##...
\   ........

\ =========================================================================
\ 5. New patterns from old: mirror, flip, rotate
\ =========================================================================
\
\ Since a pattern is a number per row, transforming the picture is
\ arithmetic.  Turning it upside down swaps the rows:

: FLIP-V  ( src dst -- )
    8 0 DO  OVER 7 I - + C@  OVER I + C!  LOOP 2DROP ;

\ A mirror image reverses the bits of each row.  REVERSE takes the bits
\ off the right of b one by one and pushes them in from the right of
\ the result, so the last one in ends up on the left:

: REVERSE  ( b -- b' )
    0 SWAP                      ( r b )
    8 0 DO
        DUP 1 AND               ( r b bit )
        ROT 2* OR               ( b r' )
        SWAP 2/                 ( r' b' )
    LOOP DROP ;

: MIRROR  ( src dst -- )
    8 0 DO  OVER I + C@ REVERSE  OVER I + C!  LOOP 2DROP ;

\   %11000000 REVERSE .         => 3
\
\ A quarter turn clockwise moves the pixel at row y, column x to row x,
\ column 7-y.  It is the one transformation that mixes rows and
\ columns, so it goes pixel by pixel.  MASK is the bit of column c:

: MASK  ( c -- b )  128 SWAP RSHIFT ;

: PIXEL?  ( a row col -- f )  MASK  >R + C@  R> AND ;

: PIXEL!  ( a row col -- )    MASK  >R + DUP C@  R> OR  SWAP C! ;

: ROTATE  ( src dst -- )
    DUP 8 ERASE
    8 0 DO                      \ I = the new row
        8 0 DO                  \ I = the new column, J = the new row
            OVER 7 I - J PIXEL? IF  DUP J I PIXEL!  THEN
        LOOP
    LOOP 2DROP ;

\ Three quarter turns give the other three arrows:

: MAKE-ARROWS  ( -- )
    0 GLYPH 1 GLYPH ROTATE      \ B points right
    1 GLYPH 2 GLYPH ROTATE      \ C points down
    2 GLYPH 3 GLYPH ROTATE ;    \ D points left

MAKE-ARROWS

\   1 GLYPH .GLYPH
\   ....#...
\   ....##..
\   ....###.
\   .#######
\   .#######
\   ....###.
\   ....##..
\   ....#...
\
\ The shaft starts one column in: the bottom row of the first arrow,
\ which is blank, has become the first column.
\
\ CAVEAT: src and dst must not be the same pattern.  ROTATE erases dst
\ first and reads src while it writes dst: 0 GLYPH DUP ROTATE erases
\ the arrow and then reads nothing but zeros.  MIRROR and FLIP-V would
\ survive it only by luck.

\ =========================================================================
\ 6. Width and height of the characters
\ =========================================================================
\
\ On every layer except Layer 0 the ROM draws the characters in a width
\ chosen with code 30, and code 29 sets the height.  vForth's LAYER12
\ starts with 4-pixel-wide characters, 64 columns.  The codes are sent
\ with EMITC, the argument as the next byte:
\
\   30 EMITC 8 EMITC            8 pixels wide: 32 columns (WIDECHAR)
\   30 EMITC 4 EMITC            4 pixels wide: 64 columns (NARROWCHAR)
\   29 EMITC 1 EMITC            double height (on the machine: verify)
\
\ NEEDS WIDECHAR and NEEDS NARROWCHAR give the first two by name.  A
\ UDG pattern is eight pixels wide, like the cell of WIDECHAR: the demo
\ switches to it before printing the arrows, and back afterwards.

\ =========================================================================
\ 7. Demo: the spinning arrow
\ =========================================================================
\
\ The arrow turns in place, sixteen quarter turns.  8 EMITC moves back
\ one place, so each frame overwrites the one before.

: SPIN  ( n -- )
    0 ?DO
        I 3 AND 144 + EMITC  8 EMITC
        150 MS
    LOOP ;

: DEMO  ( -- )
    30 EMITC 8 EMITC            \ WIDECHAR: UDGs at full width
    USE-ARROWS
    CR ." Turning: " 16 SPIN
    CR ." All four: " 148 144 DO  I EMITC SPACE  LOOP CR
    RESTORE-UDG
    30 EMITC 4 EMITC ;          \ NARROWCHAR again

\ =========================================================================
\ 8. Simple tests (requires NEEDS TESTING)
\ =========================================================================
\
\ NEEDS TESTING  DECIMAL          \ lib/testing.f leaves BASE in HEX
\ T{  0 0 0 0 QUADS  1 1 1 1 QUADS  ->  128 143  }T
\ T{  0 1 0 0 QUADS  1 0 0 0 QUADS  ->  129 130  }T
\ T{  %11000000 REVERSE  %00000001 REVERSE  ->  3 128  }T
\ T{  0 GLYPH 3 + C@  1 GLYPH 3 + C@  ->  255 127  }T
\ T{  2 GLYPH C@  2 GLYPH 7 + C@  ->  0 %00011000  }T
\ T{  ARROWS UDG @ =  ->  0  }T
