\
\ 053-more-sprites.f
\ Hardware sprites, intermediate: a struct, loading patterns from a
\ file, and animation -- almost all in pure Forth, plus one small
\ CODE word that ships a 256-byte pattern with a single Z80 "otir".
\
\ The ZX Spectrum Next has 64 hardware sprites, each a 16x16 pattern
\ of 256 bytes (one palette index per pixel).  This tutorial models a
\ single sprite as a small struct built with +FIELD, uploads pattern
\ data through the I/O ports, reads up to 64 patterns straight from a
\ .spr file with OPEN< / F_READ, and animates one sprite by writing
\ its attributes every few frames.  The X coordinate spans 0..319, so
\ it needs nine bits: the low eight live in attribute 0 and bit 8 is
\ packed into attribute 2 together with the rotate/mirror and pattern
\ fields -- the handling of that bit 8 is the subtle part below.
\
\ vForth notes: PAUSE uses the core word 1FRAME (EI HALT NEXT), which
\ blocks one 50Hz frame, so no NEEDS is required for timing.  Numeric
\ literals use the $/%/# prefixes; the global BASE is never switched
\ during compilation.
\
\ Reference: sec.3.4
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   053 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 053 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 053: More sprites loaded. ) CR
.(     Type NEWTASK to unload. ) CR

NEEDS +FIELD
NEEDS J
NEEDS REG!

\ ===========================================================================
\ 1. I/O ports and buffer length
\ ===========================================================================
\
\ Sprites are programmed through three Next I/O ports:
\   $303B  select which sprite slot / pattern slot the next writes hit
\   $0057  write the four attribute bytes of the selected sprite
\   $005B  write the 256 pattern bytes of the selected pattern slot
\ Each sprite pattern is 16x16 = 256 bytes.

$303B CONSTANT SPRITE-SLOT-SELECT-PORT
$0057 CONSTANT SPRITE-ATTRIBUTE-PORT
$005B CONSTANT SPRITE-PATTERN-PORT
 #256 CONSTANT SPRITE-BUFLEN

\ ===========================================================================
\ 2. Rotation / mirror flag bits
\ ===========================================================================
\
\ Attribute 2 carries three transform bits (positions 3:1).  These
\ masks name them; OR them into _rotmir to rotate or flip a sprite.

%00000010 CONSTANT SPRITE-ROT
%00000100 CONSTANT SPRITE-VFLIP
%00001000 CONSTANT SPRITE-HFLIP

\ ===========================================================================
\ 3. Pattern buffer
\ ===========================================================================
\
\ A 256-byte scratch buffer.  We read one sprite pattern from the
\ file into it, then ship it to the pattern port.  Cleared once here.

CREATE SPRITE-BUFFER SPRITE-BUFLEN ALLOT
       SPRITE-BUFFER SPRITE-BUFLEN ERASE

\ ===========================================================================
\ 4. The sprite struct
\ ===========================================================================
\
\ +FIELD ( n1 <name> -- n2 ) defines a field at running offset n1 and
\ leaves the next offset n2.  Threading 0 through the chain gives each
\ field its offset; the final number is the total size, named here
\ SPRITE-OB.  At run time "addr _field" adds the field offset to addr.
\
\ Field -> hardware attribute mapping:
\   _spriteid  -> attribute 3, bits 5:0 (slot number; $C0 = visible)
\   _xcoord    -> attribute 0 (low 8 bits) + attribute 2 bit 0 (bit 8)
\   _ycoord    -> attribute 1
\   _rotmir    -> attribute 2, bits 3:1 (rotate / mirror flags)
\   _pattern   -> attribute 2, bits 7:4 (pattern slot, here unused = 0)
\   _anchor    -> attribute 4 area (anchor/relative; not used below)

0  2 +FIELD _spriteid   2 +FIELD _xcoord   2 +FIELD _ycoord
   1 +FIELD _rotmir     1 +FIELD _pattern  1 +FIELD _anchor
