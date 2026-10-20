\
\ 072-real-time-clock.f
\ The real-time clock: reading the date and the time, taking them apart,
\ printing them, and computing with them.  NextZXOS gives them back as
\ two 16-bit numbers in the MS-DOS format of file dates, so the work is
\ unpacking bit fields; then a day of the week, the seconds between two
\ readings, and a clock that ticks on screen until BREAK.
\
\ vForth-specific notes:
\   - Two calls read the clock.  IDE_RTC goes through NextZXOS (M_P3DOS
\     $01CC) and returns no flag; M_GETDATE goes through esxDOS (RST $08,
\     $8E) and returns a flag that is 0 only when a clock module answered.
\     Use M_GETDATE when the program must know.
\   - Message 56 is "Real-Time-Clock module not present.", ready for
\     ?ERROR.
\   - The clock is set from BASIC (.time, .date) or by the NextZXOS menu;
\     vForth only reads it.
\   - The headless emulator answers both calls with numbers that mean
\     nothing (a year 2045, for instance): only the decoding below can be
\     checked there.  The live words want the machine, or CSpect.
\
\ Coming from BASIC: Ch.17, 21  |  doc/basic-to-vforth/
\ no Brodie counterpart (ZX Spectrum Next extension)
\ Reference: sec.2.12.14
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   072 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 072 TUTORIAL
\
\ Run it with:  DEMO   (BREAK stops the clock)
\

MARKER NEWTASK

CR
.( --- Tutorial 072: real-time clock loaded. ) CR
.(     Type NEWTASK to unload.               ) CR

NEEDS M_GETDATE
NEEDS SPLIT

\ =========================================================================
\ 1. Reading the clock
\ =========================================================================
\
\   M_GETDATE  ( -- date time hs f )
\
\ date and time are packed numbers (section 2).  hs packs the exact
\ second in its high byte and the hundredths in the low one, $FF when
\ the module does not give them; SPLIT separates the two bytes, low one
\ first.  f is 0 when the clock answered; on error date and time are 0.
\
\ The flag first: a program that needs the clock stops at once, with
\ the message the block file keeps for this case.

: CLOCK  ( -- date time secs )
    M_GETDATE 56 ?ERROR         ( date time hs )
    SPLIT NIP ;                 ( date time secs )

\   CLOCK . . .                 the second, the time, the date
\
\ On a machine without a clock module CLOCK stops with
\ "CLOCK? Real-Time-Clock module not present.": the program does not go
\ on with a date of zeros.

\ =========================================================================
\ 2. The MS-DOS format: fields of bits
\ =========================================================================
\
\ Two cells hold six numbers:
\
\   time:  hhhhh mmmmmm sssss      hours 0-23, minutes 0-59, and the
\          15-11  10-5   4-0       seconds HALVED (0-29: 2-second steps)
\   date:  yyyyyyy mmmm ddddd      year from 1980, month 1-12, day 1-31
\          15-9    8-5  4-0
\
\ Each field is a shift and a mask: RSHIFT brings it to the bottom, AND
\ keeps its width.  The top field needs no mask: the shift has already
\ thrown the rest away.

: HOURS    ( time -- h )  11 RSHIFT ;
: MINUTES  ( time -- m )  5 RSHIFT 63 AND ;
: 2SECS    ( time -- s )  31 AND 2* ;

: YEAR     ( date -- y )  9 RSHIFT 1980 + ;
: MONTH    ( date -- m )  5 RSHIFT 15 AND ;
: DAY      ( date -- d )  31 AND ;

\ A fixed example, so that the decoding can be checked anywhere: 16:55:32
\ on 10 May 2023.

34544 CONSTANT TEA-TIME
22186 CONSTANT MAY-10

\   TEA-TIME HOURS . TEA-TIME MINUTES . TEA-TIME 2SECS .   => 16 55 32
\   MAY-10 YEAR . MAY-10 MONTH . MAY-10 DAY .              => 2023 5 10
\
\ Packing is the same in reverse: shift each field into place and OR
\ them together.  It is what a program needs to compare a date with a
\ given one, or to stamp a date of its own.

: >DATE  ( d m y -- date )
    1980 - 9 LSHIFT  SWAP 5 LSHIFT OR  OR ;

\   10 5 2023 >DATE .           => 22186

\ =========================================================================
\ 3. Printing: two digits, always
\ =========================================================================
\
\ "9:5" is not a time: each field is printed with two digits, a leading
\ zero if needed.  Pictured output (tutorial 014) does it: # always
\ produces a digit, even a zero.

: .00  ( n -- )  0 <# # # #> TYPE ;

