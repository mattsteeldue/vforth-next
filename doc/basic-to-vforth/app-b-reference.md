# Appendix B - Reference

[From NextBASIC to vForth](README.md)

Manual: Appendix B, pp. 288-296.

## In short

The manual's Appendix B has three parts: the reports, the list of
keywords and functions, and the number systems. The reports change the
most. vForth has numbered messages too, kept in the block file rather
than in the ROM, but it checks far less while a word is running: many
of BASIC's reports have no counterpart, because the mistake they catch
gives a wrong result instead of an error. The list of keywords becomes
the keyword index of this guide, a page of its own. The number systems
carry over almost unchanged: `$` and `%` are written as in NextBASIC,
and `BASE` chooses how numbers are read and printed.

## What changes

**What a report looks like.** BASIC stops with a code, a message, a
line and a statement: `2 Variable not found, 10:1`. vForth prints the
word it was reading when things went wrong, a `?` and the message, and
goes back to the prompt without `ok`:

```forth
XYZ                             \ => XYZ? is undefined.
DROP                            \ => DROP? Stack is empty.
```

There is no line number, because a word typed at the keyboard has none.
An error raised while a Screen or a file is being loaded also leaves the
position on the stack, and `NEEDS WHERE` gives `WHERE`, which shows the
Screen, the line and a caret under the word.

**An error empties the stack.** After the report the data stack is
empty, whatever was on it, and the return stack is reset as well:

```forth
1 2 XYZ                         \ => XYZ? is undefined.
.                               \ => .? Stack is empty.
```

There is no `CONTINUE`. A word that stopped is not resumed: fix what
was wrong and call it again.

**The messages are numbered.** `n MESSAGE` prints message `n`. The
numbers from 0 to 79 are vForth's own; those from -1 to -31 are the
standard codes of `THROW`, the same in every Forth (-13 "is undefined",
-10 "Division by zero"):

```forth
10 MESSAGE                      \ => Wrong array index.
-10 MESSAGE                     \ => Division by zero.
```

The texts are lines of Screens 2 to 8 of the block file: `9 LOAD` lists
them all, page by page, and `EDIT` can change them. The variable
`WARNING` decides how much is shown: 1, the default, prints the text;
0 prints only the number; -1 stops without a word.

```forth
0 WARNING !  10 MESSAGE  1 WARNING !       \ => msg#10
```

**Few checks at run time.** BASIC checks every subscript, every result
and every argument. vForth checks the stack at the end of each word
typed or loaded, and little else while a word runs. Integers have 16
bits and simply wrap around, a division by zero gives a meaningless
result, and an array index is not checked at all
([Chapter 11](11-arrays.md)):

```forth
32767 1 + .                     \ => -32768
65536 .                         \ => 0
5 0 /MOD . .                    \ => -1 -1
```

So `6 Number too big`, `B Integer out of range` and `3 Subscript wrong`
have no counterpart. The checks you need are the ones you write, and
`THROW` is how a word reports what it found
([Chapter 1](01-basic-programming-concepts.md)).

**Many errors come at compile time.** In BASIC a `NEXT` without `FOR`
or a `REPEAT` without `UNTIL` is found when the line runs. In Forth the
structures are checked while the definition is compiled, so the error
comes before the word exists:

```forth
: T1  LOOP ;                    \ => LOOP? Syntax error.
: T2  10 0 DO ;                 \ => ;? Bad definition end.
10 0 DO                         \ => DO? Can't be executed.
```

`T1` and `T2` are not defined: a definition that ends in an error
cannot be found afterwards. The third line is the opposite case, a word
that only works inside a definition typed outside one.

```forth
T1                              \ => T1? is undefined.
```

**A ROM error ends in BASIC.** Codes sent with `EMITC` are read by the
ROM, as `PRINT` is, and a wrong argument raises a BASIC report: `K
Invalid colour` after a wrong colour, `5 Out of screen` after an `AT`
off the screen. The report names a line of the loader, not of your
program, and `RUN` brings vForth back
([Chapter 14](14-more-about-print-and-input.md) and
[Chapter 15](15-colours.md)).

