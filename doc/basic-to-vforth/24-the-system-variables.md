# Chapter 24 - The System Variables

[From NextBASIC to vForth](README.md)

Manual: Chapter 24, pp. 271-274.

## In short

The system variables are still there, at the same addresses, and
`C@`, `@`, `C!` and `!` read and write them as `PEEK`, `DPEEK`, `POKE`
and `DPOKE` do. vForth runs on top of the ROM and of NextZXOS: it
prints through the ROM, reads the keyboard through the interrupt of the
ROM, and calls NextZXOS for files. Every variable those parts use keeps
its meaning, so a good half of the table works as the manual says. The
other half describes the BASIC program, and while vForth runs, that
program is only the loader that started it. vForth has its own system
variables too, the user variables, and they are reached by name.

## What changes

**Two bytes are one cell.** `@` and `!` read and write a 16-bit
variable low byte first, which is the order the manual describes:
`DPEEK n` and `PEEK n+256*PEEK (n+1)` are both `n @`.

<!-- no-test -->
```forth
23730 @ U.                      \ RAMTOP: 25087, that is $61FF
```

**What vForth uses itself.** The core reads the keyboard through LAST K
(23560) and bit 5 of FLAGS (23611), shows the cursor as `C` or `L`
from bit 3 of FLAGS2 (23658), makes it blink with FRAMES (23672), and
sets SCR CT (23692) to 255 after each character it prints. Libraries
use SEED (23670) for `RND`, BORDCR (23624) for `.BORDER`, UDG (23675)
and CHARS (23606) for the characters. Writing into these changes how
vForth behaves, as it would change BASIC; that is sometimes what you
want, as in "Side by side".

**What still works as in BASIC.** Whatever the ROM does while vForth
runs:

- REPDEL (23561) and REPPER (23562), the delay and the speed of the
  key repeat;
- FLAGS2 (23658) bit 3, CAPS LOCK;
- CHARS and UDG ([Chapter 13](13-the-character-set.md));
- ATTR P, MASK P, ATTR T, MASK T and P FLAG (23693-23697), the colours
  of the ROM's printing, which `.INK` and its family set
  ([Chapter 15](15-colours.md));
- S POSN (23688-23689) and DF CC (23684), the print position on Layer 0;
- BORDCR ([Chapter 22](22-in-out-and-the-next-registers.md)), FRAMES
  ([Chapter 17](17-time-and-motion.md)), SEED
  ([Chapter 10](10-random-numbers.md)).

**What no longer means anything.** PROG, VARS, E LINE, NXTLIN, DATADD,
PPC, SUBPPC, NEWPPC, OLDPPC, ERR NR, and the variables of the editor and
of the calculator, describe the BASIC program and its state. While vForth
runs they describe the loader `Forth18_loader.bas`, which is waiting
underneath. vForth's errors do not go through ERR NR, and its words are
not BASIC lines. Read them if you like; do not write them, or the return
to BASIC may go wrong.

**What has no effect.** PIP (23609), the key click: vForth's `KEY` does
not click ([Chapter 18](18-sound-and-music.md)). RASP (23608), the
warning buzz: vForth does not buzz. SCR CT (23692): vForth sets it back
to 255 after every character, so a `POKE` to it is undone at once
([Chapter 14](14-more-about-print-and-input.md)). COORDS (23677): the
graphics of vForth do not go through the ROM's `PLOT`.

**What must not be touched.** The variables marked X and the routines
marked R, from 23296 up: the paging routines, BANKM (23388), BANK678
(23399), TSTACK. NextZXOS uses them every time vForth calls it, to read
a file or to load a word with `NEEDS`.

**RAMTOP is fixed.** BASIC's `CLEAR n` moves RAMTOP (23730). vForth is
loaded above it, at `$6366`, and moving it would put BASIC on top of
vForth. Leave it at `$61FF` ([Chapter 23](23-the-memory.md)).

**vForth's own system variables are words.** The state of the Forth
system is kept in *user variables*: `BASE` (the number base), `STATE`
(compiling or interpreting), `>IN` and `BLK` (where the interpreter is
reading), `DP` (the end of the dictionary, which `HERE` reads), `OUT`,
`SPAN`, `WARNING`, `S0`, `R0`, `FIRST` and others. Each name leaves the
address of its variable, so there is no table of numbers to remember:

```forth
BASE @ .                        \ => 10
WARNING @ .                     \ => 1
```

`HEX` is `16 BASE !`, `DECIMAL` is `10 BASE !`. `WARNING` chooses how
errors are reported: 1 prints the message from the block file, 0 only
its number.

## Correspondence table

