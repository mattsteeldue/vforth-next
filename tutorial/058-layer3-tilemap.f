\
\ 058-layer3-tilemap.f
\ The Tilemap hardware layer ("Layer 3"): a dedicated 40x32 or 80x32
\ character-cell layer, distinct from Layer 0/ULA, Layer 2, and Sprites.
\
\ Every tile is an 8x8-pixel bitmap picked from up to 256 (or 512)
\ definitions, painted through its own 16-colour palette -- like the
\ ULA's character/attribute model, but with hardware scrolling-free
\ freedom from the ULA's fixed 32x24 grid, and a second, higher-density
\ 80-column mode.  This tutorial extracts and explains the technique
\ shared by the working demos in demo/Layer3-demo1/2/3.f and the two
\ refactored library modules that grew out of them, lib/LAYER3.f
\ (mode/palette switching) and lib/TILE80.f (a full tilemap-based text
\ console).
\
\ vForth-specific notes:
\   - There is no lightweight "just switch to this layer" word here,
\     unlike LAYER0/LAYER2/LAYER12 (tutorial/CLAUDE.md section 13):
\     NEEDS LAYER3 is the only entry point, and it is already fairly
\     light (mode + palette switching only -- no PLOT/DRAW-LINE, the
\     tilemap has no vectored graphic primitives in this codebase).
\   - The tile grid and tile definitions are conventionally placed at
\     $4000 and up -- the SAME physical memory vForth's own default
\     console (LAYER12) uses for its display file.  Building the data
\     (sections 6-7) briefly scrambles whatever is on screen; this is
\     expected, not a bug -- see the gotcha in section 9.
\   - Tile index arithmetic quietly depends on which tile-defs base you
\     picked; section 4 works through the one real gotcha in the demos
\     (the "-4"/"-1" adjustment) so it stops looking like magic.
\
\ Reference: no vForth manual section yet (extension). Hardware
\ authority: ZX Spectrum Next Developer's Guide & Reference Manual
\ rev.3 (doc/zx-next-dev-guide-r3.md), section 3.7 "Tile Mode",
\ printed pages 85-86 (concepts), registers $6B/$6C/$6E/$6F on
\ printed page 91-92, and the Enhanced ULA Control $43 palette-target
\ table on printed page 65 (section 3.4, also used by tutorial 056).
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   058 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 058 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 058: Layer 3 tilemap loaded. ) CR
.(     Type NEWTASK to unload.              ) CR

NEEDS LAYER3
NEEDS SPLIT
NEEDS PAD"
NEEDS LOAD-BYTES
NEEDS WAIT-KEY
NEEDS LAYER12

\ =============================================================================
\ 1. What is the Tilemap layer?
\ =============================================================================
\
\ Tilemap ("Layer 3" in this project's naming, tutorial/CLAUDE.md's
\ Layer-family numbering) is a separate hardware layer, always present
\ in bank 5 of Next RAM (normally mapped into $4000-$7FFF, same as the
\ ULA screen): a grid of TILES, each an 8x8-pixel block chosen from a
\ table of DEFINITIONS, each pixel an index into a 16-colour palette.
\ It overlaps the ULA by 32 pixels on every side, covering the full
\ screen including the border -- dev guide sec.3.7, printed page 85.
\
\ Two data structures make it up:
\   - TILE DEFINITIONS: the 8x8 bitmaps themselves, up to 256 of them
\     (512 in an extended mode this tutorial does not use).
\   - TILEMAP DATA: one entry per grid cell, naming which definition
\     to show there (plus, optionally, a per-tile attribute byte).
\
\ Two grid resolutions are available:
\   40x32 tiles  -- lower-density, 2 bytes per cell (index + attribute:
\                   per-tile palette offset, mirror, rotate, priority)
\   80x32 tiles  -- higher-density; commonly used WITHOUT the attribute
\                   byte (see section 3), trading per-tile attributes
\                   for half the tilemap memory and finer detail.
\
\ Unlike Layer 2 (tutorial 037), Tilemap has no vectored PLOT/DRAW-LINE
\ in this codebase: you write tile INDEX bytes directly into the grid.
\ Used as a character-cell layer this is naturally suited to fast text
\ output, which is exactly what section 8's capstone builds.


