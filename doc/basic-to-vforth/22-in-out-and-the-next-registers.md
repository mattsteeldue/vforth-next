# Chapter 22 - IN, OUT and the Next Registers

[From NextBASIC to vForth](README.md)

Manual: Chapter 22, pp. 229-246.

## In short

All of it carries over, one word for one keyword. `IN` is `P@`, `OUT`
is `P!`, the two forms of `REG` are `REG@` and `REG!`, and all four are
in the core. The tables of ports and of Next registers that fill most of
the manual's chapter describe the hardware: they hold for vForth as they
are, and this guide does not repeat them. What vForth adds is a library
for most groups of ports (keyboard, mouse, sound, DMA, UART, sprites) and
something BASIC cannot do at all: an interrupt routine written in Forth.

## What changes

**The value comes first.** As with `POKE` and `C!`, the address goes on
top of the stack, so it is written last:

| NextBASIC | vForth |
|---|---|
| `OUT 254,3` | `3 254 P!` |
| `IN 65278` | `65278 P@` |
| `REG 7,3` | `3 7 REG!` |
| `REG 7` | `7 REG@` |

**`OUT` and `IN` are not port words.** In vForth `OUT` is a variable of
the system that counts the characters sent to the output: `OUT @` gives
a number that only grows, and `OUT` used as a command just leaves an
address on the stack. There is no `IN` at all. In BASIC `IN` is also the
search in a string ([Chapter 8](08-functions.md)); `>IN`, which you will
meet in vForth, is something else again: the position reached in the
line being interpreted.

**The port is the whole 16-bit address.** `P@` and `P!` put the full
number on the address bus, as `IN` and `OUT` do, so the partial decoding
described by the manual works the same way. The keyboard is the clearest
case: the upper byte chooses the half-rows, and a 0 in it selects all
eight. `254 P@` reads every key at once, and is a test for "any key":

```forth
: ANY-KEY?  ( -- n )  254 P@ 31 AND 31 XOR ;
ANY-KEY? .                      \ => 0
```

The five lower bits are 1 for the keys that are up; `31 XOR` turns them
into a number that is not zero as soon as one of them is down, which is
all that `IF` needs ([Chapter 12](12-conditions.md)).

**No "same line" rule.** The manual asks for the two `OUT`s of a Next
register on one line, so that BASIC does not select another register in
between. `REG!` and `REG@` do both steps inside one word, and nothing of
vForth runs between them. Writing the two steps by hand with `P!` and
`P@` is just as safe:

```forth
: MY-REG@  ( n -- b )  9275 P!  9531 P@ ;
7 MY-REG@ 3 AND  7 REG@ 3 AND  = .  \ => -1
```

The one thing that can come in between is an interrupt. If your own
interrupt routine (below) writes Next registers, the main program can
read the wrong one; keep the registers out of the routine, or switch the
interrupts off around the access with `ISR-DI` and `ISR-EI`.

**A bit of a register.** `REG 5&@100>>2`, bit 2 of register 5, is a
mask and a shift, written after their numbers:

<!-- no-test -->
```forth
5 REG@ 4 AND 2 RSHIFT .
```

To test the bit the shift is not needed: `5 REG@ 4 AND` is not zero when
the bit is set, and `IF` takes it as true. Chapter 17 uses it in `HZ`.

**Changing some bits and not the others.** Read, clear the bits with a
mask, put in the new ones, write back. A word does it once for all:

```forth
NEEDS INVERT
: REG-BITS!  ( v mask reg -- )
    >R  R@ REG@  OVER INVERT AND  -ROT AND  OR  R> REG! ;
$5A $7F REG!
%0011 %1111 $7F REG-BITS!  $7F REG@ .   \ => 83
```

The mask says which bits change (here the lower four), the value gives
them; `$5A` becomes `$53`, 83. Register `$7F` is the user register: it
does nothing, and is the right one to experiment on. To set a single bit,
an `OR` is enough: `$69 REG@ $80 OR $69 REG!`.

**`RUN AT` is a register.** `RUN AT n` writes register 7. vForth has a
word for each direction:

```forth
NEEDS SPEED!
NEEDS SPEED@
1 SPEED!  SPEED@ .  3 SPEED!    \ => 1
```

