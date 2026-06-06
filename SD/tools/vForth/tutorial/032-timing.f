\
\ 032-timing.f
\ Timing: ms delays and frame-synchronised animation.
\
\ vForth provides the ms word for millisecond delays.  The ZX Next
\ runs at 50 Hz (PAL) or 60 Hz (NTSC), giving one video frame every
\ 20 ms or 16.7 ms.  Frame-synchronised animation avoids tearing by
\ waiting for the vertical blank before updating the display.  The
\ ms CODE word reads the CPU speed register automatically so it gives
\ correct delays at any clock rate (3.5-28 MHz).
\
\ Reference: sec.3.4
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   032 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 032 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 032: Timing and delays loaded. ) CR
.(     Type NEWTASK to unload.               ) CR

NEEDS ms
NEEDS .BORDER
NEEDS .PAPER
NEEDS .AT
NEEDS LAYER0
NEEDS LAYER12
NEEDS WAIT-KEY
NEEDS VALUE
NEEDS TO


\ ===========================================================================
\ 1. ms -- millisecond delay
\ ===========================================================================
\
\   ms ( n -- )   delay n milliseconds (n must be < 8192)
\
\ ms is a CODE word that auto-detects the current CPU speed
\ (register $07) and adjusts its inner loop accordingly.
\ Valid speeds: 0=3.5 MHz  1=7 MHz  2=14 MHz  3=28 MHz.
\
\ Examples:
\   500 ms     \ wait half a second
\   1000 ms    \ wait one second
\   20 ms      \ wait one PAL video frame
\
\ Maximum safe value: 8191 ms (~8 seconds).
\ For longer delays, call ms repeatedly.
\
\ Example: 3-second delay
\   3000 ms
\   ( or: 3 0 DO 1000 ms LOOP )

\ ===========================================================================
\ 2. Video frame timing
\ ===========================================================================
\
\ The ZX Next video system generates interrupts at 50 Hz (PAL) or
\ 60 Hz (NTSC) -- one interrupt per video frame.
\
\ One PAL frame  = 20 ms
\ One NTSC frame = approximately 16.7 ms
\
\ ISR-SYNC is a CODE word (from lib/INTERRUPTS.f) that executes a
\ Z80 HALT instruction.  HALT suspends the CPU until the next
\ interrupt fires, giving exact frame synchronisation.
\ In this demo we use directly CODE ISR-SYNC with no NEEDS INTERRUPT needed.
\
\ Usage pattern for frame-synchronised animation:
\
\   CODE ISR-SYNC $76 C, $DD C, $E9 C, SMUDGE 
\
\   BEGIN
\       ISR-SYNC    \ wait for next vertical blank
\       \ ... update display ...
\   ?TERMINAL UNTIL
\
\ Alternatively, use 20 ms for an approximate PAL frame delay:
\
\   BEGIN
\       \ ... update display ...
\       20 ms
\   ?TERMINAL UNTIL
\
\ ?TERMINAL ( -- f ): returns true when BREAK (CAPS SHIFT + SPACE)
\ is pressed.  Use it as the loop exit condition.

\ ===========================================================================
\ 3. Demo: simple counting animation using ms
\ ===========================================================================

: COUNT-DEMO  ( -- )
    0 0 .AT  ." Press BREAK to stop." CR
    0
    BEGIN
        1+
        1 0 .AT
        DUP .
        100 ms
        ?TERMINAL
    UNTIL
    DROP  CR
;

