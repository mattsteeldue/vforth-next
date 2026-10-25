# Chapter 13 - The Character Set

[From NextBASIC to vForth](README.md)

Manual: Chapter 13, pp. 74-80.

## In short

The character set is the machine's, not the language's: the same 256 codes,
drawn by the same ROM, with the same control codes. What changes is that
Forth has no character type. A character is just its code, so `CHR$` and
`CODE` have nothing to convert: printing a code is `EMIT` (or `EMITC`),
and reading the code of a character is `CHAR` or `C@`. User-defined
graphics work as in BASIC, but they are better kept in a table of your own
than written over BASIC's. And string order has one surprise: `COMPARE`
ignores case unless you ask otherwise.

## What changes

**A character is a number.** BASIC keeps characters and codes apart and
converts between them. In Forth a character on the stack *is* its code,
so `CHR$` and `CODE` have no work to do. What is left is printing a code
and getting the code of a character you type:

```forth
65 EMIT                         \ => A
CHAR A .                        \ => 65
CHAR abc .                      \ => 97
```

`CHAR` takes the first character of the word that follows it, as `CODE`
does with a string. Inside a definition it is `[CHAR]`, for the reason
given in [Chapter 1](01-basic-programming-concepts.md). For a string held
as an address and a length, the first code is simply `C@` of the address.

**`CODE` is a false friend.** In Forth `CODE` starts a definition written in
machine code ([Chapter 25](25-using-machine-code.md)). It has nothing to do
with characters.

**`EMIT` keeps seven bits from 144 up, `EMITC` all eight.** `EMIT` is
meant for text. It lets the block graphics through, codes 128 to 143, but
from 144 up it drops the top bit, so the code comes out as another
character. The UDGs and the tokens need `EMITC`:

```forth
65 EMIT 193 EMIT                \ => AA
66 EMITC                        \ => B
: GRAPHICS  ( -- )  144 128 DO  I EMITC  LOOP ;
GRAPHICS
```

`GRAPHICS` prints the sixteen block symbols, codes 128 to 143: the
exercise of the "Battenburg cake" is solved by looking at them. Here
`I EMIT` would do as well.

**There is no range check.** BASIC stops `CHR$ 300` with
`B Integer out of range`. `EMIT` keeps the low eight bits and prints
whatever they are:

```forth
300 EMIT                        \ => ,
```

300 is 256 + 44, and 44 is the comma.

**Binary numbers are written with `%`.** BASIC's `BIN 01111100` is
`%01111100`. To type many of them, `NEEDS BINARY` gives `BINARY`, which
switches the base until `DECIMAL`:

```forth
%01111100 .                     \ => 124
NEEDS BINARY
BINARY 01111100 DECIMAL .       \ => 124
```

**UDGs live where the system variable UDG says.** As in BASIC, the codes
144 to 164 are drawn from 21 patterns of 8 bytes, starting at the address
held in the system variable UDG (23675). BASIC normally keeps them at the
top of memory, from 65368 (`$FF58`). In vForth that address is not where
BASIC left it. The top 8K of the address space, `$E000-$FFFF`, is a
window (MMU7) through which vForth pages in its heap, the names of all
its words, and the 8K page sitting there changes all the time: BASIC's
own page is not in it while Forth runs. A byte stored at `$FF58` goes
into whichever heap page happens to be there; it does no harm, because
vForth never allocates the last 257 bytes of a heap page
(`PAGE-WATERMARK`) precisely so that such stray writes fall into empty
space, but it is lost. And when `EMITC` prints a UDG, the ROM reads the
pattern from whatever page is in the window at that moment. So
`POKE USR "a"+n,r` is not translated by storing at BASIC's address. The
Forth way is to build the patterns in the dictionary, below `$E000`, as
a table, and point UDG at the table:

