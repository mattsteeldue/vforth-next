# Chapter 21 - Optional Features

[From NextBASIC to vForth](README.md)

Manual: Chapter 21, pp. 220-228.

## In short

Most of this chapter is about fitting and testing the add-ons: the extra
memory, the WiFi module, the real time clock and the Raspberry Pi
accelerator. Fitting them is the same whatever language runs on the
machine, and so is setting the clock, which is done once from the
NextZXOS menu or from BASIC. What vForth adds is a way to use each of
them from a program: the extra memory as 8K pages through `MMU7!`, the
clock through `IDE_RTC` and `M_GETDATE`, the WiFi module and the Pi
through the UART, with `lib/RPi0.f`.

## What changes

**The extra memory is more pages.** The startup menu says 1792K instead
of 768K; vForth sees the same RAM in 8K pages, mapped one at a time at
`$E000` with `MMU7!`. A 1 MB machine has pages 0 to 95, a 2 MB one 0 to
223. Nothing else changes: a program that needs more room maps a higher
page. [Chapter 23](23-the-memory.md) is about memory.

**The clock answers on the stack.** `.time` and `.date` print; vForth
asks NextZXOS and gets numbers, in the format MS-DOS uses for file
dates. [Chapter 17](17-time-and-motion.md) takes the time apart; the
date is packed the same way, the year in the top 7 bits (counted from
1980), the month in the middle 4, the day in the bottom 5:

```forth
: YEAR   ( date -- y )  9 RSHIFT 1980 + ;
: MONTH  ( date -- m )  5 RSHIFT 15 AND ;
: DAY    ( date -- d )  31 AND ;
22186 DUP YEAR .  DUP MONTH .  DAY .   \ => 2023 5 10
NEEDS .FAT-DATE
22186 .FAT-DATE                 \ => 2023-05-10
```

**Is there a clock?** `M_GETDATE ( -- date time hs f )` leaves a flag
on top, 0 when the clock answered. It is the test the manual does with
`.time`, without the message:

<!-- no-test -->
```forth
NEEDS M_GETDATE
: RTC?  ( -- f )   M_GETDATE >R 2DROP DROP R> 0= ;
RTC? .                          \ -1 with a working clock
```

A machine without the clock, or with a clock never set, gives 0. The
clock cannot be set from vForth: dot commands, `.time` and `.date`
among them, run from BASIC, and so does `.nxtp`, which sets it from the
internet. Files written by vForth get the date and time of the clock,
as BASIC's do, and `DIR` shows them.

**The UART is reached directly.** BASIC talks to the WiFi module with
`.uart` or through a driver (`.install`, then `OPEN #` on a `d>`
channel, Chapter 20). vForth has no driver: `lib/RPi0.f` writes the
UART ports itself. The same UART serves the ESP WiFi module and the Pi,
and bit 6 of port `$153B` chooses which: 1 for the Pi, 0 for the ESP.

## Correspondence table

| NextBASIC | vForth | Note |
|---|---|---|
| 1792K in the menu | pages up to 223 | `MMU7!`, [Chapter 23](23-the-memory.md). |
| `2MBTEST` | -- | Run it from the Browser. |
| `.uart`, `AT` commands | `ESP`, `AT?` below | `NEEDS RPI0` first. |
| WiFi setup menu | -- | NextZXOS menu. |
| `.time` (reading) | `IDE_RTC`, `M_GETDATE`, `.NOW` | `NEEDS` each; Chapter 17. |
| `.date` (reading) | `YEAR`, `MONTH`, `DAY`, `.FAT-DATE` | `NEEDS .FAT-DATE`. |
| `.time` as a test | `M_GETDATE`, its flag | `NEEDS M_GETDATE`. |
| `.time "hh:mm:ss"`, `.date` | -- | Set it from BASIC. |
| `.time -di` | -- | Once, from BASIC. |
| `.nxtp` | -- | In `autoexec.bas`. |
| dates on saved files | the same | `DIR` shows them. |
| `terminex`, `SUP>` | `RPI0`, `TERM` | `NEEDS RPI0`. |
| a command to the Pi | `SH command` | `NEEDS SH`. |
| its answer | `ASK command`, then `PAD n TYPE` | `NEEDS ASK`. |