| NextBASIC | vForth | Note |
|---|---|---|
| `PEEK n` | `n C@` | One-byte variables. |
| `DPEEK n`, `PEEK n+256*PEEK (n+1)` | `n @` | Low byte first, as in BASIC. |
| `POKE n,v` | `v n C!` | |
| `DPOKE n,v` | `v n !` | |
| `POKE 23561,d: POKE 23562,s` | `d 23561 C!  s 23562 C!` | Key repeat: works. |
| CAPS LOCK, 23658 bit 3 | `23658 C@ 8 XOR 23658 C!` | Works. |
| CHARS 23606, UDG 23675 | `@`, `!` | [Chapter 13](13-the-character-set.md). |
| SEED 23670 | `@`, `!`; `RANDOMIZE` | [Chapter 10](10-random-numbers.md). |
| FRAMES 23672 | `23672 @` | Two lower bytes; [Chapter 17](17-time-and-motion.md). |
| BORDCR 23624 | `BORDER@` | [Chapter 22](22-in-out-and-the-next-registers.md). |
| ATTR P 23693 and the others | `.INK`, `.PAPER`, ... | [Chapter 15](15-colours.md). |
| S POSN 23688-23689 | `COL`, `ROW` | Defined below; Layer 0. |
| SCR CT 23692 | -- | Always 255. |
| PIP 23609, RASP 23608 | -- | No click, no buzz. |
| COORDS 23677 | -- | Not updated by vForth's graphics. |
| PROG, VARS, PPC, ERR NR, ... | -- | They describe the BASIC loader. |
| RAMTOP 23730 | -- | Fixed at `$61FF`: do not move it. |
| 23296-23551, BANKM, BANK678 | -- | Used by NextZXOS: do not touch. |
| (Forth only) | `BASE`, `STATE`, `>IN`, `BLK`, `DP`, `WARNING`... | User variables, by name. |

## Side by side

**Faster key repeat.** A key held down repeats sooner and faster, for
example to move a cursor; then the usual values come back.

```
10 POKE 23561,15: POKE 23562,2
20 INPUT "Hold a key: ";a$
30 POKE 23561,35: POKE 23562,5
```

```forth
: FAST-KEYS  ( -- )  15 23561 C!  2 23562 C! ;
: SLOW-KEYS  ( -- )  35 23561 C!  5 23562 C! ;
FAST-KEYS  23561 C@ .           \ => 15
SLOW-KEYS
```

The repeat is made by the interrupt of the ROM, so it works for `KEY`
and `ACCEPT` as it does for `INPUT`.

**CAPS LOCK from a program.** Switch it over and say how it is now.

```
10 POKE 23658,% PEEK 23658^8
20 IF % PEEK 23658&8 THEN PRINT "CAPS LOCK on": STOP
30 PRINT "CAPS LOCK off"
```

```forth
: CAPS  ( -- )  23658 C@ 8 XOR 23658 C! ;
: .CAPS  ( -- )
    ." CAPS LOCK "  23658 C@ 8 AND IF ." on" ELSE ." off" THEN ;
CAPS .CAPS                      \ => CAPS LOCK on
CAPS .CAPS                      \ => CAPS LOCK off
```

`XOR` switches bit 3 and leaves the others alone. The two lines of the
test assume that CAPS LOCK starts off.

**Where is the cursor?** S POSN holds 33 minus the column and 24 minus
the line of the next character printed on Layer 0.

```
10 PRINT AT 5,10;"Hello";
20 LET c=33-PEEK 23688: LET r=24-PEEK 23689
30 PRINT AT 0,0;r,c
```

<!-- no-test -->
```forth
NEEDS .AT
: COL  ( -- n )  33 23688 C@ - ;
: ROW  ( -- n )  24 23689 C@ - ;
: WHERE?  ( -- )  5 10 .AT ." Hello"  COL ROW  0 0 .AT . . ;
WHERE?
```

`COL` and `ROW` are read before the cursor moves again: `.AT` changes
them too, which is why BASIC keeps them in `c` and `r` first. The two numbers come out in the order `ROW COL`, the last one
pushed being the first one printed: `5 15`. On the other layers the
windows of NextZXOS keep their own position.

## No equivalent

- **The variables of the BASIC program.** PROG, VARS, PPC, DATADD, ERR
  NR and the like describe the loader, not your Forth program.
- **`CLEAR` and RAMTOP.** The memory of vForth is fixed.
- **The scroll counter, the key click, the warning buzz.** vForth
  overrides the first and has neither of the others.
- **Writing the paging variables.** They belong to NextZXOS, which
  vForth calls all the time.

## Further reading

- Tutorial `008` -- `C@`, `C!`, `@`, `!`.
- Tutorials `004` and `019` -- the user variables `BASE` and `STATE`.
- Tutorial `032` -- FRAMES and the time.
- `HELP BASE`, `HELP WARNING`, `HELP USER`.
- [Chapter 13](13-the-character-set.md),
  [Chapter 14](14-more-about-print-and-input.md),
  [Chapter 15](15-colours.md), [Chapter 17](17-time-and-motion.md) --
  the variables already met in those chapters.

<!-- nav -->
---

Previous: [Chapter 23 - The Memory](23-the-memory.md) |
[Contents](README.md) |
Next: [Chapter 25 - Using Machine Code](25-using-machine-code.md)
