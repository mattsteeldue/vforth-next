\
\ 049-interrupts.f
\ Interrupt service routines (ISR) with lib/INTERRUPTS.f.
\
\ lib/INTERRUPTS.f installs a Z80 interrupt mode 2 handler that can
\ call any Forth word each time the ULA generates a vertical-blank
\ interrupt (50 Hz / 60 Hz).  The ISR saves all Z80 registers and
\ the Forth stacks, executes the user word, then restores everything.
\ Key setup words: ISR-OFF, ISR-ON, ISR-XT, ISR-SYNC.  The MOUSE
\ driver is an example that uses this facility.
\
\ Reference: sec.8
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   049 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 049 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 049: Interrupt service routines loaded. ) CR
.(     Type NEWTASK to unload.                    ) CR

NEEDS INTERRUPTS
NEEDS .BORDER
NEEDS .PAPER
NEEDS .AT
NEEDS ms
NEEDS LAYER0
NEEDS LAYER12
NEEDS [']

\ ===========================================================================
\ 1. Overview of the interrupt facility
\ ===========================================================================
\
\ The ZX Spectrum ULA generates a vertical-blank interrupt at 50 Hz
\ (PAL) or 60 Hz (NTSC).  The Z80 responds by jumping through the
\ interrupt vector to the ISR handler.
\
\ lib/INTERRUPTS.f sets up:
\   - A 257-byte interrupt vector table (ISR-TABLE) aligned to a
\     page boundary in the Forth dictionary
\   - An ISR handler (ISR-SUB) that saves all registers, sets up
\     Forth's internal pointers (IX, SP, RP), and executes the
\     word stored in ISR-XT
\   - After the user word returns, ISR-RET restores all registers
\     and returns from interrupt with EI and RET
\
\ Usage template (at the interpreter -- typed at the prompt or run as
\ top-level code, NOT inside a definition):
\   ISR-OFF                  \ disable interrupts while configuring
\   ' MY-WORD  ISR-XT !      \ install handler word (' is ok here)
\   ISR-ON                   \ enable Z80 IM2 interrupts
\   ...
\   ISR-OFF                  \ disable when done
\ Inside a colon definition use ['] instead of ' -- see the note in
\ section 2 and the demos in sections 5-7.

\ ===========================================================================
\ 2. ISR-XT -- the interrupt handler pointer
\ ===========================================================================
\
\ ISR-XT is a two-cell CREATE area:
\   ISR-XT + 0  : execution token of the user word (default: NOOP)
\   ISR-XT + 2  : execution token of ISR-RET (return from interrupt)
\
\ To install a handler:
\   ' MY-HANDLER  ISR-XT !
\
\ To reset to no-op:
\   ' NOOP  ISR-XT !
\
\ NOTE -- ' (tick) vs ['] :  the two snippets just above are
\ interpret-level (type them at the prompt, or run as top-level code).
\ There ' is correct: it parses the next word and returns its xt.
\ INSIDE a colon definition you must use ['] -- ' is not immediate, so
\ ' MY-HANDLER would compile a run-time parse of the input stream
\ (the wrong word, or an error) plus a stray call to MY-HANDLER.  The
\ demos in sections 5-7 install from inside definitions, so they use
\   ['] WORD  ISR-XT !       ( NEEDS ['] is loaded at the top ).
\ Counter-example at interpret level: lib/MOUSE.f ends with
\   ' MOUSE-DELTA ISR-XT !   at load time -- no brackets needed.
\
\ The user handler word must:
\   - Have no net stack effect  ( -- )
\   - Execute quickly (it runs at every frame, ~50 times per second)
\   - Not call words that use the data stack in non-trivial ways
\     unless all cells pushed are also popped

