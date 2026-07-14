\
\ 056-layer2-palette.f
\ Layer 2 palette: registers $40/$41/$43/$44, first vs second bank,
\ palette-swap effects, 9-bit colors and per-pixel priority, and the
\ Global Transparency register $14.
\
\ Every Layer 2 pixel byte (as seen in tutorial 037) is not a color:
\ it is an INDEX into a 256-entry palette.  The palette itself is a
\ separate table of RRRGGGBB (or 9-bit) values, programmed through
\ four Next hardware registers.  This tutorial covers only the Layer 2
\ side of that mechanism -- ULA, Sprites and Tilemap have their own
\ palettes, addressed the same way but selected by different bits (see
\ the dev guide for those).
\
\ vForth rarely touches palettes today: the one existing example is
\ lib/AUTOEXEC.f's SET-PALETTE, which recolors the ULA splash screen
\ and is FORGETten right after use (not a reusable word).  This
\ tutorial is the first to work through the mechanism in the open.
\
\ No section of the vForth manual documents palettes yet (there is no
\ PALETTE entry under "Colors & Attributes").  Authoritative source is
\ the ZX Spectrum Next Developer's Guide & Reference Manual rev.3
\ (doc/zx-next-dev-guide-r3.txt in this repo): section 3.4 "Palette",
\ printed pages 60-66 (registers $40/$41/$43/$44 on pages 63-65), and
\ section 3.6.4 "Effects" / double-buffering note, printed page 73-74.
\
\ Reference: no vForth manual section yet (extension)
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   056 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 056 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 056: Layer 2 palette loaded. ) CR
.(     Type NEWTASK to unload.              ) CR

NEEDS GRAPHICS
NEEDS TO
NEEDS WAIT-KEY
NEEDS J

\ ===========================================================================
\ 1. The four palette registers
\ ===========================================================================
\
\ REG! ( b n -- ) and REG@ ( n -- b ) are core words (src/F18e.f) that
\ write/read a Next hardware register: no NEEDS required.  Palettes
\ are programmed through four of them:
\
\   $40  Palette Index    -- selects the color index (0-255) to edit
\   $41  Palette Value    -- 8-bit RRRGGGBB read/write for that index
\   $43  Enhanced ULA Control -- selects WHICH palette is being edited
\                                (layer + bank) and which bank of each
\                                layer is currently ON SCREEN
\   $44  Palette Extension -- 9-bit color (two writes) + Layer 2
\                              per-pixel priority bit
\
\ PATTERN (dev guide sec.3.4.2, page 61):
\   1. Write $43 to choose the palette to edit
\   2. Write $40 with the index to touch
\   3. Write $41 (or $44 twice) with the color; if $43 bit 7 is 0
\      (auto-increment enabled), the index in $40 advances by itself
\      so a whole palette can be streamed with one loop.
\
\ GOTCHA: reading $41 does NOT auto-increment (only writing does), so
\ a read loop must rewrite $40 before every PAL-COLOR@.

$40 CONSTANT PAL-INDEX
$41 CONSTANT PAL-VALUE
$43 CONSTANT PAL-CONTROL
$44 CONSTANT PAL-EXT

: PAL-INDEX!  ( idx -- )    PAL-INDEX REG! ;
: PAL-COLOR!  ( color -- )  PAL-VALUE REG! ;
: PAL-COLOR@  ( -- color )  PAL-VALUE REG@ ;

\ ===========================================================================
\ 2. First vs second bank: choosing what $43 does
\ ===========================================================================
\
\ Every layer (ULA, Layer 2, Sprites, Tilemap) has TWO independent
\ palette banks; only one of the two is shown on screen at a time.
\ $43 packs three unrelated things in one byte -- writing it for one
\ purpose can silently disturb another if you are not explicit about
\ every bit:
\
\   bit 7    0 = auto-increment $40 on write (usual choice), 1 = off
\   bits 6-4 which palette is the EDIT target (dev guide table,
\            page 65): Layer 2 first = %001, Layer 2 second = %101
\   bit  2   which Layer 2 bank is currently ON SCREEN
\            (0 = first, 1 = second) -- independent of the edit target
\
\ Because a single write sets all of these together, this tutorial
\ always writes the whole byte rather than trying to flip one bit.