CONSTANT SPRITE-OB

CREATE SPRITE  SPRITE-OB ALLOT

\ ===========================================================================
\ 5. Uploading a pattern
\ ===========================================================================
\
\ Send 256 bytes starting at address a to the pattern port.  The
\ original Sprite Lib shipped a whole pattern with a single Z80
\ "otir", and so does this CODE word -- far faster than a Forth loop.
\ EXX swaps to the alternate register set so BC (the Forth IP) and HL
\ (W) survive without any stack traffic; the address is popped into
\ HL', BC' is loaded with SPRITE-PATTERN-PORT (high byte 0 = a count
\ of 256, low byte $5B = the port), OTIR streams the block, then a
\ second EXX restores the VM registers before NEXT.
\
\ The opcodes are written as raw hex C, literals (no ASSEMBLER
\ vocabulary needed); the mnemonics are kept in trailing comments.

CODE SPRITE-DATA>  ( a -- )
    $D9 C,                            \ exx
    $E1 C,                            \ pop hl
    $01 C,  SPRITE-PATTERN-PORT ,     \ ld bc, SPRITE-PATTERN-PORT
    $ED C,  $B3 C,                    \ otir
    $D9 C,                            \ exx
    $DD C,  $E9 C,                    \ jp (ix)   ( NEXT )
    SMUDGE

\ Write one attribute byte to the attribute port.
: SPRITE-ATTR   ( b -- )
    SPRITE-ATTRIBUTE-PORT P! ;

\ Select pattern slot id, then push the buffer's 256 bytes to it.
: SPRITE-INIT   ( id -- )
    SPRITE-SLOT-SELECT-PORT P!       \ select slot id
    SPRITE-BUFFER SPRITE-DATA> ;     \ upload its pattern

\ ===========================================================================
\ 6. Updating a sprite's attributes
\ ===========================================================================
\
\ Given the address of a SPRITE struct, select its slot and write the
\ four attribute bytes.  Attribute 2 is assembled from three pieces:
\ X bit 8, the rotate/mirror flags, and the pattern nibble.  The whole
\ word keeps the struct address on the stack and DROPs it at the end.

: SPRITE-UPDATE ( a -- )
    DUP  _spriteid C@ SPRITE-SLOT-SELECT-PORT P!   ( a )   \ select slot
    DUP  _xcoord     C@               SPRITE-ATTR  ( a )   \ attr 0: X low
    DUP  _ycoord     C@               SPRITE-ATTR  ( a )   \ attr 1: Y
    DUP  _xcoord 1+  C@  $01 AND                    ( a x8 )
    OVER _rotmir     C@  $0E AND  OR                ( a v2 )
    OVER _pattern    C@  $F0 AND  OR  SPRITE-ATTR   ( a )   \ attr 2
    DUP  _spriteid   C@  $C0      OR  SPRITE-ATTR   ( a )   \ attr 3: vis
    DROP ;

\ ===========================================================================
\ 7. Hiding a sprite
\ ===========================================================================
\
\ Selecting slot n then writing four zero attributes clears the
\ visible bit (attr 3 = 0), so the sprite disappears.

: SPRITE-HIDE   ( n -- )
    SPRITE-SLOT-SELECT-PORT P!
    0 SPRITE-ATTR  0 SPRITE-ATTR  0 SPRITE-ATTR  0 SPRITE-ATTR ;

\ ===========================================================================
\ 8. Loading patterns from a .spr file
\ ===========================================================================
\
\ OPEN< parses the file name from the input stream, opens it, and
\ leaves a file handle.  WARNING: OPEN< is interpreter-only and reads
\ the rest of the line, so SPRITE-LOAD< must be typed interactively
\ with the file name on the SAME line -- never call it from inside a
\ colon definition.
\
\ For each of the 64 sprite slots we read 256 bytes into the buffer
\ and upload them.  F_READ ( a n fh -- n f ) returns the bytes read
\ and an error/eof flag (f <> 0 means stop).  J fetches the open
\ file handle from the return stack (it sits under the loop index I).
\
\   SPRITE-BUFFER SPRITE-BUFLEN  J  F_READ   ( read-count flag )
\   IF LEAVE ELSE I SPRITE-INIT THEN  DROP   ( discard read-count )