```forth
23675 @ CONSTANT BASIC-UDG
CREATE SHAPES
  %00000000 C, %01101100 C, %11111110 C, %11111110 C,
  %01111100 C, %00111000 C, %00010000 C, %00000000 C,
  %00010000 C, %00111000 C, %01111100 C, %11111110 C,
  %01111100 C, %00111000 C, %00010000 C, %00000000 C,
SHAPES 23675 !
144 EMITC 145 EMITC
```

The table needs only as many patterns as you use, counted from `A`: here
two, a heart for `A` and a diamond for `B`. `BASIC-UDG` keeps the old
value, so that `BASIC-UDG 23675 !` gives BASIC its UDGs back. The table
replaces `READ`, `DATA` and the loop of `POKE`s
([Chapter 5](05-read-data-restore.md)): each `C,` stores one row.

**A pattern is just bytes.** Nothing stops you reading the table back.
This word draws a pattern with `#` and `.`, one row per line:

```forth
: .ROW  ( b -- )
    8 0 DO
        DUP 128 AND IF  [CHAR] #  ELSE  [CHAR] .  THEN EMIT
        2*
    LOOP DROP ;
: .SHAPE  ( a -- )  8 0 DO  CR DUP I + C@ .ROW  LOOP DROP ;
SHAPES .SHAPE
```

```text
........
.##.##..
#######.
#######.
.#####..
..###...
...#....
........
```

`SHAPES 8 + .SHAPE` draws the diamond.

**`NEEDS UDG+` gives the letters.** `lib/udg+.f` turns a letter into its
UDG code (`UDG+`), compiles one into a definition (`[UDG]`), finds the
address of a pattern (`UDG@`, BASIC's `USR "a"`, through the same system
variable), lists all the UDGs (`UDGs`) and draws one (`.UDG`):

```forth
NEEDS UDG+
CHAR S UDG+ .                   \ => 162
CHAR B UDG@ SHAPES - .          \ => 8
: HEARTS  ( n -- )  0 ?DO  [UDG] A EMITC  LOOP ;
3 HEARTS
```

`UDG+` does not check that the letter is one of `A` to `U`: `CHAR Z UDG+`
gives 169.

**More than 21 UDGs.** The manual stops at 21, `A` to `U`, codes 144 to
164, but nothing in the table says where it ends: it is just bytes, and
a longer table holds more patterns. Developing the game
`demo/chomp-chomp/chomp-chomp.f` showed that the screen goes on past
`U`: code 165 is drawn from the 22nd pattern, `V`, and so on up to `Z`,
169, the 26th. The game uses them for the small dot, a wall piece and
three fruits. The game draws on Layer 1,1 (`LAYER11`). Tried by the
author in BASIC on every layer: on all of them but Layer 0 the UDGs go
on up to code 255, the 112th pattern, and the codes the table does not
hold show whatever bytes follow it, random shapes. Layer 0 is the
exception: there the 48K ROM prints its keywords from 165 on, never a
pattern ([Appendix A](app-a-character-set-z80n-control-codes.md)). A
table for all of them takes 112 times 8 bytes, 896.

**Control codes are sent with `EMITC`.** The codes below 32 do the same
things as in BASIC, because the same ROM routine receives them: 8 moves
back one place, 13 goes to a new line (`CR` does it by name), 16 to 23
take arguments (ink, paper, `AT`, `TAB`):

```forth
." 1234" 8 EMITC ." 5"          \ => 1235
```

A wrong argument after code 16 to 23 is an error *of the ROM*, and it ends
in BASIC, not at the `ok` prompt: `RUN` brings vForth back. The words
`.INK`, `.PAPER`, `.AT` and the like keep the arguments in range, and are
the subject of Chapters 14 and 15.

**String order follows the codes, except for case.** `COMPARE`
(`NEEDS COMPARE`) puts strings in order exactly by the rule of the manual,
character by character and the shorter first, with one exception: at
start-up it does not distinguish capitals from small letters. `CASEON`
makes it do so, as BASIC does.