\ =============================================================================
\ 2. The registers: $6B, $6C, $6E, $6F, and $68 bit 7
\ =============================================================================
\
\ Four Next registers configure Tilemap (dev guide printed page 91-92):
\
\ Tilemap Control $6B
\   bit 7   1 = enable tilemap, 0 = disable
\   bit 6   1 = 80x32 columns, 0 = 40x32
\   bit 5   1 = NO per-tile attribute byte (1 byte/cell instead of 2)
\   bit 4   1 = second tilemap palette, 0 = first
\   bit 3   1 = "text mode" -- tiles are 1-bit B&W bitmaps (8 bytes
\               each), like classic Spectrum UDGs; see section 8
\   bit 1   1 = 512-tile mode (unused here)
\   bit 0   1 = force tilemap on top of ULA
\
\ Default Tilemap Attribute $6C -- read only when $6B bit 5 = 1 (no
\ per-tile attribute byte): applies the SAME attribute to every tile.
\   bits 7-4  palette offset      bit 1  rotate 90 clockwise
\   bit  3    mirror X            bit 0  ULA-over-tilemap priority
\   bit  2    mirror Y
\
\ Tilemap Base Address $6E / Tile Definitions Base Address $6F -- each
\ holds the MOST SIGNIFICANT BYTE of an offset from $4000 (bank 5's
\ start): address = $4000 + (register << 8).  Because only the top
\ byte is stored, data can only start on a 256-byte boundary.
\
\ ULA Control $68 bit 7 -- NOT a tilemap register, but every demo in
\ this codebase writes it alongside $6B: it blanks the ULA plane
\ entirely, so text/graphics already on screen do not show through
\ (and are not scrambled-looking) once the tilemap takes over.


\ =============================================================================
\ 3. The vForth API: NEEDS LAYER3
\ =============================================================================
\
\ lib/LAYER3.f (already loaded above) defines four ready-made modes and
\ two palettes, built from exactly the register values section 2 just
\ explained:
\
\   TILE-OFF   ( -- )   disable tilemap, restore ULA
\   TILE-40    ( -- )   enable 40x32, WITH per-tile attribute byte,
\                       tile defs at $4A00, grid at $4000
\   TILE-80    ( -- )   enable 80x32, no attribute byte, defs at $5400
\   TILE-TXT   ( -- )   enable 80x32 "text mode" (1-bit tiles), defs
\                       at $5400 too -- the mode section 8's console
\                       runs in
\
\   SET-PAL  ( colour index -- )   write one palette entry
\   GET-PAL  ( index -- colour )   read one palette entry
\   TILE-40-PALETTE / TILE-80-PALETTE / TILE-TXT-PALETTE  ( -- )
\       preloaded 8/8/2-colour palettes matching each mode
\
\ These four mode words already write $6E/$6F for you (whenever the
\ mode enables the layer) -- unlike the earliest demo (Layer3-demo1.f),
\ which called a separate ...-BASE word first.  Section 4 shows why
\ that consolidation was possible and safe.


\ =============================================================================
\ 4. Under the hood: TILE-MODE: and TILE-PALETTE:
\ =============================================================================
\
\ TILE-40/TILE-80/TILE-TXT/TILE-OFF are not four separate hand-written
\ words: they are four instances of one CREATE...DOES> defining word
\ (tutorial 010), TILE-MODE:, each CREATEd with its own four register
\ bytes stored in its PFA:
\
\   $00 $06 $80 %10000001  TILE-MODE:  TILE-40   \ 40 col, defs $4A00
\   $00 $13 $80 %11001001  TILE-MODE:  TILE-80   \ 80 col, defs $5400
\
\ Reading the DOES> body (lib/LAYER3.f) tells you, unambiguously, which
\ literal ends up where -- more reliably than the word's own stack
\ comment, whose four parameter names do not line up with the storage
\ order:  the DOES> writes byte 0 to $6B, byte 1 to $68, byte 2 to
\ $6F, byte 3 to $6E, and CREATE's four C, calls consume the stack
\ LAST-typed-first (as any C, sequence does).  Net effect: reading an
\ invocation left to right, the FIRST literal becomes the $6E value,
\ the second becomes $6F, the third becomes $68, and the LAST
\ (rightmost) becomes $6B.  Practically: to add a new mode, copy an
\ existing line and change only the name and the four literals in
\ place -- do not try to re-derive the order from the stack comment.
\
\ This is also why the base-address write folded cleanly into the mode
\ word: TILE-MODE:'s DOES> only writes $6F/$6E "when n68 is non-zero"
\ (i.e. only when the mode is actually enabling the layer), so TILE-OFF
\ can safely pass $00 $00 for both without ever touching them.
\
\ TILE-PALETTE: (also in lib/LAYER3.f) is the same idea for palettes:
\ CREATE stores a pair COUNT and a list of colour/index bytes (via the
\ helper PAL, ( colour index -- )); DOES> loops SET-PAL over them after
\ selecting the tilemap as $43's edit target (section 5).  TILE-40-
\ PALETTE, TILE-80-PALETTE and TILE-TXT-PALETTE are three such tables,
\ 8, 8, and 2 colour/index pairs respectively -- open lib/LAYER3.f to
\ see the exact values used below.