%00010000 CONSTANT PAL-EDIT-L2-1ST  \ $10: edit target = L2 first bank
%01010000 CONSTANT PAL-EDIT-L2-2ND  \ $50: edit target = L2 second bank
%00010100 CONSTANT PAL-SHOW-L2-2ND  \ $14: on screen = L2 second bank
%00100000 CONSTANT PAL-RESET-BYTE   \ $20: power-on default (see below)

: PAL-EDIT-1ST  ( -- )  PAL-EDIT-L2-1ST  PAL-CONTROL REG! ;
: PAL-EDIT-2ND  ( -- )  PAL-EDIT-L2-2ND  PAL-CONTROL REG! ;
: PAL-SHOW-1ST  ( -- )  PAL-EDIT-L2-1ST  PAL-CONTROL REG! ;  \ bit2=0
: PAL-SHOW-2ND  ( -- )  PAL-SHOW-L2-2ND  PAL-CONTROL REG! ;

\ PAL-RESET-BYTE matches the reset value documented in tutorial 053
\ (sprite palette init): edit target = Layer 2 first bank, every
\ layer's on-screen bank = first, ULANext off, auto-increment on.
: PAL-RESET  ( -- )  PAL-RESET-BYTE  PAL-CONTROL REG! ;

\ ===========================================================================
\ 3. Reading back the default palette
\ ===========================================================================
\
\ Next initializes every palette to the "identity" mapping: color
\ index i has RGB value i (see also tutorial 053's palette note about
\ the sprite palette).  We can verify this on Layer 2's first bank.

: CHECK-IDENTITY  ( -- )
    PAL-EDIT-1ST
    CR ." Layer 2 first palette, default identity check:" CR
    8 0 DO
        I 32 * PAL-INDEX!         ( -- )       \ select index I*32
        PAL-COLOR@                 ( color )
        ." index " I 32 * 3 .R  ."  -> " DUP .  ( color )
        I 32 * =                   ( flag )
        IF ."  OK" ELSE ."  FAIL" THEN
        CR
    LOOP
;

.( Try CHECK-IDENTITY to confirm the power-on palette. )

\ ===========================================================================
\ 4. Writing a custom palette
\ ===========================================================================
\
\ Because pixel data only stores an INDEX, repainting the palette
\ changes the whole picture without touching a single pixel.  This
\ demo fills the screen with each index 0-255 (via PLOT, tutorial 037
\ style) using the untouched default palette, then rewrites the first
\ bank to an inverted palette and shows the same pixel data again.

: SETUP  ( -- )
    LAYER2  CLS
;

: RESTORE-IDENTITY  ( -- )  \ color(i) := i, both Layer 2 banks
    PAL-EDIT-1ST  0 PAL-INDEX!
    256 0 DO  I PAL-COLOR!  LOOP
    PAL-EDIT-2ND  0 PAL-INDEX!
    256 0 DO  I PAL-COLOR!  LOOP
;

: UNSETUP  ( -- )
    RESTORE-IDENTITY
    PAL-RESET
    LAYER12  _BLUE .PAPER
;

: FILL-INDEX-MAP  ( -- )  \ pixel (x,y) gets color index (x+y) mod 256
    256 0 DO
        192 0 DO
            J I + 255 AND TO ATTRIB
            I J PLOT
        LOOP
    LOOP
;

: INVERT-1ST-PALETTE  ( -- )  \ color(i) := 255 - i, whole first bank
    PAL-EDIT-1ST
    0 PAL-INDEX!               \ auto-increment starts from index 0
    256 0 DO
        255 I -  PAL-COLOR!
    LOOP
;

: PALETTE-REPAINT-DEMO  ( -- )
    SETUP
    FILL-INDEX-MAP
    CR .( Default identity palette -- press a key for the inverted one.)
    WAIT-KEY
    INVERT-1ST-PALETTE
    CR .( Same pixels, inverted palette -- press a key to finish.)
    WAIT-KEY
    UNSETUP
;

\ ===========================================================================
\ 5. Palette-swap effects: instant, flicker-free color changes
\ ===========================================================================
\
\ Tutorial 046 double-buffers PIXEL DATA (two Layer 2 RAM pages) to
\ avoid tearing while loading a new image.  The same idea works for
\ COLOR: prepare an alternate palette in the second bank while the
\ first is on screen, then flip the single active bit in $43.  No
\ pixel is rewritten, so the whole picture changes color in one
\ frame -- useful for day/night, flash, or fade-style effects.