## Side by side

**Today's date.**

```
10 .date
20 .time
```

<!-- no-test -->
```forth
NEEDS .NOW
.NOW                            \ 2023-05-10 16:55
```

`.NOW` prints from the numbers `IDE_RTC` leaves, through `.FAT-DATE`
and `.FAT-TIME`. With `YEAR`, `MONTH` and `DAY` above, a program can
use the date instead of printing it: test the month, name a file after
the day.

**Is the WiFi module there?** In BASIC the test is `.uart`, then `AT`
typed by hand, and the answer `OK`. vForth sends the same two letters
from a program:

<!-- no-test -->
```forth
NEEDS RPI0  NEEDS S"
: ESP  ( -- )                       \ the UART to the ESP, 115200 baud
    0 UART-CT-PORT P!  115.200 UART-SET-BAUDRATE ;
: REPLY  ( -- )                     \ print until 200 ms of silence
    BEGIN  200 UART-RX-TIMEOUT ?DUP
    WHILE  DUP 10 = IF DROP ELSE EMIT THEN
    REPEAT ;
: AT?  ( -- )
    ESP  S" AT" UART-SEND-TEXT  UART-SEND-CR UART-SEND-LF  REPLY ;
AT?
```

The module echoes `AT`, then answers `OK`; nothing at all means no
module, or the wrong speed. `NEEDS RPI0` loads the
UART words and, at the end of the file, selects the Pi: `ESP` selects
the module afterwards. 115200 is the speed the module usually works
at; another firmware may want another, and `UART-SET-BAUDRATE` takes
it as a double number, with the dot.

**A command for the Pi.** The manual checks the accelerator with
`terminex` and its `SUP>` prompt. `RPI0` opens the same kind of
terminal, and `ASK` sends one line and keeps the answer:

<!-- no-test -->
```forth
NEEDS ASK
ASK uname -m
PAD SWAP TYPE
```

The answer goes into `PAD`, up to 1024 bytes, and `ASK` leaves its
length. `SH` sends a line and drops the answer.

## No equivalent

- **Fitting and testing the hardware**: the steps of the manual,
  `2MBTEST`, the WiFi setup menu, the NextPi SD card.
- **Setting the clock** (`.time -di`, `.time "..."`, `.date "..."`,
  `.nxtp`): dot commands, run from BASIC or from the NextZXOS menu.
  Setting it once is enough.
- **The ESP driver and network streams** (`.install espat.drv`,
  `OPEN #n,"d>N>TCP,..."`). vForth only reaches the UART: the `AT`
  commands are sent by the program, as in `AT?` above.

## Further reading

- Tutorial `047` -- the UART words.
- Tutorial `048` -- the Raspberry Pi: `RPI0`, `TERM`, the `#` command.
- Tutorial `041` -- pages and `MMU7!`.
- `HELP IDE_RTC`, `HELP M_GETDATE`, `HELP .NOW`, `HELP .FAT-DATE`,
  `HELP .FAT-TIME`, `HELP RPI0`, `HELP ASK`, `HELP SH`.
- [Chapter 17](17-time-and-motion.md) -- the time, and `.NOW`.
- [Chapter 20](20-channels-streams-drivers-and-windows.md) -- streams and
  drivers.

<!-- nav -->
---

Previous: [Chapter 20 - Channels, Streams, Drivers and Windows](20-channels-streams-drivers-and-windows.md) |
[Contents](README.md) |
Next: [Chapter 22 - IN, OUT and the Next Registers](22-in-out-and-the-next-registers.md)