\ =============================================================================
\ 5. Selecting the Tilemap palette in $43
\ =============================================================================
\
\ Tutorial 056 covers the general four-register palette mechanism
\ ($40 index, $41 value, $43 edit-target-and-active-bank, $44
\ extension) in depth for Layer 2; the same mechanism serves every
\ layer, selected by different bits of $43 -- dev guide printed
\ page 65.  The only Tilemap-specific fact needed here: bits 6-4 of
\ $43 select the palette being EDITED, and the Tilemap values are
\   %011  Tilemap first palette
\   %111  Tilemap second palette
\ lib/LAYER3.f's TILE-PALETTE-SELECT-1ST does exactly this, preserving
\ every other bit of $43 (auto-increment, and the per-layer ON-SCREEN
\ bank selects tutorial 056 section 2 explains):
\
\   : TILE-PALETTE-SELECT-1ST ( -- )
\       $43 REG@  %10001111 AND  %00110000 OR  $43 REG!
\   ;
\
\ TILE-40/80-PALETTE's colour bytes are RRRGGGBB, same encoding as
\ tutorial 037/056; TILE-TXT-PALETTE only fills index 0 and 1 (see
\ section 8 -- "text mode" tiles are 1-bit, so only two colours exist
\ per tile no matter how big the palette is).


\ =============================================================================
\ 6. Building tile definitions from the ROM charset (40-column, live)
\ =============================================================================
\
\ The ROM character set ($5C36 is the CHARS system variable; +256
\ skips its 32-byte offset to the first PRINTABLE character bitmap)
\ is 1 bit per pixel.  40-column tiles need 4 bits per pixel (to reach
\ the 16-colour palette), so each ROM byte must be expanded 1 bit ->
\ 1 nibble: TILE-40-BIT turns one 8-pixel ROM row into two full bytes
\ (4 nibbles), assigning palette entry 6 to set bits (ink) and entry 1
\ to clear bits (paper) -- exactly the pair TILE-40-PALETTE defines at
\ indices $x6/$x1 for each of the four 4-colour "banks" it preloads.

: TILE-40-BIT     ( b -- n1 n2 n3 n4 )
    7 LSHIFT               \ align pattern to the sign bit
    0 0
    8 0 DO
        2DUP D+ 2DUP D+ 2DUP D+ 2DUP D+   \ 4x lshift on the 32-bit acc
        ROT DUP + DUP                     \ shift pattern; test old bit14
        0< IF -ROT   06 0 D+              \ set pixel  -> palette entry 6
        ELSE -ROT    01 0 D+              \ clear pixel -> palette entry 1
        THEN
    LOOP
    ROT DROP                \ discard the shifted pattern copy
    SPLIT   ROT              \ nHL nHH dL
    SPLIT   2SWAP ;          \ nLL nLH nHL nHH

\ Tile definitions land at a FIXED $4A00, 32 bytes/tile (8 rows x 4
\ bytes), covering the printable ASCII range.  TILE-40's $6F value is
\ $06, not the $0A the plain (address-$4000)>>8 formula would give for
\ $4A00: this is the "-4" adjustment.  TILE-40-EXAMPLE below uses the
\ RAW ASCII CODE as the tile index (not a compacted 0-based one), so
\ the base register must be programmed 4 MSB-units (4 x 256 = 1024
\ bytes) LOWER than $4A00's own MSB, exactly enough to skip the 32
\ unused low indices x 32 bytes/tile = 1024 bytes.  (Section 8's
\ 1-bit-per-pixel 80-column tiles are only 8 bytes each, so there the
\ same 32-index skip is just 256 bytes = 1 MSB-unit -- lib/LAYER3.f's
\ $13 for TILE-80/TILE-TXT is exactly $14 minus that single unit.)
\ You do not need to recompute this for TILE-40/80/TXT -- it is baked
\ into lib/LAYER3.f already; know it is there before defining a mode
\ with a different tile size, where the adjustment would differ again.