: SPRITE-LOAD<  ( <file> -- )
    OPEN< >R                         ( )   \ open, save handle on R
    #64 0 DO                         ( )
        SPRITE-BUFFER SPRITE-BUFLEN  ( a n )
        J                            ( a n fh )
        F_READ                       ( count flag )
        IF    LEAVE                  ( count )   \ error/eof: stop
        ELSE  I SPRITE-INIT          ( count )   \ upload slot I
        THEN
        DROP                         ( )         \ drop read count
    LOOP
    R> F_CLOSE  #42 ?ERROR ;

\ ===========================================================================
\ 9. Turning the sprite engine on and off
\ ===========================================================================
\
\ $14 = global transparency colour ($E3 is the default magenta key);
\ $15 = sprite control: %00000011 enables sprites and draws them over
\ the border.  Palette, clock speed ($07), contention ($08) and the
\ sprite palette registers ($40/$41) are left at their defaults, so
\ the sprites use the default sprite palette.

: SPRITES-ON   ( -- )
    $E3 $14 REG!                     \ transparency colour
    #3  $15 REG! ;                   \ enable + over border

: SPRITES-OFF  ( -- )
    #0  $15 REG! ;                   \ disable sprites

\ ===========================================================================
\ 10. Timing helper
\ ===========================================================================
\
\ 1FRAME (core) waits exactly one 50Hz frame.  PAUSE waits n frames.

: PAUSE  ( n -- )
    0 ?DO 1FRAME LOOP ;

\ ===========================================================================
\ 11. Placing and animating (patterns must already be loaded)
\ ===========================================================================
\
\ These words assume SPRITE-LOAD< has already filled the pattern
\ slots (do that interactively first -- see section 12).
\
\ DISPLAY stores x, y and the slot id into the shared SPRITE struct and
\ pushes the attributes out.  With the stack ( x y id ), id is on top,
\ so it is stored first, then y, then x.

: DISPLAY  ( x y id -- )
    SPRITE _spriteid !               ( x y )   \ store id
    SPRITE _ycoord   !               ( x )     \ store y
    SPRITE _xcoord   !               ( )       \ store x
    SPRITE SPRITE-UPDATE ;

\ TEST sweeps one sprite across the screen, alternating between
\ pattern slots 0 and 1 (I 1 AND), four frames per step.

: TEST  ( -- )
    #60 0 DO
        I 1 AND  SPRITE _spriteid !  ( )   \ alternate slot 0/1
        I 4 *    SPRITE _xcoord !    ( )   \ march X right
        SPRITE SPRITE-UPDATE
        #4 PAUSE
    LOOP
    0 SPRITE-HIDE ;

\ ===========================================================================
\ 12. Trying it interactively
\ ===========================================================================
\
\ The pattern upload reads from a file, so it must be run by hand in
\ the interpreter (OPEN< grabs the file name from the line).  A full
\ session looks like this:
\
    SPRITES-ON
    SPRITE-LOAD<    tutorial/DKSprite.spr
    100 80 0 DISPLAY
    TEST
    SPRITES-OFF

\ ===========================================================================
\ 13. Tests
\ ===========================================================================
\
\ The sprite words write to hardware I/O ports and cannot be checked
\ automatically -- only the constant port numbers are testable.
\
\ NEEDS TESTING
\ T{  SPRITE-ATTRIBUTE-PORT     ->     87 }T
\ T{  SPRITE-SLOT-SELECT-PORT   ->  12347 }T
\ T{  SPRITE-PATTERN-PORT       ->     91 }T
\ T{  SPRITE-BUFLEN             ->    256 }T
