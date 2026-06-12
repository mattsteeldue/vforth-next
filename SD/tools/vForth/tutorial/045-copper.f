\
\ 045-copper.f
\ The ZX Next copper unit: scanline-timed display effects.
\
\ The ZX Next copper is a simple co-processor that executes a list
\ of commands in sync with the video scan.  Each command can either
\ wait until a given scanline/horizontal position, or write a value
\ to a Next register at that moment.  Common uses: changing the
\ border color per scanline, split-screen palette changes, and
\ hardware-timed scrolling effects.
\
\ Reference: sec.7.6
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   045 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 045 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 045: Copper unit loaded. ) CR
.(     Type NEWTASK to unload.         ) CR

NEEDS COPPER

\ ===========================================================================
\ 1. Copper hardware overview
\ ===========================================================================
\
\ The copper unit executes a list stored in its own 1K RAM (512 x
\ 16-bit words).  The list is uploaded via Next register $63
\ (COP-WRITE) one 16-bit word at a time.  The copper automatically
\ resets and restarts from the beginning on each vertical blank
\ when in mode %11.
\
\ Control registers (Next registers):
\   $61 COP-CTRL-LO  copper control low byte
\   $62 COP-CTRL-HI  copper control high byte
\
\   COP-START writes $00 to $61 and $C0 to $62:
\     bits 7-6 of $62 = %11  -->  run from start on each VSYNC
\
\   COP-STOP writes $00 to both:
\     resets instruction pointer to 0, stops execution
\
\ Copper instruction format (16-bit):
\   bit 15 = 0 : MOVE  instruction
\     bits 14-8 : Next register number (0-127)
\     bits  7-0 : value to write
\
\   bit 15 = 1 : WAIT  instruction
\     bits 14-6 : vertical line number (9 bits, 0-311)
\     bits  5-1 : horizontal position (5 bits, 0-55)
\     bit     0 : unused

\ ===========================================================================
\ 2. Key words from lib/copper.f
\ ===========================================================================
\
\   COP-STOP  ( -- )         stop copper, reset pointer to 0
\   COP-START ( -- )         start in VSYNC-reset mode (%11)
\   COP-UPLOAD ( n -- )      write one 16-bit word to copper RAM
\   COP-WAIT ( v h -- )      emit WAIT instruction
\                            v: vertical line 0-311
\                            h: horizontal position 0-55
\   COP-MOVE ( v r -- )      emit MOVE instruction
\                            v: value 0-255
\                            r: register number 0-127
\   COP-NOOP ( -- )          emit no-op (one horizontal skip)
\   COP-HALT ( -- )          emit $FFFF (stop copper)
\
\ Building a copper list:
\   1. COP-STOP              reset and zero the pointer
\   2. emit WAIT and MOVE instructions
\   3. COP-HALT              terminate the list
\   4. COP-START             begin execution
\
\ The list is self-contained in copper RAM; you can re-write it by
\ calling COP-STOP again and starting fresh.

\ ===========================================================================
\ 3. Next register for border color
\ ===========================================================================
\
\ Writing to Next register $62 changes the border color.
\ Actually the ULA border color is at I/O port $FE, but a common
\ copper effect is to change the border via the ULA register.
\
\ In practice, COP-MOVE can write any Next register.
\ To change border per scanline, write to reg $62 which on the Next
\ can control the border indirectly, or use reg $40-$4F for palette.
\
\ A common trick is to write to Next register $43 (palette data) at
\ specific scanlines to create a per-scanline color effect.

\ ===========================================================================
\ 4. Demo: rainbow border using copper
\ ===========================================================================
\
\ This example changes the border ULA color by writing to port $FE
\ via copper at intervals of 24 scanlines.
\ We use COP-MOVE to write to Next register $62 (copper control hi)
\ is not the border -- instead we demonstrate the pattern with
\ Next register $40 (palette index) to show the technique.
\
\ For a real border effect on the Next, you write to the ULA ink/
\ paper registers, or set palette entries.  Here we change the
\ background palette entry (index 0) for visual effect.

NEEDS ms

: COPPER-RAINBOW  ( -- )
    COP-STOP
    \ Build copper list: change palette entry 0 per 24-line band
    8 0 DO
        I 24 *  0 COP-WAIT       \ wait for scanline I*24
        I 32 *  $40 COP-MOVE     \ write palette index
        I 32 * 7 AND  $41 COP-MOVE \ write palette color
    LOOP
    COP-HALT
    COP-START
    ." Rainbow effect running. Press BREAK to stop." CR
    BEGIN  ?TERMINAL  UNTIL
    COP-STOP
;

\ ===========================================================================
\ 5. Demo: split screen border effect
\ ===========================================================================
\
\ Change border register at two scanlines to create a split-color
\ effect at row 96 (halfway down the display area).
\
\ Border changes by writing to I/O port $FE are not available via
\ copper MOVE (which only writes Next registers).  However, you can
\ use copper to write to Next register $62 palette-related registers
\ or to the ULA scroll register to achieve split-screen effects.
\
\ The following example uses copper to write palette value at line 96.

: COPPER-SPLIT  ( -- )
    COP-STOP
    \ Above scanline 96: palette 0 = dark blue ($09)
    0   0 COP-WAIT
    $09 $41 COP-MOVE     \ set color of palette index 0
    \ At scanline 96: palette 0 = dark green ($12)
    96  0 COP-WAIT
    $12 $41 COP-MOVE
    COP-HALT
    COP-START
    ." Split screen effect. BREAK to stop." CR
    Begin  ?TERMINAL  UNTIL
    COP-STOP
;

\ ===========================================================================
\ 6. Demo: disable copper
\ ===========================================================================
\
\ COP-STOP disables the copper and resets its internal pointer.
\ After COP-STOP, the copper does nothing until COP-START is called.

: COPPER-OFF  ( -- )
    COP-STOP
    ." Copper stopped." CR
;

\ ===========================================================================
\ 7. Notes on copper timing
\ ===========================================================================
\
\ Vertical line numbers for PAL (312 total lines):
\   0-191 : active display area (top to bottom)
\   192   : last display line
\   193+  : vertical blanking interval
\
\ Horizontal positions 0-55 correspond to positions within each
\ scanline.  Position 0 is the leftmost pixel position.
\
\ The copper list can hold up to 512 instructions (16-bit each).
\ The list halts at COP-HALT ($FFFF) or wraps around.

\ ===========================================================================
\ 8. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ Copper effects are purely visual.  Register constants can be tested.
\
\ NEEDS TESTING
\ T{  COP-CTRL-LO  ->  97   }T    \ $61
\ T{  COP-CTRL-HI  ->  98   }T    \ $62
\ T{  COP-WRITE    ->  99   }T    \ $63
