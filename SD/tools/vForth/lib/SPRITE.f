\
\ SPRITE.f
\
\ Hardware sprite engine (ZX Spectrum Next).  Extracted from tutorial
\ 053-more-sprites.f (confirmed on CSpect 2026-07-05) into a loadable
\ NEEDS SPRITE module -- the tutorial demonstrates the mechanism inline;
\ this is the same mechanism as a reusable library.  Only the general
\ engine is here: port constants, the sprite struct, pattern upload,
\ attribute update/hide, palette bring-up.  SPRITE-LOAD< (reading a
\ whole .spr file of 64 patterns) stays a tutorial-only convenience and
\ is NOT part of this module -- callers that build their own patterns
\ (e.g. from an existing UDG table) upload each one with SPRITE-INIT.
\
\ Reference: sec.3.4 (see tutorial 053 for the full walkthrough,
\ including the slot-vs-pattern and palette-offset gotchas -- also
\ documented in tutorial/CLAUDE.md section 16).
\

.( SPRITE )

MARKER NO-SPRITE

NEEDS +FIELD

\ ===========================================================================
\ 1. I/O ports and buffer length
\ ===========================================================================

$303B CONSTANT SPRITE-SLOT-SELECT-PORT
$0057 CONSTANT SPRITE-ATTRIBUTE-PORT
$005B CONSTANT SPRITE-PATTERN-PORT
 #256 CONSTANT SPRITE-BUFLEN

\ ===========================================================================
\ 2. Rotation / mirror flag bits (attribute 2, bits 3:1)
\ ===========================================================================

%00000010 CONSTANT SPRITE-ROT
%00000100 CONSTANT SPRITE-VFLIP
%00001000 CONSTANT SPRITE-HFLIP

\ ===========================================================================
\ 3. Pattern buffer -- one pattern (256 bytes) staged here, then shipped
\ ===========================================================================

CREATE SPRITE-BUFFER SPRITE-BUFLEN ALLOT
       SPRITE-BUFFER SPRITE-BUFLEN ERASE

\ ===========================================================================
\ 4. The sprite struct -- see tutorial 053 section 4 for the field ->
\ hardware attribute mapping and the _spriteid/_pattern naming gotcha
\ (_spriteid is the PATTERN shown, not the hardware SLOT).
\ ===========================================================================

0  2 +FIELD _spriteid   2 +FIELD _xcoord   2 +FIELD _ycoord
   1 +FIELD _rotmir     1 +FIELD _pattern  1 +FIELD _anchor
CONSTANT SPRITE-OB

\ Shared scratch struct.  Callers that need to program more than one
\ sprite between fills should re-fill and SPRITE-UPDATE per slot -- the
\ struct itself is not slot-specific (the slot is SPRITE-UPDATE's own
\ argument), so nothing here needs one struct per slot.

CREATE SPRITE  SPRITE-OB ALLOT
       SPRITE  SPRITE-OB ERASE

\ ===========================================================================
\ 5. Uploading a pattern (see tutorial 053 section 5 for the OTIR detail)
\ ===========================================================================

CODE SPRITE-DATA>  ( a -- )
    $D9 C,                            \ exx
    $E1 C,                            \ pop hl
    $01 C,  SPRITE-PATTERN-PORT ,     \ ld bc, SPRITE-PATTERN-PORT
    $ED C,  $B3 C,                    \ otir
    $D9 C,                            \ exx
    $DD C,  $E9 C,                    \ jp (ix)   ( NEXT )
    SMUDGE

: SPRITE-ATTR   ( b -- )
    SPRITE-ATTRIBUTE-PORT P! ;

\ Select pattern slot id, then push SPRITE-BUFFER's 256 bytes to it.
: SPRITE-INIT   ( id -- )
    SPRITE-SLOT-SELECT-PORT P!
    SPRITE-BUFFER SPRITE-DATA> ;

\ ===========================================================================
\ 6. Updating a sprite's attributes (tutorial 053 section 6)
\ ===========================================================================

: SPRITE-UPDATE ( a n -- )
    SPRITE-SLOT-SELECT-PORT P!                     ( a )   \ select slot n
    DUP  _xcoord     C@               SPRITE-ATTR  ( a )   \ attr 0: X low
    DUP  _ycoord     C@               SPRITE-ATTR  ( a )   \ attr 1: Y
    DUP  _xcoord 1+  C@  $01 AND                    ( a x8 )
    OVER _rotmir     C@  $0E AND  OR                ( a v2 )
    OVER _pattern    C@  $F0 AND  OR  SPRITE-ATTR   ( a )   \ attr 2
    DUP  _spriteid   C@  $C0      OR  SPRITE-ATTR   ( a )   \ attr 3: pat+vis
    DROP ;

\ ===========================================================================
\ 7. Hiding a sprite (tutorial 053 section 7)
\ ===========================================================================

: SPRITE-HIDE   ( n -- )
    SPRITE-SLOT-SELECT-PORT P!
    0 SPRITE-ATTR  0 SPRITE-ATTR  0 SPRITE-ATTR  0 SPRITE-ATTR ;

\ ===========================================================================
\ 8. Turning the sprite engine on and off (tutorial 053 section 9)
\ ===========================================================================
\
\ SPRITE-PALETTE-INIT here is the same identity default the tutorial
\ uses ($40/$41/$43, colour i = i).  A caller with its own colour
\ scheme (e.g. a game reusing 3-bit ink numbers via the palette-offset
\ attribute) should overwrite the palette itself right after SPRITES-ON
\ -- see chomp-chomp-next's MOB-PALETTE-INIT for a worked example, and
\ the caution about $E3/identity colliding with a real foreground
\ colour once the palette is no longer the identity mapping.

: SPRITE-PALETTE-INIT  ( -- )
    %00100000 $43 REG!               \ r/w + show sprite 1st palette
    0 $40 REG!                       \ palette index 0
    #256 0 DO  I $41 REG!  LOOP ;    \ identity: colour i = i

: SPRITES-ON   ( -- )
    SPRITE-PALETTE-INIT
    $E3 $14 REG!                     \ transparency colour (identity default)
    #3  $15 REG! ;                   \ enable + over border

: SPRITES-OFF  ( -- )
    #0  $15 REG! ;                   \ disable sprites
