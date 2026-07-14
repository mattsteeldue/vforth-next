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
\ This tutorial's demo is a three-band split-scroll effect over a
\ loaded Layer 2 picture, ported from a working forum contribution
\ (forum/copper-bmp2.f) and adapted to current vForth conventions.
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
NEEDS LAYER2
NEEDS LAYER12
NEEDS BMP-LOAD
NEEDS VALUE
NEEDS TO
NEEDS CASE
NEEDS INTERRUPTS
NEEDS .PAPER

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
\ 3. Demo overview: a three-band split-scroll effect
\ ===========================================================================
\
\ Next register $17 (Layer 2 Y Offset) sets a pixel offset applied
\ to the whole Layer 2 framebuffer when it is drawn to the screen.
\ Writing to it once per frame produces an ordinary vertical scroll;
\ writing to it several times per frame, at different scanlines via
\ COP-WAIT, produces a "torn" effect: the picture is cut into
\ independent horizontal bands, each one showing the source bitmap
\ at its own vertical offset.
\
\ This demo splits the 192-line display into three bands (lines
\ 0-63, 64-127, 128-191) and scrolls each one by a different amount
\ every frame, giving the classic split/shear "melting picture"
\ copper effect.

\ ===========================================================================
\ 4. Loading the picture
\ ===========================================================================
\
\ BMP-LOAD" (from lib/bmp-load.f, see tutorial 046) reads a 256x192
\ 256-color BMP straight into the Layer 2 frame buffer, handling
\ MMU7 page mapping and BMP header orientation internally.  It
\ replaces the hand-rolled, order-reversed loader from the original
\ forum source, which read pages back to front and hard-coded the
\ file's payload offset instead of parsing it from the header.

\ ===========================================================================
\ 5. Building the copper program for one frame
\ ===========================================================================
\
\ Each band keeps a running Y-offset (SCROLLn) and a per-frame step
\ (STEPn, signed).  BUILD-COPPER-LIST advances each offset and
\ re-emits the whole three-band list; it must be called again every
\ time the offsets change, since the copper list is not re-read
\ from the VALUEs -- it is a fixed sequence of numbers uploaded once.

0 VALUE SCROLL0   \ current Y-offset, band 0 (lines 0-63)
0 VALUE SCROLL1   \ current Y-offset, band 1 (lines 64-127)
0 VALUE SCROLL2   \ current Y-offset, band 2 (lines 128-191)

0 VALUE STEP0     \ per-frame increment (signed), band 0
0 VALUE STEP1     \ per-frame increment (signed), band 1
0 VALUE STEP2     \ per-frame increment (signed), band 2

: BUILD-COPPER-LIST  ( -- )
    COP-STOP
    $00 $00 COP-WAIT
        SCROLL0 STEP0 + TO SCROLL0  SCROLL0  $17 COP-MOVE
    $40 $0F COP-WAIT
        SCROLL1 STEP1 + TO SCROLL1  SCROLL1  $17 COP-MOVE
    $80 $1E COP-WAIT
        SCROLL2 STEP2 + TO SCROLL2  SCROLL2  $17 COP-MOVE
    COP-HALT
;

\ ===========================================================================
\ 6. Driving the effect from the 50Hz interrupt
\ ===========================================================================
\
\ ISR-TEST rebuilds and restarts the copper list every 4th frame
\ (roughly 12.5 times a second -- fast enough to look smooth, slow
\ enough to leave CPU time for the key-polling loop below).  It is
\ installed with ISR-XT, the current INTERRUPTS.f API; the original
\ forum source stored it into a nonexistent "ISR-W" instead, which
\ left the handler never actually hooked up.

23672 CONSTANT FRAMES-ADDR   \ ZX Next 50Hz frame counter (system var)

: ISR-TEST  ( -- )
    FRAMES-ADDR @ 3 AND 0= IF
        BUILD-COPPER-LIST COP-START
    THEN
;

ISR-OFF
' ISR-TEST ISR-XT !

\ ===========================================================================
\ 7. Interactive control
\ ===========================================================================
\
\ KEYPRESS blocks until a key is pressed and returns its code, using
\ LAST-K ($5C08), the ZX ROM system variable holding the last key
\ decoded by the keyboard interrupt routine.  HANDLE-KEY dispatches
\ on it:
\
\   a   ISR-ON   start (or resume) the animation
\   d   ISR-OFF  pause it -- the copper keeps displaying its last
\                uploaded list, but the offsets stop advancing
\   e   reverse all three bands to one direction
\   q   reverse all three bands to the other direction
\
\ [BREAK] ends KEY-LOOP via ?TERMINAL.

$5C08 CONSTANT LAST-K

: KEYPRESS  ( -- c )
    0 LAST-K C!
    BEGIN  LAST-K C@  UNTIL
    LAST-K C@
;

: HANDLE-KEY  ( c -- )
    CASE
        [CHAR] a OF  ISR-ON                                      ENDOF
        [CHAR] d OF  ISR-OFF                                     ENDOF
        [CHAR] e OF  -1 TO STEP0  -2 TO STEP1  -3 TO STEP2       ENDOF
        [CHAR] q OF   1 TO STEP0   2 TO STEP1   3 TO STEP2       ENDOF
    ENDCASE
;

: KEY-LOOP  ( -- )
    BEGIN
        KEYPRESS HANDLE-KEY
    ?TERMINAL UNTIL
;

\ ===========================================================================
\ 8. The demo word
\ ===========================================================================
\
\ SPLIT-SCROLL-DEMO ties the pieces together: switch to Layer 2,
\ load the picture, reset the scroll state, and hand control to
\ KEY-LOOP.  On exit (BREAK) it stops the copper, disables the
\ interrupt, and restores the normal LAYER12 text mode -- the same
\ switch-in/restore-out pattern used by every graphic demo in this
\ tutorial series (see tutorial/CLAUDE.md sec.13).
\
\ COP-STOP only halts the copper's own instruction pointer -- it
\ does not touch whatever value the copper last wrote to Next
\ register $17.  Without an explicit restore, BUILD-COPPER-LIST's
\ last COP-MOVE would leave Layer 2's Y-offset shifted even after
\ this demo exits, silently displacing any later, unrelated use of
\ Layer 2.  SAVED-Y-OFFSET captures the register's value on entry
\ and puts it back on exit, so the demo leaves hardware state ($17)
\ exactly as it found it -- the same in-out discipline as LAYER12.

VARIABLE SAVED-Y-OFFSET

: SPLIT-SCROLL-DEMO  ( -- )
    $17 REG@ SAVED-Y-OFFSET !
    LAYER2 CLS
    ." Loading image..." CR
    BMP-LOAD" tutorial/bmp/critters.bmp"
    0 TO SCROLL0  0 TO SCROLL1  0 TO SCROLL2
    -1 TO STEP0  -2 TO STEP1  -3 TO STEP2
    ." a=start  d=pause  e/q=reverse direction  BREAK=quit" CR
    KEY-LOOP
    ISR-OFF
    COP-STOP
    SAVED-Y-OFFSET @ $17 REG!
    LAYER12 1 .PAPER CLS
;

\ ===========================================================================
\ 9. Notes on copper timing
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
\ 10. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ The animation is purely visual and needs SPLIT-SCROLL-DEMO run
\ interactively; only the register constants can be tested here.
\
\ NEEDS TESTING
\ T{  COP-CTRL-LO  ->  97   }T    \ $61
\ T{  COP-CTRL-HI  ->  98   }T    \ $62
\ T{  COP-WRITE    ->  99   }T    \ $63
