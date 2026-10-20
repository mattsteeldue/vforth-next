\
\ 073-rom-and-nextzxos-calls.f
\ Calling code that vForth did not write: a routine of the Spectrum ROM,
\ machine code already in memory, a service of NextZXOS.  BASIC has USR
\ for the first two and nothing for the third; vForth has CALL# for
\ code that takes one number, a CODE word for code that wants more
\ registers, and M_P3DOS for the operating system.  The thread through
\ all of them: which registers go in, which come out, and which three
\ belong to Forth and must come back untouched.
\
\ vForth-specific notes:
\   - CALL# is in inc/call#.f (NEEDS CALL#); M_P3DOS is in the core.
\   - BC, DE and IX are Forth's: the instruction pointer, the return
\     stack pointer, the address of the inner interpreter.  Every word
\     below saves them around the call.  IY belongs to the interrupt.
\   - While vForth runs, the ROM paged in at $0000-$3FFF is the 48K BASIC
\     ROM: vForth itself prints through its RST $10 and selects streams
\     through its CHAN-OPEN at $1601.  The ROM addresses below are those
\     of the 48K ROM.
\   - The headless emulator has no ROM, so sections 3 and 4 are for the
\     machine or CSpect only; sections 2 and 5 run anywhere.
\
\ Coming from BASIC: Ch.25  |  doc/basic-to-vforth/
\ no Brodie counterpart (ZX Spectrum Next extension)
\ Reference: sec.2.12.14, 2.12.8
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   073 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 073 TUTORIAL
\
\ Run it with:  DEMO   (on the machine: it calls the ROM)
\

MARKER NEWTASK

CR
.( --- Tutorial 073: ROM and NextZXOS calls loaded. ) CR
.(     Type NEWTASK to unload.                      ) CR

NEEDS CALL#

\ =========================================================================
\ 1. USR, and what the code may touch
\ =========================================================================
\
\ BASIC's USR a jumps to address a with an ordinary CALL; the code ends
\ with RET, and BC at that moment is the number USR returns.  BASIC has
\ nothing of its own in the registers while USR runs.
\
\ Forth has.  Three registers carry the state of the interpreter, and
\ code that changes them and does not put them back crashes vForth the
\ moment it returns:
\
\   BC   the instruction pointer: where the current definition is
\   DE   the return stack pointer
\   IX   the address of NEXT, the inner interpreter
\
\ HL, A and the flags are free, and so is the alternate set, which
\ CODE words use to hide BC DE HL with EXX.  SP is the data stack.

\ =========================================================================
\ 2. CALL#: USR with one argument
\ =========================================================================
\
\   CALL#  ( n1 a -- n2 )
\
\ n1 goes into BC, and its low byte into A; the code at a is CALLed and
\ ends with RET; n2 is BC on return.  CALL# saves BC, DE and IX before
\ the call and restores them after, so the code may use them freely.
\
\ Machine code already in memory -- loaded from a file, POKEd by a BASIC
\ program, or built here with C, -- is called this way.  These five
\ bytes double the number in BC:

CREATE TWICE
    $CB C, $21 C,       \ sla c
    $CB C, $10 C,       \ rl  b
    $C9 C,              \ ret

\   21 TWICE CALL# .            => 42
\   20000 TWICE CALL# U.        => 40000
\
\ The 0 that USR does not need still goes on the stack when the code
\ wants no argument: 0 a CALL#, then DROP if it returns nothing.

\ =========================================================================
\ 3. A ROM routine through CALL#
\ =========================================================================
\
\ Some ROM routines want exactly what CALL# gives: one byte in A.  The
\ BORDER command of the 48K ROM starts at $2294 by fetching its number
\ from the calculator stack; three instructions later, at $229B, the
\ number is in A and the routine writes it to port $FE and keeps a copy
\ in the system variable BORDCR, as BASIC's BORDER does.

: ROM-BORDER  ( colour -- )  $229B CALL# DROP ;

\   2 ROM-BORDER                red border, and BORDCR updated
\
\ CAVEAT: entering a ROM routine in the middle skips its checks.  BASIC's
\ BORDER 9 stops with "K Invalid colour"; 9 ROM-BORDER writes 9 to the
\ port and a garbage BORDCR.  The range is the caller's job: 7 AND first.
\ CAVEAT: a ROM routine that does raise an error (RST $08 with an error
\ code) falls back to BASIC, not to the vForth prompt.  RUN resumes vForth.

