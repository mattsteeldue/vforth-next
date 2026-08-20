\
\ 054-dma.f
\ Direct Memory Access (DMA) controller on the ZX Spectrum Next.
\
\ The zxnDMA is a single-channel DMA controller that transfers data between
\ memory and memory, memory and I/O ports, and I/O and memory at CPU speed.
\ This tutorial covers continuous-mode transfers: copy, fill, out, and in.
\ Burst mode with fixed-time-transfer (for audio streaming) is reserved for
\ a future Phase 2 library extension.
\
\ The hardware is programmed by writing seven sequential WR0-WR6 register
\ bytes to port $xx6B. The vForth DMA library abstracts this: high-level
\ words like DMA-COPY take (src dest len) on the stack and generate the
\ correct register sequence automatically, eliminating the Z80 "self-modifying
\ code" pattern shown in the hardware manual.
\
\ Authoritative source: ZX Spectrum Next Developer's Guide & Reference Manual
\ rev.3 (doc/zx-next-dev-guide-r3.txt in this repo): section 3.3 "DMA",
\ printed pages 43-60 (registers WR0-WR6 on pages 44-53, examples on pages
\ 54-59). See also "DMA and Interrupts" (page 59) for timing implications
\ when running DMA in continuous mode: the CPU is blocked until the transfer
\ completes, and level-triggered maskable interrupts cannot fire during DMA.
\
\ Reference: sec.3.3 (DMA)
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   054 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 054 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 054: DMA (Direct Memory Access) loaded. ) CR
.(     Type NEWTASK to unload.                         ) CR

NEEDS DMA

\ =========================================================================
\ 1. Basic copy: DMA-COPY transfers a block of memory
\ =========================================================================
\
\ DMA-COPY ( src dest len -- ) transfers len bytes from src to dest at full
\ CPU speed. Both addresses increment after each byte. The CPU is blocked
\ until the transfer completes (continuous mode). This is faster than
\ looping with CMOVE because the hardware takes over the address/counter
\ arithmetic.
\
\ Example: allocate a small source block and copy it to a test destination.
\
\ CAUTION: $E000-$FFFF is not off-limits by address - it is the MMU7
\ window, the single gateway through which any code (the compiler, a
\ library, or your own) reaches the full expansion RAM pool, well
\ beyond the 64K the Z80 can address directly. Its content is simply
\ whichever 8K page a prior MMU7! last selected, and that selection is
\ not tied to one purpose: at compile time (INCLUDE/NEEDS/LOAD),
\ dictionary search pages in the heap pages holding the word headers,
\ but at run time the dictionary is never consulted again (execution
\ runs from already-resolved xt/cfa), so MMU7 is then free for other
\ jobs - paging the LAYER2 framebuffer, decoding a Heap string via FAR
\ (as lib/TUTORIAL.f does, keeping filenames in Heap and only an array
\ of heap-pointers in the dictionary), or, most visibly, LED (lib/LED.f)
\ which pages through as many of the available 8K slots as the file
\ being edited needs - MMU7 as a window onto up to about 2MB of RAM.
\ A DMA transfer may legitimately target $E000-$FFFF, but only once you
\ know - and control - which of these uses currently owns the page
\ mapped there; write before repaging it and you overwrite whatever
\ that owner still needs. This tutorial sidesteps the whole question by
\ using ALLOTed scratch buffers in ordinary dictionary space, owned by
\ the tutorial and safe to overwrite, which need no MMU7 care at all.

CREATE TEST-SRC   $80 ALLOT
CREATE TEST-DEST  $80 ALLOT
$80   CONSTANT TEST-LEN

: .DEMO-COPY
    CR
    TEST-SRC TEST-LEN $55 FILL     \ recognizable pattern for DUMP checks
    .( Copying ) TEST-LEN . .( bytes from ) TEST-SRC HEX . DECIMAL
    .( to ) TEST-DEST HEX . DECIMAL CR
    TEST-SRC TEST-DEST TEST-LEN DMA-COPY
    .( Done. ) CR ;