**Files report with a flag and a code.** `F_OPEN`, `F_READ` and the
other file words leave a flag, 0 when all went well
([Chapter 19](19-nextzxos-and-alternatives.md)). When `F_OPEN` fails,
the number it leaves in place of the handle is the error code of
NextZXOS, in the numbering of esxDOS: 5 is "No such file or dir", 18
"Already exists". The table under "Correspondence table" gives the
codes of the storage reports of the manual. `NEEDS` of a word that
has no file prints a message and goes on, without stopping:

```forth
NEEDS NOSUCHWORD                \ => NOSUCHWORD File not found.
```

**BREAK.** While a line, a Screen or a file is being interpreted, BREAK
stops it after the current word, silently, as `QUIT` does. `LIST`,
`INDEX` and `WORDS` stop on BREAK as well. A word of your own that
runs for a long time has to test `?TERMINAL` by itself
([Chapter 3](03-looping.md)): there is no `L BREAK into program`.

**Trapping is `CATCH` and `THROW`.** `ON ERROR` becomes a `CATCH`
around one call; `ERROR` in the handler, which raises the error again,
becomes `THROW`. A `THROW` that nobody catches prints the message of
its number. Both are in [Chapter 1](01-basic-programming-concepts.md)
and [Chapter 4](04-procedures-and-subroutines.md).

**Keywords and functions.** The alphabetical list of the manual, every
command and function with its syntax, is the subject of the keyword
index of this guide, [Keyword index](keyword-index.md): one line per
keyword, with the Forth word and the chapter where it is explained.

**Number systems.** NextBASIC's `$FF` and `@1010` (or `BIN 1010`) are
`$FF` and `%1010` in vForth: `@` is a Forth word, it reads a cell of
memory. The suffixes `h` and `b` of the manual are not read. `HEX`,
`DECIMAL` and `BINARY` (`NEEDS BINARY`) change the base for reading
and printing alike, until the next change; `BASE` holds it, so any base
can be stored there:

```forth
$FF .                           \ => 255
%1100 .                         \ => 12
255 HEX . DECIMAL               \ => FF
10 2 BASE ! . DECIMAL           \ => 1010
```

**Bytes, words and long words.** A *word* of the manual, 16 bits, is a
Forth *cell*: what `@` reads, what `!` stores and what `.` prints. A
byte is read with `C@` and stored with `C!`. A *long word*, 32 bits, is
a *double* cell: it is written with a dot (`100000.`) and printed with
`D.`. A cell is printed with its sign by `.` and without by `U.`, which
is why 65535 is also -1:

```forth
-1 U.                           \ => 65535
50000. 50000. D+ D.             \ => 100000
```

Setting a bit is `OR`, resetting it is `INVERT AND`, testing it is
`AND` ([Chapter 12](12-conditions.md)):

```forth
NEEDS INVERT
%0101 %0010 OR .                \ => 7
%0111 %0010 INVERT AND .        \ => 5
```

## Correspondence table