\ ===========================================================================
\ 4. Demo: stopwatch -- count elapsed seconds via the FRAMES counter
\ ===========================================================================
\
\ The naive way to count seconds is "1000 ms" inside the loop, but ms
\ *blocks* the CPU for a whole second: while it spins, the loop cannot
\ poll the keyboard, so BREAK only responds once per second and the
\ count drifts by however long the printing takes.
\
\ A far better timing source when interactivity matters is the ZX
\ system variable FRAMES at $5C78 (decimal 23672).  It is a 3-byte
\ counter that the 50 Hz (PAL) / 60 Hz (NTSC) interrupt increments on
\ every video frame -- a free running real-time tick.  Reading it with
\ @ returns the low 16 bits, which is all we need to measure a delta
\ (it wraps only every ~21 minutes at 50 Hz).
\
\ The loop below never blocks: it spins reading FRAMES and polling
\ ?TERMINAL every iteration (so BREAK reacts instantly), and bumps the
\ seconds counter only once /SEC ticks have elapsed.  Advancing the
\ baseline by exactly /SEC each time keeps it phase-locked to the
\ interrupt -- no cumulative drift from the time spent printing.

$5C78 CONSTANT FRAMES   \ ZX system tick at 23672: 3-byte counter,
                        \ +1 on every 50 Hz (PAL) / 60 Hz (NTSC) interrupt

\ /SEC is the number of frames in one second.  Rather than hard-code it,
\ read the live video timing from Next register $05 (Peripheral 1):
\ bit 2 = 0 -> 50 Hz (PAL), bit 2 = 1 -> 60 Hz (NTSC).  Because the
\ machine can switch modes at run time, /SEC is a VALUE, refreshed by
\ ?VIDEO-HZ (call it again after changing the video mode).
50 VALUE /SEC           \ frames per second; set for real just below

: ?VIDEO-HZ  ( -- )     \ refresh /SEC from the current 50/60 Hz timing
    $05 REG@  $04 AND   \ isolate bit 2 of Peripheral 1 register
    IF  60  ELSE  50  THEN  TO /SEC
;

: STOPWATCH  ( -- )
    ?VIDEO-HZ           \ auto-detect once at load time
    0 0 .AT  ." Stopwatch (BREAK to stop)" CR
    0                   ( secs )         \ elapsed seconds
    FRAMES @            ( secs base )    \ tick at the last whole second
    BEGIN
        ?TERMINAL 0=    ( secs base f )  \ run until BREAK is pressed
    WHILE               ( secs base )
        FRAMES @ OVER - ( secs base d )  \ d = ticks since base
        /SEC U< 0= IF   ( secs base )    \ a full second elapsed?
            /SEC +      ( secs base' )   \ advance base by one second's ticks
            SWAP 1+     ( base' secs+1 ) \ bump the seconds counter
            DUP 1 0 .AT  .  ."  seconds"
            SWAP        ( secs base' )   \ restore loop order
        THEN
    REPEAT              ( secs base )
    2DROP CR
;

\ ===========================================================================
\ 5. Demo: frame-synchronised flash using ISR-SYNC
\ ===========================================================================
\
\ The following demo uses ISR-SYNC for exact 50 Hz frame timing.

CODE ISR-SYNC  ( -- )
    $76 C,             \ halt
    $DD C, $E9 C,      \ jp (ix)   -- NEXT
    SMUDGE

: FRAME-FLASH  ( -- )
    ." Frame-sync flash demo." CR
    ." BREAK to stop." CR
    0
    BEGIN
        1+
        DUP 25 MOD 12 < IF  7  ELSE  0  THEN
        ISR-SYNC        \ wait for vertical blank
        .BORDER
        ?TERMINAL
    UNTIL
    DROP
    0 .BORDER
    CLS
;

\ ===========================================================================
\ 6. Cumulative demo
\ ===========================================================================

: DEMO
    LAYER0 CLS
    FRAME-FLASH     WAIT-KEY 
    COUNT-DEMO      WAIT-KEY
    STOPWATCH       WAIT-KEY
    LAYER12 1 .PAPER
;

CR
.( Try: DEMO ) CR


\ ===========================================================================
\ 7. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ ms has no return value and cannot be verified automatically.
\ The following are structural tests only.
\
\ NEEDS TESTING
\ T{  0 ms  ->  }T     \ zero ms does nothing
\ T{  1 ms  ->  }T     \ 1 ms delay