\ =========================================================================
\ 4. More registers: a CODE word around the call
\ =========================================================================
\
\ BEEPER, at $03B5, makes a sound: DE is the number of cycles, HL the
\ length of one cycle (437500/f - 30 for a frequency f in Hz).  CALL#
\ cannot load DE and HL, so a CODE word does: it takes the two numbers
\ off the data stack, saves Forth's registers on it, and calls the ROM.
\ It is the pattern of inc/call#.f, with two arguments instead of one.

CODE ROM-BEEP  ( cycles length -- )
    $D9 C,              \ exx            alternate set: arguments
    $E1 C,              \ pop hl         length
    $D1 C,              \ pop de         cycles
    $D9 C,              \ exx            Forth's BC DE back
    $DD C, $E5 C,       \ push ix
    $D5 C,              \ push de        save Forth's registers
    $C5 C,              \ push bc
    $D9 C,              \ exx            arguments in HL and DE
    $CD C, $03B5 ,      \ call $03B5     BEEPER
    $C1 C,              \ pop bc         Forth's registers back
    $D1 C,              \ pop de
    $DD C, $E1 C,       \ pop ix
    $DD C, $E9 C,       \ jp (ix)
    SMUDGE

\ Middle A, 440 Hz, for half a second: 220 cycles of 437500/440 - 30.

: A4  ( -- )  220  437500. 440 UM/MOD NIP 30 -  ROM-BEEP ;

\ 437500 does not fit in a cell: it is written as a double (the dot) and
\ divided with UM/MOD, which divides a double by a cell (tutorial 015).
\ vForth's own BEEP (NEEDS BEEP, tutorial 033) is the practical word; the
\ point here is how a ROM routine with several registers is reached.

\ =========================================================================
\ 5. NextZXOS: M_P3DOS
\ =========================================================================
\
\ The services of NextZXOS (files, memory pages, the clock, the display
\ mode) are entered at fixed addresses of a jump table in ROM 2, after
\ paging the right ROM and RAM in and moving the stack.  M_P3DOS does
\ all of that:
\
\   M_P3DOS  ( hl de bc a addr -- hl' de' bc' a' f )
\
\ The four registers go in from the stack in that order and come back in
\ the same order; f is 0 when NextZXOS reported success and not 0 on an
\ error, A then holding the error code.
\ The documentation of each service gives its address, what it wants in
\ which register and what it gives back: the rest is mechanical.
\
\ IDE_RTC, at $01CC, takes nothing and gives the date in BC and the
\ time in DE (the MS-DOS format of tutorial 072).  Its word, in
\ inc/IDE_RTC.f, is this one, and here it is again:

: RTC  ( -- time date f )
    0 0 0 0  $01CC M_P3DOS      ( hl de bc a f )
    >R  DROP  ROT DROP  R> ;    ( de bc f )

\   RTC . . .                   the flag, the date, the time
\
\ Leaving the flag on top, as all the F_ words do, lets the caller test
\ it at once, with IF or with n ?ERROR.  (The headless emulator, which
\ has no clock, answers this call with a flag of 1.)
\
\ The other door to the system is RST $08 followed by a byte, the
\ esxDOS "hook codes": M_GETDATE ($8E) and M_DOSVERSION ($88) in inc/
\ are CODE words of a dozen bytes each, worth reading after this one.

\ =========================================================================
\ 6. Demo: the border, by ROM
\ =========================================================================
\
\ Cycles the border through the eight colours with the ROM's own
\ routine, plays the A, and leaves the border as BASIC set it.

23624 CONSTANT BORDCR

: BORDER@  ( -- colour )  BORDCR C@ 3 RSHIFT 7 AND ;

: DEMO  ( -- )
    BORDER@
    8 0 DO  I ROM-BORDER  5000 0 DO LOOP  LOOP
    A4
    ROM-BORDER ;

\ =========================================================================
\ 7. Simple tests (requires NEEDS TESTING)
\ =========================================================================
\
\ Only the code built here can be tested without a ROM:
\
\ NEEDS TESTING  DECIMAL          \ lib/testing.f leaves BASE in HEX
\ T{  21 TWICE CALL#  ->  42  }T
\ T{  -1 TWICE CALL#  ->  -2  }T
\ T{  437500. 440 UM/MOD NIP 30 -  ->  964  }T