```forth
NEEDS COMPARE
NEEDS S"
: E1  S" EVIL" S" evil" COMPARE . ;
: E2  S" zoo" S" zoology" COMPARE . ;
: E3  S" AA man" S" AARDVARK" COMPARE . ;
E1 E2 E3                        \ => 0 -1 -1
CASEON
E1                              \ => -1
dup                             \ => dup? is undefined.
CASEOFF
```

The last line but one is the trap. `CASEON` does not belong to `COMPARE`:
it is a switch of the whole system, and it also makes the *names of words*
case-sensitive. While it is on, `dup` is no longer `DUP`, and a library
written in small letters cannot be loaded. Switch it on around the
comparisons that need it, and off again.

**Swapping two strings copies nothing.** BASIC's `a$,b$=b$,a$` becomes
`2SWAP`: the two address-length pairs change places on the stack, and the
characters stay where they were. The program that puts two strings in
order is in [Chapter 12](12-conditions.md).

## Correspondence table

| NextBASIC | vForth | Note |
|---|---|---|
| `CHR$ n` | `n EMIT`, `n EMITC` | A code is printed, not converted. `EMITC` from 144 up. |
| `CODE "x"` | `CHAR x`, `[CHAR] x` | `[CHAR]` inside a definition. |
| `CODE a$` | `a C@` | `a` is the address of the string. |
| `CHR$` out of range | -- | No error: only the low eight bits count. |
| `BIN 01111100` | `%01111100` | Or `BINARY` ... `DECIMAL`, `NEEDS BINARY`. |
| `USR "a"` | `CHAR A UDG@` | `NEEDS UDG+`. Follows the system variable UDG. |
| `POKE USR "a"+n,r` | `CREATE` a table with `C,`, then `t 23675 !` | Do not write at BASIC's address. |
| `CHR$ 144` ... `CHR$ 164` | `144 EMITC`, `[UDG] A EMITC` | `NEEDS UDG+` for `[UDG]`. |
| `CHR$ 6` | `6 EMITC` | As a comma in `PRINT`. |
| `CHR$ 8` | `8 EMITC` | Back one place. |
| `CHR$ 13` | `CR` | Or `13 EMITC`. |
| codes 16 to 23 | `.INK`, `.PAPER`, `.AT`, ... | Or `EMITC`, at your own risk. |
| `a$<b$`, `a$=b$` | `COMPARE 0<`, `COMPARE 0=` | `NEEDS COMPARE`. Ignores case unless `CASEON`. |
| `a$,b$=b$,a$` | `2SWAP` | |
| `DPOKE 23606,a-256` | `a 256 - 23606 !` | A font of your own, 768 bytes. |
| tokens (165 to 255) | -- | Forth source is plain text. |
| Layer 3 | `NEEDS LAYER3`, `NEEDS TILE80` | A library, where BASIC has only `POKE` and `REG`. |

## Side by side

**The printable characters.** BASIC prints the whole set; here only the
capitals, then everything from the space to the `~`.

```
10 FOR a=65 TO 90: PRINT CHR$ a;: NEXT a
20 PRINT
30 FOR a=32 TO 126: PRINT CHR$ a;: NEXT a
```

```forth
: CAPITALS  ( -- )  [CHAR] Z 1+ [CHAR] A DO  I EMIT  LOOP ;
CAPITALS                        \ => ABCDEFGHIJKLMNOPQRSTUVWXYZ
: CHARSET  ( -- )  127 32 DO  I EMIT  LOOP ;
CHARSET
```

`[CHAR] Z 1+` is the limit, because `DO` stops one before it. Code 127 is
the copyright sign, outside ASCII: `127 EMITC` prints it.

**Two UDGs.** A heart and a diamond on `A` and `B`.