: .HMS  ( h m s -- )
    ROT .00 [CHAR] : EMIT  SWAP .00 [CHAR] : EMIT  .00 ;

: .YMD  ( date -- )
    DUP YEAR 0 <# # # # # #> TYPE  [CHAR] - EMIT
    DUP MONTH .00                  [CHAR] - EMIT
    DAY .00 ;

\   TEA-TIME DUP HOURS SWAP DUP MINUTES SWAP 2SECS .HMS   => 16:55:32
\   MAY-10 .YMD                                           => 2023-05-10
\
\ The library has the same printing ready made: NEEDS .NOW gives .NOW,
\ which reads the clock (through IDE_RTC) and prints "2023-05-10 16:55",
\ the line of the start-up banner.

\ =========================================================================
\ 4. The day of the week
\ =========================================================================
\
\ The clock has no day of the week, but the date determines it.  This
\ is Sakamoto's method: a table of twelve month offsets, and January and
\ February counted as months of the year before, so that the leap day
\ comes at the end.  0 is Sunday.

CREATE MONTH-OFFSETS
    0 C, 3 C, 2 C, 5 C, 0 C, 3 C, 5 C, 1 C, 4 C, 6 C, 2 C, 4 C,

: WEEKDAY  ( d m y -- 0..6 )
    OVER 3 < IF  1-  THEN               ( d m y' )
    >R                                  ( d m )
    1- MONTH-OFFSETS + C@ +             ( d+offset )
    R@ +  R@ 4 / +  R@ 100 / -  R> 400 / +
    7 MOD ;

CREATE DAY-NAMES  ," SunMonTueWedThuFriSat"

: .DAY  ( 0..6 -- )  3 * DAY-NAMES 1+ + 3 TYPE ;

\   10 5 2023 WEEKDAY .DAY      => Wed
\   18 10 2026 WEEKDAY .DAY     => Sun
\
\ The numbers stay small enough for 16 bits up to the year 9999: y +
\ y/4 is at most 12498.

\ =========================================================================
\ 5. Seconds between two readings
\ =========================================================================
\
\ A day has 86400 seconds, too many for one cell: the seconds since
\ midnight are a double number (tutorial 015).  M* multiplies two cells
\ into a double, D+ adds doubles.

: >SECS  ( h m s -- d )
    >R  60 *                ( h m*60 )
    SWAP 3600 M*            ( m*60 d )
    ROT 0 D+  R> 0 D+ ;

\   16 55 32 >SECS D.           => 60932
\   23 59 59 >SECS D.           => 86399
\
\ The difference of two such numbers is the time in between, in
\ seconds, as long as midnight does not fall between the two readings.

\ =========================================================================
\ 6. Demo: a clock on screen
\ =========================================================================
\
\ NOW reads the clock and leaves the exact time: hours and minutes from
\ the time, the second from the high byte of hs, not the halved one.
\ TICK prints it in place, going back over its eight characters with
\ code 8, and only when the second has changed; BREAK stops it.  The
\ last second printed stays on the stack, under the new reading.

: NOW  ( -- h m s )
    CLOCK >R  NIP               ( time )
    DUP HOURS SWAP MINUTES  R> ;

: BACK8  ( -- )  8 0 DO  8 EMITC  LOOP ;

: .CLOCK  ( h m s -- s )  DUP >R .HMS BACK8 R> ;

: TICK  ( -- )
    -1                                  ( last )
    BEGIN
        NOW DUP 4 PICK =                ( last h m s f )
        IF  DROP 2DROP  ELSE  .CLOCK NIP  THEN
        ?TERMINAL
    UNTIL  DROP ;

: TODAY  ( -- )
    CLOCK 2DROP                         ( date )
    DUP .YMD SPACE
    DUP DAY  OVER MONTH  ROT YEAR       ( d m y )
    WEEKDAY .DAY ;

: DEMO  ( -- )
    CR TODAY SPACE TICK CR ;

\ =========================================================================
\ 7. Simple tests (requires NEEDS TESTING)
\ =========================================================================
\
\ NEEDS TESTING  DECIMAL          \ lib/testing.f leaves BASE in HEX
\ T{  TEA-TIME HOURS  TEA-TIME MINUTES  TEA-TIME 2SECS  ->  16 55 32  }T
\ T{  MAY-10 YEAR  MAY-10 MONTH  MAY-10 DAY  ->  2023 5 10  }T
\ T{  10 5 2023 >DATE  ->  22186  }T
\ T{  10 5 2023 WEEKDAY  18 10 2026 WEEKDAY  ->  3 0  }T
\ T{  1 1 2000 WEEKDAY  29 2 2024 WEEKDAY  ->  6 4  }T
\ T{  23 59 59 >SECS  ->  86399.  }T