\ ===========================================================================
\ 3. ISR-ON, ISR-OFF
\ ===========================================================================
\
\   ISR-OFF ( -- )   disable interrupts (switch to Z80 IM1)
\                    write I register = $3F (standard IM1 vector)
\   ISR-ON  ( -- )   install interrupt vector table address into I
\                    register, switch to Z80 IM2, enable interrupts
\
\ ISR-OFF restores the standard Spectrum interrupt mode 1 (ROM
\ handler at $38).  The keyboard and FRAMES counter still work.
\
\ Always bracket ISR setup with ISR-OFF ... ISR-ON (interpreter form;
\ inside a definition use ['], see section 2):
\   ISR-OFF
\   ' MY-HANDLER ISR-XT !
\   ISR-ON

\ ===========================================================================
\ 4. ISR-SYNC -- wait for vertical blank
\ ===========================================================================
\
\   ISR-SYNC ( -- )   execute Z80 HALT; suspend until next interrupt
\
\ ISR-SYNC is the cleanest way to synchronise with the display.
\ HALT suspends the CPU until the next interrupt fires (the vertical
\ blank at 50 Hz / 60 Hz), then the ISR handler runs, then execution
\ continues after ISR-SYNC.
\
\ Use ISR-SYNC in animation loops for exact frame timing:
\   BEGIN
\       \ update display here
\       ISR-SYNC    \ wait for frame boundary
\   ?TERMINAL UNTIL

\ ===========================================================================
\ 5. Example: frame counter
\ ===========================================================================

VARIABLE FRAME-COUNT

: COUNT-FRAMES  ( -- )
    1 FRAME-COUNT +!
;

: INSTALL-COUNTER  ( -- )
    ISR-OFF
    ['] COUNT-FRAMES  ISR-XT !
    ISR-ON
;

: REMOVE-COUNTER  ( -- )
    ISR-OFF
    ['] NOOP  ISR-XT !
;

\ ===========================================================================
\ 6. Demo: frame-based animation
\ ===========================================================================

: FRAME-ANIM  ( -- )
    0 FRAME-COUNT !
    INSTALL-COUNTER
    CLS
    0 0 .AT  ." Frame animation (BREAK to stop):" CR
    BEGIN
        ISR-SYNC
        1 0 .AT  ." Frames: " FRAME-COUNT @ .  ."   "
        ?TERMINAL
    UNTIL
    REMOVE-COUNTER
    CLS
;

\ ===========================================================================
\ 7. Demo: border flasher (simple ISR)
\ ===========================================================================

VARIABLE FLASH-STATE

: BORDER-FLASH  ( -- )
    FLASH-STATE @ IF
        7 .BORDER  
        0 FLASH-STATE !
    ELSE
        0 .BORDER  
        1 FLASH-STATE !
    THEN
;

: INSTALL-FLASH  ( -- )
    ISR-OFF
    [']  BORDER-FLASH  ISR-XT !
    ISR-ON
;

: FLASH-DEMO  ( -- )
    LAYER0
    0 FLASH-STATE !
    INSTALL-FLASH
    ." Border flashing at 50 Hz. BREAK to stop." CR
    BEGIN  ?TERMINAL  UNTIL
    ISR-OFF
    [']  NOOP  ISR-XT !
    LAYER12
;

\ ===========================================================================
\ 8. Cautions
\ ===========================================================================
\
\ 1. Keep ISR handlers very short.  Each ISR must finish before the
\    next interrupt arrives (~20 ms at 50 Hz, 3.5 MHz clock).
\
\ 2. Do not call EMIT, TYPE, or any Forth I/O word from within the
\    ISR.  These are not re-entrant.
\
\ 3. The ISR uses a temporary stack area (ISR-SP0, ISR-RP0) located
\    between ISR-TABLE and ISR-VECTOR.  About 100 bytes are available.
\    Do not push many cells in the ISR handler.
\
\ 4. If the ISR handler crashes (bad XT, stack overflow), it will
\    leave the system in an unstable state.  Save your work before
\    experimenting.
\
\ 5. MOUSE (lib/MOUSE.f) uses this ISR facility.  Do not load MOUSE
\    and then install your own ISR-XT without first unloading MOUSE.

\ ===========================================================================
\ 9. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ NEEDS TESTING
\ T{  ISR-XT @  ->  ISR-XT @  }T    \ ISR-XT is readable