: TILE-40-DEF    ( -- )
    $5C36 @ #256 +           \ ROM charset address, printable range
    $5600 $4A00 DO
        DUP C@
        TILE-40-BIT           \ one ROM byte -> 4 destination bytes
        I     C!
        I 1+  C!
        I 2+  C!
        I 3 + C!
        1+
    4 +LOOP DROP
;

\ A simple example grid: fill the 40x32 tilemap with the printable
\ ASCII range, alternating two of the palette's four colour banks.

: TILE-40-EXAMPLE  ( -- )
    $4000  #40 #32 * 2*  ERASE          \ 2560 bytes = $0A00
    #40 #32 * 2*  0 DO
        I 2/ #96 MOD #32 +   I  $4000 + C!   \ tile index = ASCII code
        I 7 AND 3 LSHIFT     I  $4001 + C!   \ attribute: pick a bank
    2 +LOOP
;

: TILE3-40-DEMO  ( -- )
    CLS
    TILE-40-PALETTE
    TILE-40-DEF
    TILE-40-EXAMPLE
    TILE-40
    WAIT-KEY
    TILE-OFF  LAYER12 CLS
;

CR .( Try:  TILE3-40-DEMO ) CR


\ =============================================================================
\ 7. The persisted-asset alternative: SAVE-BYTES once, LOAD-BYTES always
\ =============================================================================
\
\ Regenerating the charset from ROM every time (section 6) is cheap
\ but unnecessary once the result is known-good: SAVE-BYTES it to a
\ file (tutorial 042; the same LOAD2BLOCK-adjacent idea as tutorial
\ 063's BLOCK-as-asset technique) and just LOAD-BYTES it back from
\ then on.  demo/Layer3-demo2-setup.f does exactly this once (it must
\ run under the non-dot vForth variant) and writes five .bin files
\ into demo/; demo/Layer3-demo2.f (and demo3.f, section 4) just
\ LOAD-BYTES them.  The 80-column charset/example pair used below are
\ two of those five, already shipped in this repository.
\
\ PATH GOTCHA (tutorial 046): the filename passed to LOAD-BYTES is
\ relative to the directory vForth was STARTED from, not to this
\ tutorial file's own location.

: TILE3-80-DEMO  ( -- )
    CLS
    TILE-80-PALETTE

    PAD" demo/Layer3-charset-80.bin"
    $5400 #1792 LOAD-BYTES

    PAD" demo/Layer3-example-80.bin"
    $4000 #5120 LOAD-BYTES

    TILE-80
    WAIT-KEY
    TILE-OFF  LAYER12 CLS
;

CR .( Try:  TILE3-80-DEMO ) CR

: DEMO  ( -- )
    TILE3-40-DEMO
    TILE3-80-DEMO
;

CR .( Try:  DEMO   for both, one after the other ) CR


\ =============================================================================
\ 8. Capstone: a tilemap text console (NEEDS TILE80)
\ =============================================================================
\
\ lib/TILE80.f turns TILE-TXT (80x32, 1-bit tiles, section 2-3) into a
\ complete replacement text console: scrolling, backspace, the classic
\ AT-y,x escape sequence -- and wires it in by taking over EMIT, EMITC
\ and CLS themselves.
\
\ It does NOT use DEFER/IS (tutorial 017).  EMIT/EMITC/CLS were never
\ DEFERred in the first place; each is an ordinary colon-definition
\ whose entire body is a single call (src/F18e.f):
\
\   : emitc  ( -- )  (emitc) ;
\   : cls    ( -- )  (cls)   ;
\
\ A colon-definition's PARAMETER FIELD (>BODY, root CLAUDE.md's
\ Dictionary Structure section) is just the thread of calls it makes;
\ for a single-call body like these, that thread is one cell.
\ Overwriting that one cell with a different execution token turns
\ "call (emitc)" into "call T-EMITC" without touching EMITC's own
\ header -- the exact idiom tutorial 049 uses to install an interrupt
\ handler (['] FOO HANDLER !), applied here to three core words that
\ happen to already be trivial enough to double as vector cells:
\
\   ['] T-EMITC   ['] EMITC >BODY !
\   ['] T-EMIT    ['] EMIT  >BODY !
\   ['] T-CLS     ['] CLS   >BODY !
\
\ NOTE: this REPLACES EMIT's own logic wholesale, including whatever
\ (?emit)'s character-conversion table normally does -- T-EMIT talks
\ to T-EMITC directly.  NO-TILE (below) restores the original three
\ targets the same way, so nothing about EMIT/CLS is permanently lost.
\
\ Its own driver words -- T-CLS, T-HOME, T-SCROLL, T-CR, T-BS, T-XY --
\ implement a proper 80x32 scrolling console over the tile grid built
\ in section 6-7's style (T-HOME LOAD-BYTES's the pre-built charset
\ from lib/TILE80-CHARSET.bin, already shipped).  T-DECODE also
\ recognises the classic two-byte AT escape (chr 22, row, column),
\ exactly like Spectrum BASIC's PRINT AT.
\
\ Try it (not run automatically by this tutorial -- it takes over the
\ console you are reading this from):
\
\   NEEDS TILE80
\   TILE80                 \ activates the tilemap console
\   .( Hello from Layer 3! )
\   NO-TILE                 \ back to the normal LAYER12 prompt


\ =============================================================================
\ 9. Gotchas
\ =============================================================================
\
\ - Building tile data at $4000+ (sections 6-7) briefly scrambles the
\   visible screen if run while LAYER12 is the active console: the
\   writes land in memory LAYER12 may currently be displaying, before
\   TILE-40/TILE-80 hides the ULA plane ($68 bit 7, section 2) and
\   shows the tilemap instead.  Not a bug -- Next ties tilemap memory
\   to a fixed offset in bank 5 (dev guide sec.3.7.3, "Memory
\   Organization", printed page 86), which vForth's default text layer
\   happens to share.  TILE-OFF + LAYER12 CLS (as every DEMO word here
\   does) cleanly restores the console afterward.
\ - 40-column and 80-column/text-mode tile DEFINITIONS are not
\   interchangeable formats: 40-column is 4 bits/pixel (32 bytes/tile),
\   80-column/text is 1 bit/pixel (8 bytes/tile).  Loading one format's
\   .bin at the other mode's base address produces visible garbage, not
\   an error -- there is no format tag anywhere to catch the mismatch.
\ - TILE-TXT-PALETTE only has two entries (index 0/1): text-mode tiles
\   are 1-bit, so a third or fourth colour has nowhere to go no matter
\   how many entries you SET-PAL.
\ - lib/TILE80-setup.f's own header says it "must run with non-dot
\   vForth" -- but you should not normally need to run it at all: its
\   output, lib/TILE80-CHARSET.bin, already ships in this repository
\   (used automatically by T-HOME, section 8).  Only re-run it if you
\   are deliberately changing the ROM charset it draws from.
\ - TILE-MODE:'s own stack comment in lib/LAYER3.f does not match its
\   actual argument order -- see section 4 before adding a new mode.


\ =============================================================================
\ 10. Further reading
\ =============================================================================
\
\ demo/Layer3-demo1.f          self-contained: builds everything live
\                              from ROM every run (section 6's source).
\ demo/Layer3-demo2-setup.f    one-shot: writes the five .bin assets
\                              this tutorial and demo2/3 load (section
\                              7); run only under non-dot vForth.
\ demo/Layer3-demo2.f          LOAD-BYTES-only consumer of those
\                              assets, still with its own inline mode/
\                              palette words (pre-lib/LAYER3.f style).
\ demo/Layer3-demo3.f          the fully refactored consumer: NEEDS
\                              LAYER3, no inline mode/palette code left
\                              -- what section 3-4 above describe.
\ lib/LAYER3.f                 TILE-MODE:/TILE-PALETTE: defining words
\                              and the four ready-made modes/palettes.
\ lib/TILE80.f + TILE80-setup.f  the text-console capstone (section 8).
\ Screens 340, 420-436 ("TILEMAP study") in !Blocks-64.bin -- an
\ earlier, block-based exploration of the same hardware.

\ NEEDS TESTING
\ T{  TILE3-40-DEMO  ->  }T   \ visual only, no stack effect
