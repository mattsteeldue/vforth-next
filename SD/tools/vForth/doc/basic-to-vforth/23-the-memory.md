# Chapter 23 - The Memory

[From NextBASIC to vForth](README.md)

Manual: Chapter 23, pp. 247-275.

## In short

`PEEK`, `POKE`, `DPEEK` and `DPOKE` carry over as four words: `C@`, `C!`,
`@` and `!`. In Forth they are the normal way of working with memory,
not a last resort, because nothing in vForth moves. The banks are a
different matter. BASIC counts them in 16K and reaches them by number
with `BANK n PEEK`, `BANK n POKE` and so on. vForth reaches the rest of
the memory through one 8K window at `$E000`, a page at a time, with
`MMU7!`. You ask NextZXOS for the pages yourself, and every `BANK`
command becomes a few lines: map a page, use it, put the old one back.
`CLEAR` and RAMTOP have no part in this: the memory map of vForth is
fixed.

## What changes

**The value comes first.** As with `OUT` ([Chapter 22](22-in-out-and-the-next-registers.md)),
the address is on top of the stack and is written last:

| NextBASIC | vForth |
|---|---|
| `POKE a,v` | `v a C!` |
| `PEEK a` | `a C@` |
| `DPOKE a,v` | `v a !` |
| `DPEEK a` | `a @` |

`!` and `@` keep the low byte first, as `DPOKE` and `DPEEK` do. `C!`
checks nothing: it stores the low byte of whatever number it is given.

```forth
CREATE BUF 16 ALLOT
300 BUF C!  BUF C@ .            \ => 44
```

**Where vForth lives.** vForth is loaded by BASIC above RAMTOP, as a
machine code program would be, and does not move from there:

| Addresses | Contents |
|---|---|
| `$0000`-`$3FFF` | ROM |
| `$4000`-`$5AFF` | screen and attributes (Layer 0) |
| `$5B00`-`$61FF` | system variables, BASIC, up to RAMTOP |
| `$6200`-`$6365` | interrupt table and vForth's own stacks for the OS |
| `$6366` up to `HERE` | the dictionary: your words and data |
| below `S0 @` | the data stack, growing down towards `HERE` |
| `S0 @` to `$DFFF` | input line, return stack, user variables, block buffers |
| `$E000`-`$FFFF` | the MMU7 window: the names of the words, or a page of yours |

```forth
S0 @ U.  FIRST @ U.             \ => 53492 53732
```

**No `CLEAR`.** BASIC's `CLEAR n` moves RAMTOP to make room below it,
and wipes the variables. vForth has neither to do: memory for your data
comes from the dictionary, where `ALLOT` takes it and `UNUSED` says how
much is left.

```forth
NEEDS UNUSED
UNUSED  CREATE TABLE 1000 ALLOT  UNUSED  - .     \ => 1007
```

The 7 bytes beyond the thousand are the word `TABLE` itself: its name
is kept apart, in the pages of the names (below). `FORGET` and
`MARKER` give the space back
([Chapter 1](01-basic-programming-concepts.md)).

**Absolute addresses are safe.** The manual advises the `BANK` forms over
`PEEK` and `POKE` with addresses, because a BASIC program and its
variables move while it runs. The dictionary does not: `BUF` and
`TABLE` stay where `CREATE` put them, so `C@` and `C!` on them are the
ordinary way to work.

**A list after `POKE` is a table.** `POKE a,1,2,3` writes three bytes at
once. In Forth the bytes are compiled into a table with `C,` (`,` for
16-bit words), then copied with `CMOVE` ( from to count -- ):

```forth
CREATE BYTES  1 C, 2 C, 3 C,
BYTES BUF 3 CMOVE  BUF 2 + C@ . \ => 3
```

**`PEEK$` is already done.** An address and a length are a string in
Forth ([Chapter 7](07-strings.md)): `a n TYPE` prints it, with no copy.
A string closed by a zero byte, as NextZXOS writes them
([Chapter 7](07-strings.md)), needs its length counted first:

```forth
: ZLEN  ( a -- n )  DUP BEGIN DUP C@ WHILE 1+ REPEAT SWAP - ;
CREATE ZS  72 C, 105 C, 0 C,
ZS DUP ZLEN TYPE                \ => Hi
```

**Looking at memory.** The loop of `PEEK`s that prints a range of bytes
is a word, and `DUMP` shows the same range in hex with the characters:

```forth
: PEEKS  ( a n -- )  BOUNDS DO  I C@ .  LOOP ;
BYTES 3 PEEKS                   \ => 1 2 3
NEEDS DUMP
BYTES 8 DUMP
```

**Banks of 16K, pages of 8K.** BASIC numbers its memory in 16K banks;
the MMU of the Next, and vForth with it, in 8K pages. Bank *n* is pages
*2n* and *2n+1*, and an offset beyond 8191 in a bank falls into the
second page:

```forth
: BANK>PAGE  ( bank off -- page off' )  8192 /MOD  ROT 2* +  SWAP ;
20 10 BANK>PAGE . .             \ => 10 40
20 8202 BANK>PAGE . .           \ => 10 41
```

**One window, shared.** vForth sees other pages through the top 8K of
the address space, `$E000` to `$FFFF`. `n MMU7!` puts page *n* there,
`MMU7@` says which page is there now. The window normally holds the
names of the words, and vForth maps those pages itself whenever it needs
them: compiling a definition, for instance, leaves a page of names in
the window. So a page of yours must be mapped, used and taken away
inside one word, and the old page put back:

```forth
: PAGE-C!  ( b page off -- )
    $E000 +  SWAP  MMU7@ >R  MMU7!  C!  R> MMU7! ;
: PAGE-C@  ( page off -- b )
    $E000 +  SWAP  MMU7@ >R  MMU7!  C@  R> MMU7! ;
99 60 10 PAGE-C!  60 10 PAGE-C@ .   \ => 99
```

These are `BANK n POKE` and `BANK n PEEK`, with a page for a bank. A
16-bit `@` or `!` works the same way, except at offset 8191, where the
cell would straddle two pages.

**`BANK NEW` asks NextZXOS.** BASIC's `BANK NEW` reserves a bank so that
nobody else uses it. vForth has no word for it, but the call behind it,
`IDE_BANK`, is a few lines away through `M_P3DOS`, and it works in 8K
pages, the unit `MMU7!` wants:

<!-- no-test -->
```forth
: NEW-PAGE  ( -- page )
    1 0 0 0 $01BD M_P3DOS  40 ?ERROR  2DROP NIP 255 AND ;
: FREE-PAGE  ( page -- )
    3 SWAP 0 0 $01BD M_P3DOS  44 ?ERROR  2DROP 2DROP ;
```

`NEW-PAGE` is `BANK NEW` and stops with "NextZXOS Out of memory" when no
page is left; `FREE-PAGE` is `BANK n CLEAR`. A page taken this way is
yours until you free it, and the next run of the program may get a
different number, as with `BANK NEW`. Some pages are used whether you
reserve them or not: the names of the words in pages 32 to 39 (banks 16
to 19), the Layer 2 where Next register `$12` says, and a few that the
libraries take without asking (page 40 for `PAINT`, from 48 up for
`LED`). A program that only uses what `NEW-PAGE` gives it meets none of
them.

**A bank that BASIC filled.** `LOAD "f" BANK n` in BASIC, before vForth
starts, leaves the data in a known bank. `BANK>PAGE` gives the page
and offset to read it from vForth: `n off BANK>PAGE PAGE-C@`.

**Copying and filling.** `BANK m ERASE` and `BANK m COPY TO n` become
`FILL` and `CMOVE` on the window. Between two pages the data goes
through a buffer in the dictionary, since only one page is visible at a
time:

```forth
: PAGE-FILL  ( page c -- )
    SWAP  MMU7@ >R  MMU7!  $E000 8192 ROT FILL  R> MMU7! ;
CREATE XBUF 1024 ALLOT
: PAGE-COPY  ( from to -- )
    MMU7@ >R
    8192 0 DO
        OVER MMU7!  $E000 I +  XBUF  1024 CMOVE
        DUP  MMU7!  XBUF  $E000 I +  1024 CMOVE
    1024 +LOOP
    2DROP  R> MMU7! ;
```

For large blocks the DMA of the Next does the copy without the CPU:
`NEEDS DMA` and tutorial `054`.

**The other ways of paging are not for vForth.** The ports `7FFDh`,
`1FFDh` and `DFFDh`, the all-RAM modes and taking the ROM away are
NextZXOS's business, and vForth needs the ROM to print and to read the
keyboard. Only MMU7 belongs to your program; `MMU0!` and `MMU1!`
(`NEEDS MMU0!`, `NEEDS MMU1!`) exist for the brave, and tutorial `041`
shows them.

## Correspondence table