`n SPEED!` is `n 7 REG!`; `SPEED@` is `7 REG@ 3 AND`, the speed asked
for, from 0 (3.5 MHz) to 3 (28 MHz).

**The border: port or ROM.** `OUT 254,c` changes the colour of the
border and nothing else. `.BORDER` goes through the ROM, which also
keeps the colour in the system variable BORDCR (23624), as `BORDER` does
in BASIC. The ROM paints the border again from there, so a colour sent
to the port lasts only until the ROM does that:

```forth
NEEDS .BORDER
: BORDER@  ( -- c )  23624 C@ 3 RSHIFT 7 AND ;
5 .BORDER  2 254 P!  BORDER@ .  \ => 5
```

The border is red, but the system variable still says cyan.

**The keyboard, half-row by half-row.** The manual's formula for the
address of half-row *n* becomes:

```forth
: HALF-ROW  ( n -- port )  1 SWAP LSHIFT  255 SWAP -  256 *  254 + ;
0 HALF-ROW U.  3 HALF-ROW U.    \ => 65278 63486
```

`U.` prints the address without a sign: above 32767 `.` would show it as
negative. A bit at 0 means the key is pressed, as in BASIC. For more than
a key or two, `NEEDS KEYBOARD` scans the whole matrix and names the keys
([Chapter 14](14-more-about-print-and-input.md)).

**The paging ports are not for vForth programs.** `7FFDh`, `1FFDh` and
`DFFDh` crash BASIC when written carelessly; they do the same to vForth.
vForth maps memory with the MMU registers instead, `$50` to `$57`, and
leaves one of them, MMU7, to the program: `MMU7!` and `MMU7@`. That is
the subject of [Chapter 23](23-the-memory.md).

**Interrupts are in reach.** The manual lists the interrupt registers
(`$C0` and after) but BASIC gives no way to run your own code on an
interrupt. vForth does: `NEEDS INTERRUPTS` loads a routine that, fifty
times a second, first lets the ROM do its usual work and then executes
the Forth word stored in `ISR-XT`.

<!-- no-test -->
```forth
NEEDS INTERRUPTS
VARIABLE TICKS
: TICK  ( -- )  1 TICKS +! ;
' TICK ISR-XT !  ISR-ON
TICKS @ .
ISR-OFF
```

`TICKS` goes up by one every frame while your program does something
else. The word must be short, leave the stack as it found it and not
wait for anything. `ISR-OFF` puts back the interrupt of the ROM.
Tutorial `049` shows more. The library uses the frame interrupt of the
ULA, the one BASIC has; the interrupt controller of the Next (lines,
UART, CTC: registers `$C0` to `$CE`) has no library yet.

## Correspondence table

| NextBASIC | vForth | Note |
|---|---|---|
| `IN p` | `p P@` | |
| `OUT p,v` | `v p P!` | Value first. |
| `REG n` | `n REG@` | |
| `REG n,v` | `v n REG!` | Value first. |
| `OUT 9275,n: OUT 9531,v` | `n 9275 P!  v 9531 P!` | Same as `REG!`. |
| `REG n&m` | `n REG@ m AND` | |
| `>> n`, `<< n` | `n RSHIFT`, `n LSHIFT` | |
| some bits of a register | `REG-BITS!` | Defined above. |
| `RUN AT n` | `n SPEED!` | `NEEDS SPEED!`; reading: `SPEED@`. |
| `IN 65278` and the other half-rows | `65278 P@` | `HALF-ROW` above; `NEEDS KEYBOARD`. |
| `IN 254`, any key | `254 P@ 31 AND 31 XOR` | `ANY-KEY?` above. |
| `OUT 254,c` | `c 254 P!` | `c .BORDER` also sets BORDCR. |
| `OUT 7FFDh`, `1FFDh`, `DFFDh` | -- | MMU registers instead: [Chapter 23](23-the-memory.md). |
| MMU registers `$50`-`$57` | `MMU7!`, `MMU7@` | Only MMU7 belongs to the program. |
| `OUT 65533`, `OUT 49149` (AY) | `v r AY!` | `NEEDS AY`; [Chapter 18](18-sound-and-music.md). |
| Kempston joystick, ports 31 and 55 | `31 P@`, `55 P@` | [Chapter 14](14-more-about-print-and-input.md). |
| Kempston mouse | `NEEDS MOUSE` | Tutorial `044`. |
| sprite ports `303Bh`, `57h`, `5Bh` | `NEEDS SPRITE` | [Chapter 17](17-time-and-motion.md). |
| DMA ports `6Bh`, `0Bh` | `NEEDS DMA` | Tutorial `054`. |
| UART ports `133Bh`-`163Bh` | `NEEDS UART-SYS` | Tutorial `047`. |
| DAC, SPI, I2C, CTC | `P@`, `P!` | No library. |
| (not in BASIC) an interrupt routine | `NEEDS INTERRUPTS` | `ISR-XT`, `ISR-ON`, `ISR-OFF`. |
| `NEXTREG` (Z80N instruction) | `REG!`, or in `CODE` | [Chapter 25](25-using-machine-code.md). |

