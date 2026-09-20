\
\ 066-kempston-joystick.f
\ Reading the Kempston joystick interface directly through port $1F
\ (31 decimal): the de-facto standard joystick port inherited from the
\ classic 8-bit Spectrum world, still wired the same way on the Next.
\
\ No library wraps this port in vForth today -- demo/chomp-chomp.f reads
\ it raw with "31 P@" (its pacman-move word) and nothing else in the
\ repo documents the bit layout.  This tutorial fills that gap: what the
\ port is, what each bit means, and a small live demo that decodes it
\ continuously on screen until BREAK is pressed.
\
\ vForth-specific notes:
\   - P@ ( port -- byte ) is a core word: no NEEDS required.
\   - ?TERMINAL ( -- f ) is the core BREAK-key test used to stop the
\     demo loop; no NEEDS required either (see tutorial 035 section 3).
\   - Kempston is ACTIVE HIGH (bit=1 means pressed): the opposite sense
\     from the keyboard matrix's port $FE, which is active low (tutorial
\     051).  Mixing the two conventions up is the classic bug here.
\
\ no Brodie counterpart (vForth extension)
\ Reference: sec.2.12.8 (I/O Ports category: P@ -- generic, no
\            Kempston-specific entry).  Hardware source is
\            doc/zx-next-dev-guide-r3.md, section 3.1 "Ports and
\            Registers", printed page 28:
\              R- $xx1F  Reads movement of joysticks using Kempston
\                        interface
\            That entry names the port but does NOT give a per-bit
\            table -- the guide has no dedicated Kempston section (only
\            "$xx37  Kempston interface second joystick variant", also
\            without a bit table).  The bit layout in section 1 below is
\            the industry-standard Kempston convention, not a quote from
\            the guide; demo/chomp-chomp.f's working code (bits 1/2/4/8
\            decoded as right/left/down/up) is independent confirmation
\            that vForth/the Next follow it.
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   066 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 066 TUTORIAL
\
\ Run it with:  DEMO   (BREAK stops it)
\

MARKER NEWTASK

CR
.( --- Tutorial 066: Kempston joystick loaded. ) CR
.(     Type NEWTASK to unload.               ) CR

NEEDS .AT

\ ===========================================================================
\ 1. Port $1F (31 decimal) and its bit layout
\ ===========================================================================
\
\ A single INPUT port, read-only, address $xx1F (the high byte is
\ ignored by the hardware decoder, so 31 P@ is the whole story -- no
\ NextReg selection is involved, unlike REG@/REG!).
\
\   bit   value   meaning
\   ---   -----   -------
\    0      1     RIGHT
\    1      2     LEFT
\    2      4     DOWN
\    3      8     UP
\    4     16     FIRE
\   5-7      -    unused, always read 0
\
\ ACTIVE HIGH: a bit reads 1 while the corresponding direction/button is
\ held, 0 when it is not.  The idle byte (nothing touched) is 0.  More
\ than one bit can be set at once -- a diagonal is RIGHT+UP ($09), and
\ FIRE can combine with any direction -- so decoding must test each bit
\ independently with AND, never compare the whole byte against a single
\ expected value (see the caveat in section 4).
\
\ There is also NextReg $05, which can put the physical DB9 ports into
\ Kempston, Sinclair, Cursor or MD-pad emulation modes (dev guide
\ section 3.1, "Sets joystick mode"); this tutorial assumes the default
\ Kempston mapping and does not touch NextReg $05.  Port $xx37 (the
\ "second Kempston variant") is out of scope: this tutorial covers only
\ the classic single-port interface every 8-bit Kempston joystick uses.

\ ===========================================================================
\ 2. Reading the port
\ ===========================================================================
\
\   31 P@   ( -- byte )
\
\ P@ ( port -- byte ) is the core word that performs the Z80 IN
\ instruction.  Give it a name so the rest of this tutorial (and any
\ code built on it) reads by intent rather than by magic number:

: JOY@  ( -- byte )  31 P@ ;

\   JOY@ .   \ prints the current byte: 0 when the stick is centred
\            \ and no button is held

\ ===========================================================================
\ 3. Decoding the byte
\ ===========================================================================
\
\ One predicate word per bit, each independent of the others -- exactly
\ what section 1 said a diagonal or FIRE-plus-direction needs:

: RIGHT?  ( byte -- f )   1 AND ;
: LEFT?   ( byte -- f )   2 AND ;
: DOWN?   ( byte -- f )   4 AND ;
: UP?     ( byte -- f )   8 AND ;
: FIRE?   ( byte -- f )  16 AND ;

\   JOY@ RIGHT? IF ." moving right" THEN

\ ===========================================================================
\ 4. Demo: live decode at a fixed screen position, BREAK to stop
\ ===========================================================================
\
\ Read the port in a tight loop, redraw a fixed-width status line in
\ place with .AT (so it does not scroll), and stop on ?TERMINAL -- the
\ same "game loop" shape as tutorial 051 section 6, PLAY.

: .JOY  ( byte -- )
    DUP RIGHT?  IF ." RIGHT  " ELSE ." .      " THEN
    DUP LEFT?   IF ." LEFT   " ELSE ." .      " THEN
    DUP DOWN?   IF ." DOWN   " ELSE ." .      " THEN
    DUP UP?     IF ." UP     " ELSE ." .      " THEN
    DUP FIRE?   IF ." FIRE   " ELSE ." .      " THEN
        ."  raw=" 3 .R
;

: PLAY  ( -- )
    CLS
    2 0 .AT ." Kempston joystick, port $1F (31 decimal)."
    4 0 .AT ." Move the stick / press fire.  BREAK stops."
    BEGIN
        6 0 .AT
        JOY@ .JOY
        ?TERMINAL
    UNTIL
    CR CR ." Demo stopped." CR
;

\   DEMO
: DEMO  ( -- )  PLAY ;

\ ===========================================================================
\ 5. Caveats
\ ===========================================================================
\
\ - ACTIVE HIGH here, ACTIVE LOW on the keyboard matrix (port $FE,
\   tutorial 051): the two hardware inputs use opposite conventions for
\   "pressed".  Reusing a predicate word between the two without
\   checking is a real bug, not a style choice.
\ - No debouncing and no edge detection: JOY@ reports the instantaneous
\   state every time it is called, exactly like the keyboard matrix
\   words in tutorial 051 (KEY-DOWN?/KEY-PRESSED?), unlike the buffered,
\   ROM-mediated KEY of tutorial 035.
\ - Without real Kempston hardware (or CSpect's Kempston emulation
\   enabled and a joystick/gamepad mapped to it), 31 P@ simply reads 0
\   forever -- that is a correctly-idle joystick, not a bug in this code.
\ - demo/chomp-chomp.f's own decoder (pacman-move) is a narrower
\   consumer of this same port: it uses CASE on the exact values 1, 2,
\   4, 8 and ignores FIRE and diagonals entirely, which is enough for a
\   single-direction maze game but would miss a genuine diagonal press.
\   See also chomp-chomp.f directly for that real-world (if partial)
\   usage.

\ ===========================================================================
\ 6. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ JOY@ depends on physical/emulated hardware state and cannot be tested
\ automatically; RIGHT?/LEFT?/DOWN?/UP?/FIRE? can, against a fed byte.
\
\ NEEDS TESTING
\ T{  9   RIGHT? ->  1  }T   \ $09 = RIGHT+UP: bit 0 set
\ T{  9   UP?    ->  8  }T   \ $09 = RIGHT+UP: bit 3 set
\ T{  9   LEFT?  ->  0  }T
\ T{  16  FIRE?  -> 16  }T