\ =========================================================================
\ 2. Fill: DMA-FILL writes a constant byte repeatedly
\ =========================================================================
\
\ DMA-FILL ( byte dest len -- ) fills len bytes at address dest with a
\ constant byte value. The source address is fixed (pointing to an internal
\ buffer), and the destination address increments. This is faster than
\ looping with FILL for large blocks.
\
\ Example: fill a test area with a pattern byte.

CREATE FILL-DEST  $80 ALLOT
$80   CONSTANT FILL-LEN

: .DEMO-FILL
    CR
    .( Filling ) FILL-LEN . .( bytes at ) FILL-DEST HEX . DECIMAL
    .( with byte $AA ) DECIMAL CR
    $AA FILL-DEST FILL-LEN DMA-FILL
    .( Done. ) CR ;

\ =========================================================================
\ 3. Memory to I/O: DMA-OUT sends memory bytes to a port
\ =========================================================================
\
\ DMA-OUT ( src ioport len -- ) transfers len bytes from memory (address
\ src, incrementing) to an I/O port (fixed address). The destination port
\ receives all bytes at the same port number in sequence.
\
\ Example: write a sequence of bytes to a test port (simulated here, since
\ actual I/O effects depend on the specific port hardware).

: .DEMO-OUT
    CR
    .( Sending ) TEST-LEN . .( bytes from ) TEST-SRC HEX . DECIMAL
    DECIMAL .( to port $FE (border) ) CR
    TEST-SRC $FE TEST-LEN DMA-OUT
    .( Done. [Border color affected if on real hardware.] ) CR ;

\ =========================================================================
\ 4. I/O to Memory: DMA-IN reads port bytes into memory
\ =========================================================================
\
\ DMA-IN ( ioport dest len -- ) transfers len bytes from an I/O port
\ (fixed address) to memory (address dest, incrementing). The source port
\ delivers all bytes in sequence to incrementing memory locations.
\
\ Example: read bytes from a port into memory (effects depend on port).

CREATE IN-DEST  $10 ALLOT
$10   CONSTANT IN-LEN

: .DEMO-IN
    CR
    .( Reading ) IN-LEN . .( bytes from port $FE (keyboard)  ) CR
    .( into memory at ) IN-DEST HEX . DECIMAL CR
    $FE IN-DEST IN-LEN DMA-IN
    .( Done. ) CR ;

\ =========================================================================
\ 5. Unload demonstration
\ =========================================================================
\
\ To unload the tutorial and all DMA library words:
\   NEWTASK
\
\ This restores the dictionary to its state before tutorial 054 was loaded.
\ The `NO-DMA` unload anchor (defined inside lib/DMA.f) is forgotten along
\ with the entire DMA-library definition tree.

\ =========================================================================
\ Interactive demonstrations
\ =========================================================================

: DEMO
    .DEMO-COPY
    .DEMO-FILL
    .DEMO-OUT
    .DEMO-IN ;

CR
.( Type:  DEMO    to run all demonstrations. ) CR
.( or:     .DEMO-COPY / .DEMO-FILL / .DEMO-OUT / .DEMO-IN  individually. ) CR
.( or:     NEWTASK  to unload this tutorial. ) CR

\ =========================================================================
\ NEEDS TESTING
\ =========================================================================
\
\ The demonstrations above are not automated unit tests because DMA behavior
\ depends on real hardware (CSpect emulator or physical ZX Spectrum Next).
\ The headless emulator (emu/repl.py) does not model the zxnDMA controller,
\ so no meaningful stack-effect test is possible.
\
\ Manual CSpect verification checklist (to be confirmed):
\   1. Run DEMO on CSpect and observe that each transfer completes without
\      error.
\   2. Use DUMP to verify that TEST-DEST contains a copy of TEST-SRC
\      (both hold $55 bytes after .DEMO-COPY).
\   3. Use DUMP to verify that FILL-DEST is filled with $AA bytes.
\   4. Observe no crashes when DMA-OUT or DMA-IN are called (port I/O effects
\      are hardware-dependent and not easily visible).
\   5. Load/unload the tutorial multiple times: NEWTASK should restore the
\      dictionary and allow 054 TUTORIAL to reload successfully.
\
\ Status: DMA library **NOT YET VERIFIED on CSpect or real hardware**.
\          Byte-level register traces from the emulator can confirm WR0-WR6
\          sequences, but real data transfer verification requires CSpect.