| NextBASIC | vForth | Note |
|---|---|---|
| `POKE a,v` | `v a C!` | Value first. |
| `PEEK a` | `a C@` | |
| `DPOKE a,v` | `v a !` | Low byte first, as in BASIC. |
| `DPEEK a` | `a @` | |
| `POKE a,v1,v2,...` | a table with `C,`, then `CMOVE` | |
| `POKE a,"text"` | a table, then `CMOVE` | |
| `PEEK$ (a,n)` | `a n` | Already a string. |
| `PEEK$ (a,~0)` | `a DUP ZLEN` | `ZLEN` above. |
| a loop of `PEEK`s | `a n PEEKS`, `a n DUMP` | `NEEDS DUMP`. |
| `CLEAR` | -- | Nothing to wipe, no RAMTOP to move. |
| `CLEAR n`, making room | `CREATE name n ALLOT` | `UNUSED` says how much is left. |
| `BANK NEW v` | `NEW-PAGE` | Defined above; 8K, not 16K. |
| `BANK n CLEAR` | `page FREE-PAGE` | |
| `BANK n POKE o,v` | `v page o PAGE-C!` | `BANK>PAGE` for a 16K bank. |
| `BANK n PEEK o` | `page o PAGE-C@` | |
| `BANK n DPOKE`, `DPEEK` | `MMU7!`, then `!` or `@` at `$E000+o` | Not across offset 8191. |
| `BANK n PEEK$ (o,l)` | map, copy below `$E000`, put back | |
| `BANK n ERASE v` | `page v PAGE-FILL` | |
| `BANK m COPY TO n` | `p1 p2 PAGE-COPY`; `NEEDS DMA` | Through a buffer. |
| `BANK n LAYER ...` | -- | A loop of `CMOVE` for Layer 2. |
| `LAYER BANK n,m` | `n $12 REG!  m $13 REG!` | [Chapter 17](17-time-and-motion.md). |
| `BANK n GO TO`, `LIST`, `MERGE`... | -- | Programs in banks: no counterpart. |
| `BANK 1346 USR`, `FORMAT` | -- | The RAM disk. |
| MMU registers `$50`-`$57` | `MMU7!`, `MMU7@` | Only MMU7 is yours. |
| ports `7FFDh`, `1FFDh`, `DFFDh` | -- | Leave them alone. |

## Side by side

**A byte in a bank.** Reserve memory, store two bytes, read them back,
give the memory back.

```
10 BANK NEW b
20 BANK b POKE 10,99
30 BANK b POKE 20,77
40 LET x=BANK b PEEK 10: LET y=BANK b PEEK 20
50 PRINT x,y
60 BANK b CLEAR
```

<!-- no-test -->
```forth
: TRY-PAGE  ( -- )
    NEW-PAGE
    99 OVER 10 PAGE-C!
    77 OVER 20 PAGE-C!
    DUP 10 PAGE-C@ .  DUP 20 PAGE-C@ .  CR
    FREE-PAGE ;
TRY-PAGE
```

The page number stays on the stack for the whole word, where BASIC keeps
it in `b`; `OVER` and `DUP` copy it for each access.

**Fill and copy.** One bank filled with the letter A, copied into a
second one.

```
10 BANK NEW a: BANK NEW b
20 BANK a ERASE 65
30 BANK a COPY TO b
40 LET c=BANK b PEEK 100: PRINT CHR$ c
50 BANK a CLEAR: BANK b CLEAR
```

```forth
60 65 PAGE-FILL  60 62 PAGE-COPY
62 100 PAGE-C@ EMIT             \ => A
```

Here pages 60 and 62 stand for what `NEW-PAGE` would return; with
`NEW-PAGE` the word looks like `TRY-PAGE`. `PAGE-COPY` copies 8K, half
of what `BANK COPY` copies: a 16K bank is two calls.

**A look at the system variables.** Eight bytes from the start of the
system variables, then the same with `DUMP`.

```
10 FOR a=23552 TO 23559
20   PRINT PEEK a;" ";
30 NEXT a
```

```forth
23552 8 PEEKS
23552 8 DUMP
```

## No equivalent

- **`CLEAR` and RAMTOP.** The memory map of vForth is fixed; space comes
  from `ALLOT`.
- **Programs and `DATA` in banks.** `BANK n GO TO`, `LIST`, `MERGE`,
  `RESTORE` and the rest work on BASIC lines kept in a bank. vForth's
  code lives in the dictionary, its names in the pages of the window.
- **`BANK n LAYER`.** Copying a rectangle between a layer and a bank is
  a loop of `CMOVE`, a row at a time, written for the layer in use.
- **The RAM disk.** `BANK 1346 USR` and `FORMAT` belong to NextZXOS.
- **Paging through the old ports**, the all-RAM modes and removing the
  ROM: vForth uses only MMU7.

## Further reading

- Tutorial `041` -- the MMU, `MMU7!`, `MMU7@`, the Layer 2 pages.
- Tutorial `008` -- `C@`, `C!`, `@`, `!`, `CREATE`, `ALLOT`.
- Tutorial `025` -- the dictionary and its memory.
- Tutorial `054` -- the DMA: `DMA-COPY`, `DMA-FILL`.
- `HELP MMU7!`, `HELP CMOVE`, `HELP FILL`, `HELP DUMP`, `HELP UNUSED`.
- The vForth manual, "Dictionary memory structure": how the dictionary
  and the names are laid out.

<!-- nav -->
---

Previous: [Chapter 22 - IN, OUT and the Next Registers](22-in-out-and-the-next-registers.md) |
[Contents](README.md) |
Next: [Chapter 24 - The System Variables](24-the-system-variables.md)