| NextBASIC | vForth | Note |
|---|---|---|
| `0 OK` | `ok` | The prompt. |
| `1 NEXT without FOR` | `LOOP? Syntax error.` | At compile time. |
| `2 Variable not found` | `name? is undefined.` | For any word, not only variables. |
| `3 Subscript wrong` | -- | Not checked. |
| `4 Out of memory` | `Dictionary full.`, `Heap full.` | Messages 2 and 12. |
| `5 Out of screen` | the same, from the ROM | Ends in BASIC; `RUN`. |
| `6 Number too big` | -- | Integers wrap around. |
| `7 RETURN without GO SUB` | -- | No `GO SUB`; a word returns by itself. |
| `8 End of file` | `F_READ` reads fewer bytes | No error. |
| `9 STOP statement` | `QUIT`, `ABORT` | [Chapter 1](01-basic-programming-concepts.md). |
| `A Invalid argument` | -- | Not checked. |
| `B Integer out of range` | -- | Only the low bits count. |
| `C Nonsense in BASIC` | `name? is undefined.` | From `EVALUATE` too. |
| `D BREAK - CONT repeats` | -- | No `CONTINUE`. |
| `E Out of DATA` | -- | A table has no end mark. |
| `F Invalid file name` | `F_OPEN` flag, code 7 | |
| `G No room for line` | `Dictionary full.` | |
| `H STOP in INPUT` | -- | `ACCEPT` has no `STOP`. |
| `I FOR without NEXT` | `;? Bad definition end.` | At compile time. |
| `K Invalid colour` | the same, from the ROM | Ends in BASIC; `RUN`. |
| `L BREAK into program` | `?TERMINAL` | Tested by hand. |
| `M RAMTOP no good` | -- | No `CLEAR`. |
| `N Statement lost` | -- | No line numbers. |
| `O Invalid stream` | the same, from the ROM | `SELECT` of a stream not open; ends in BASIC. |
| `P FN without DEF` | `name? is undefined.` | |
| `Q Parameter error` | `Stack is empty.` | Only when too few; extra values stay. |
| `R Tape loading error` | -- | |
| `d Too many parentheses` | `Syntax error.` | `PLAY`: more than five `(` open. |
| `k Invalid note` | `Syntax error.` | `PLAY`, `NEEDS PLAY`. |
| `l Too big`, `n Out of range` | `Invalid numeric argument.` | `PLAY`. |
| `m Note out of range` | -- | `PLAY` keeps the note within the chip's range. |
| `o Too many tied notes` | -- | `PLAY` ties any number. |
| `Loop error`, `No ENDIF` | `Syntax error.`, `Bad definition end.` | At compile time. |
| `No DEFPROC`, `No label` | `name? is undefined.` | |
| `Direct command error` | `Can't be executed.` | The opposite case: a compiling word typed outside a definition. |
| `ON ERROR` | `['] word CATCH` | `NEEDS CATCH`, `NEEDS [']`. |
| `ERROR` | `n THROW` | `NEEDS THROW`. |
| `ERROR$` | `n MESSAGE` | Prints it. |
| `Already exists` | code 18 | From `F_OPEN` and the other file words. |
| `Bad file number` | code 13 | |
| `Bad filename` | code 7 | |
| `Disk full` | code 9 | |
| `File not found` | code 5 | `NEEDS`: `File not found.`, message 43. |
| `In use` | code 23 | |
| `Invalid drive` | code 11 | |
| `Invalid path` | code 19 | `Directory not found.`, message 37, from `CD`. |
| `Out of handles` | code 12 | |
| `Read only` | code 24 | |
| `Wrong file type` | code 4 | |
| `$FF`, `FFh` | `$FF` | |
| `@1010`, `BIN 1010`, `1010b` | `%1010` | `@` is a word of its own. |
| a word, 16 bits | a cell: `@`, `!`, `.` | `U.` without sign. |
| a byte | `C@`, `C!` | |
| a long word, 32 bits | a double: `100000.`, `D.` | |
| setting, resetting a bit | `OR`, `INVERT AND` | `NEEDS INVERT`. |

## No equivalent

- **`CONTINUE`.** A word that stopped is called again.
- **The line and statement of a report.** At the keyboard there are
  none; for a Screen or a file, `WHERE` shows the place.
- **Most run-time checks.** Overflow, subscripts, `DATA`, ranges: see
  "Few checks at run time".
- **Two `PLAY` reports**, `m` and `o`: `PLAY` keeps a note within the
  chip's range and ties any number of notes.
- **Retry, Ignore or Cancel.** A file word that fails returns at once,
  with its flag and code.

## Further reading

- Tutorial `026` -- `CATCH` and `THROW`.
- Tutorial `004` -- number bases, `HEX`, `DECIMAL`, `BASE`.
- Tutorial `011` -- `AND`, `OR`, `XOR`, `INVERT` on bits.
- Tutorial `015` -- double numbers.
- `HELP ERROR`, `HELP MESSAGE`, `HELP WARNING`, `HELP WHERE`,
  `HELP CATCH`, `HELP THROW`, `HELP ?TERMINAL`, `HELP BASE`, `HELP U.`,
  `HELP D.`.
- `9 LOAD` -- every message, page by page.
- `doc/NextZXOS_and_esxDOS_APIs.md` -- the esxDOS error codes.
- [Chapter 1](01-basic-programming-concepts.md) -- errors, `CATCH`,
  `THROW`, `QUIT`, `ABORT`.
- [Chapter 6](06-expressions.md) -- integers, signs, `$` and `%`.

<!-- nav -->
---

Previous: [Appendix A - Character Set, Z80N Mnemonics and Control Codes](app-a-character-set-z80n-control-codes.md) |
[Contents](README.md) |
Next: [Appendix C - Machine Personalities](app-c-machine-personalities.md)