: DIM-2ND-PALETTE  ( -- )  \ color(i) := identity, halved brightness
    PAL-EDIT-2ND
    0 PAL-INDEX!               \ auto-increment starts from index 0
    256 0 DO
        I  %10110110 AND  PAL-COLOR!   \ drop msb of each RGB field
    LOOP
;

23672 CONSTANT FRAMES-ADDR   \ ZX Spectrum 50Hz frame counter, $5C78

\ Wait half a second (25 frames), or until [BREAK] is pressed
: SWAP-DELAY  ( -- )
    0 FRAMES-ADDR !
    FRAMES-ADDR @ 25 +
    BEGIN
        DUP FRAMES-ADDR @ U<
        ?TERMINAL OR
    UNTIL
    DROP
;

: PALETTE-SWAP-DEMO  ( -- )
    SETUP
    FILL-INDEX-MAP
    DIM-2ND-PALETTE
    CR .( Flipping between full and dimmed palette -- [BREAK] to stop.)
    BEGIN
        PAL-SHOW-2ND  SWAP-DELAY
        PAL-SHOW-1ST  SWAP-DELAY
        ?TERMINAL
    UNTIL
    UNSETUP
;

\ ===========================================================================
\ 6. 9-bit colors and per-pixel priority ($44)
\ ===========================================================================
\
\ $44 gives each color a third bit per RGB component (9-bit color
\ instead of 8-bit) via two consecutive writes; ONLY for Layer 2, the
\ second write's bit 7 is a per-pixel PRIORITY flag: when set, that
\ color always renders above every other layer, regardless of the
\ normal layer ordering (Sprite and Layers System $15 -- a separate
\ topic, not covered here).
\
\   1st write to $44: R2 R1 R0 G2 G1 G0 B2 B1   (same layout as $41)
\   2nd write to $44: Pr  0  0  0  0  0  0  B0  (Pr = priority, L2 only)
\
\ Reading $44 always returns the 2nd byte (B0 + priority) and never
\ auto-increments; read the RGB part back through PAL-VALUE ($41).

: PAL-COLOR9!  ( rggb priority-and-b0 -- )
    SWAP  PAL-EXT REG!
          PAL-EXT REG!
;

\ Example: give index 200 a 9-bit red with the priority bit set, so
\ it would stay on top of other layers once $15 is configured to let
\ Layer 2 compete for priority (left as an exercise -- out of scope):
\   PAL-EDIT-1ST
\   200 PAL-INDEX!
\   %11100000 %10000000 PAL-COLOR9!

\ ===========================================================================
\ 7. Global Transparency $14
\ ===========================================================================
\
\ One color index per Global Transparency $14 is not drawn at all:
\ pixels using that index let whatever is behind Layer 2 show through
\ instead.  This single register is shared by Layer 2, ULA and LoRes.
\ Default after reset is $E3 (also the default sprite transparency
\ index -- see tutorial/CLAUDE.md sec.16).  Seeing the effect requires
\ deciding what sits behind Layer 2 (layer ordering, $15), so this
\ tutorial only shows how to read and change the index:

$14 CONSTANT L2-TRANSPARENT

: TRANSPARENT@  ( -- idx )  L2-TRANSPARENT REG@ ;
: TRANSPARENT!  ( idx -- )  L2-TRANSPARENT REG! ;

.( Try  TRANSPARENT@ .  to see the current transparent index. )

\ ===========================================================================
\ 8. Cleanup
\ ===========================================================================
\
\   UNSETUP (called at the end of both demos) runs RESTORE-IDENTITY,
\   which rewrites color(i) := i into BOTH Layer 2 banks, then
\   PAL-RESET, which puts $43 back to its power-on default (section
\   2).  Neither touches ULA/Sprites/Tilemap palettes.  Run
\   CHECK-IDENTITY afterwards if in doubt.

.( Try PALETTE-REPAINT-DEMO or PALETTE-SWAP-DEMO. )

\ ===========================================================================
\ 9. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ NEEDS TESTING
\ T{  PAL-EDIT-1ST  0 PAL-INDEX!  PAL-COLOR@  ->  0  }T