## Side by side

**How fast?** Read the speed, slow down, report, go back.

```
10 LET s=% REG 7&3
20 PRINT "Speed: ";s
30 RUN AT 0
40 PRINT "Now: ";% REG 7&3
50 RUN AT s
```

```forth
: SLOW-REPORT  ( -- )
    SPEED@  ." Speed: " DUP . CR
    0 SPEED!  ." Now: " SPEED@ . CR
    SPEED! ;
SLOW-REPORT
```

```text
Speed: 3
Now: 0
```

The old speed waits on the stack, where BASIC needs the variable `s`,
and `SPEED!` at the end takes it from there.

**Wait for SPACE.** The bottom right half-row is port 32766, and SPACE
is its bit 0.

```
10 PRINT "Press SPACE"
20 IF %IN 32766&1 THEN GO TO 20
30 PRINT "Thank you"
```

```forth
: SPACE?  ( -- flag )  32766 P@ 1 AND 0= ;
: WAIT-SPACE  ( -- )
    ." Press SPACE" CR
    BEGIN SPACE? UNTIL
    ." Thank you" CR ;
SPACE? .                        \ => 0
```

`0=` turns "bit at 0" into "true", so that `UNTIL` can wait for it. Type
`WAIT-SPACE` to try it on the machine.

**Stripes on the border.** Eight colours sent straight to the port, then
the border the system knows about.

```
10 FOR c=0 TO 7
20   OUT 254,c: PAUSE 10
30 NEXT c
40 OUT 254,% PEEK 23624>>3&7
```

```forth
NEEDS MS
: STRIPES  ( -- )
    8 0 DO  I 254 P!  200 MS  LOOP
    BORDER@ 254 P! ;
STRIPES
```

The last line of each listing puts the border back as BORDCR says, which
is what the ROM would do anyway the next time it paints it. `BORDER@`
was defined above.

## No equivalent

- **The tables of the manual.** The ports and the Next registers are the
  hardware, and are the same under vForth: keep the manual open.
- **`IN` and `OUT` as names.** `OUT` exists with another meaning, `IN`
  does not exist.
- **The Next's interrupt controller.** Registers `$C0` to `$CE` can be
  written with `REG!`, but no library sets up the hardware interrupt
  mode yet; `NEEDS INTERRUPTS` uses the frame interrupt.
- **DAC, SPI, I2C and CTC.** No words of their own: `P@`, `P!` and
  `REG!`, following the manual.

## Further reading

- Tutorial `040` -- `REG!`, `REG@`, `SPEED!`, `SPEED@`.
- Tutorial `049` -- interrupts: `ISR-XT`, `ISR-ON`, `ISR-OFF`.
- Tutorial `051` -- the keyboard matrix, `NEEDS KEYBOARD`.
- Tutorial `030` -- the ULA and the border.
- Tutorial `041` -- the MMU and `MMU7!`.
- Tutorials `044`, `047`, `054`, `066` -- mouse, UART, DMA, joystick.
- `HELP P@`, `HELP P!`, `HELP REG@`, `HELP REG!`, `HELP SPEED!`.
- [Chapter 17](17-time-and-motion.md) -- frames, `HZ`, the Layer 2 and
  sprite registers.

<!-- nav -->
---

Previous: [Chapter 21 - Optional Features](21-optional-features.md) |
[Contents](README.md) |
Next: [Chapter 23 - The Memory](23-the-memory.md)