```
10 FOR n=0 TO 15
20   READ r: POKE USR "a"+n,r
30 NEXT n
40 PRINT CHR$ 144;CHR$ 145
50 DATA 0,108,254,254,124,56,16,0
60 DATA 16,56,124,254,124,56,16,0
```

That is `SHAPES`, in "What changes": the `DATA` lines become the table,
the loop of `POKE`s becomes one store into UDG, and the `PRINT` becomes
`144 EMITC 145 EMITC`. To fetch the patterns from somewhere else instead,
a file or a table built at run time, copy them into the table with
`CMOVE`: `src SHAPES 16 CMOVE`.

**An alternative font.** BASIC and Forth do the same thing here: 96
patterns of 8 bytes, codes 32 to 127, and the system variable CHARS
pointing 256 bytes before the first, the space. This one is a bold copy
of the ROM font: every byte is ORed with itself shifted one pixel to the
right, so each stroke gets twice as thick.

```
5 CLEAR 49999
10 LET a=50000
20 FOR n=0 TO 767
30 v=PEEK (15616+n)
40 POKE a+n, v|INT (v>>1)
50 NEXT n
60 DPOKE 23606,a-256
70 LIST
```

<!-- no-test -->
```forth
CREATE FONT  768 ALLOT
: BOLD  ( -- )
    768 0 DO  15616 I + C@  DUP 1 RSHIFT OR  FONT I + C!  LOOP ;
BOLD  FONT 256 - 23606 !
WORDS
```

The loop reads the ROM font, at 15616, and writes the bold version:
`v|INT (v>>1)` is `DUP 1 RSHIFT OR`. NextBASIC's `DPOKE` stores two
bytes, a whole address: that is Forth's `!`. BASIC needs `CLEAR 49999`
to keep its own data away from the font; `CREATE` takes the room in the
dictionary, where nothing else will use it. `LIST` and `WORDS` then show
the new letters. `15360 23606 !` puts the ROM font back. The font, like
the UDGs, must stay below `$E000`; a `CREATE` in the dictionary always
is.

**Order and case.** The third exercise: which is the lesser, `"EVIL"` or
`"evil"`?

```
10 PRINT "EVIL"<"evil"
```

BASIC prints 1: every capital has a smaller code than every small letter.
vForth's `COMPARE` gives 0 unless `CASEON` is on, as `E1` shows above.

## No equivalent

- **`CHR$` and `CODE` as conversions.** There is nothing to convert.
- **The error on `CHR$` out of range.** `EMIT` takes the low eight bits.
- **Tokens.** Forth source is plain text; a word is typed letter by letter.
  `EMITC` of a token code still prints it, through the ROM.
- **The graphics mode of the keyboard.** In Forth source a UDG is
  written by number, or by letter with `[UDG]`.

## Further reading

- Tutorial `071` -- block graphics computed from their quadrants, a UDG
  table of your own, patterns mirrored and rotated.
- Tutorial `003` -- `EMIT`, `CR`, `SPACE`, printing.
- Tutorial `060` -- `EMIT` against `EMITC` among the idiomatic traps.
- Tutorial `019` -- how `[UDG]` is built, as an example of `IMMEDIATE`.
- Tutorial `008` -- `C,`, `C@` and system variables.
- Tutorial `058` -- Layer 3, the tilemap.
- `demo/chomp-chomp.f` -- a game drawn with UDGs, with its own table.
- `HELP EMIT`, `HELP EMITC`, `HELP CHAR`, `HELP [CHAR]`, `HELP CASEON`,
  `HELP CASEOFF`, `HELP COMPARE`.
- [Chapter 5](05-read-data-restore.md) -- tables built with `C,`.
- [Chapter 7](07-strings.md) -- strings as an address and a length.

<!-- nav -->
---

Previous: [Chapter 12 - Conditions](12-conditions.md) |
[Contents](README.md) |
Next: [Chapter 14 - More about PRINT and INPUT](14-more-about-print-and-input.md)
