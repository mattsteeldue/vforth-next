# Chapter 19 - NextZXOS and alternatives

[From NextBASIC to vForth](README.md)

Manual: Chapter 19, pp. 157-205.

## In short

vForth runs on top of NextZXOS and uses the same SD card, the same drives,
folders and file names: what the manual says about them still holds.
What changes is what a program is. A NextBASIC program is a file that
`LOAD` brings in whole and `SAVE` writes back. A Forth program is a text
file of source, which `INCLUDE` compiles into the dictionary and which
vForth never saves, because it is already on the card. Bytes travel with
`LOAD-BYTES` and `SAVE-BYTES`, the `CODE` of `LOAD` and `SAVE`; the
catalogue and the folders with `DIR`, `CD`, `PWD`, `MAKEDIR`, `REMOVEDIR`
and `UNLINK`, each brought in by `NEEDS`. The rest of the chapter (the
Browser, the NMI menu, partitions and mounting, `SPECTRUM`, CP/M, esxDOS)
is the machine around the language, and stays NextBASIC's business.
vForth adds one thing BASIC lacks: a 16 MB block file, always open.

## What changes

**A program is a source file.** It is written with a text editor, on the
PC or on the Next (`NEEDS LED`, then `LED name`), and `INCLUDE` reads it
line by line, as if each line were typed at the prompt: definitions are
compiled, everything else is executed. `NEEDS word` does the same with
the file named after a word, looked for first in `inc/` and then in
`lib/`, and only if the word is not in the dictionary yet. That makes
`NEEDS` the usual way to build a program out of a library of routines,
the job `MERGE` does in BASIC, without loading anything twice.

**The name follows the word, without quotes.** `INCLUDE`, `CD`, `DIR`,
`MAKEDIR`, `REMOVEDIR`, `UNLINK` and `VIEW` read the name from the line,
up to the next space: `INCLUDE demo/game.f`, not `INCLUDE "demo/game.f"`.
A name with a space in it cannot be given this way. The words that take
the name from the stack find it in `PAD`, where `PAD"` puts it:
`PAD" game.dat"`, with a space after `PAD"` that is not part of the name.
Drive letters, `/`, `..` and the wildcards are NextZXOS's, so they work
as in BASIC.

**There is no `SAVE` for a program, and no `LINE`.** The source is
already a file, so there is nothing to save. A program that starts by
itself is one whose last line calls the main word: `INCLUDE` compiles
the definitions and, reaching that line, runs it. To ship a game that
starts from a BASIC loader without the prompt, `NEEDS ZAP` and `ZAP name`
freeze the running system into files (tutorial `059`).

**`LOAD-BYTES` and `SAVE-BYTES` are `CODE`.** The name goes in `PAD`,
the address and the length on the stack, and both numbers are always
given:

<!-- no-test -->
```forth
NEEDS PAD"  NEEDS LOAD-BYTES  NEEDS SAVE-BYTES
PAD" pic.scr" $4000 6912 SAVE-BYTES   \ SAVE "pic.scr" SCREEN$
PAD" pic.scr" $4000 6912 LOAD-BYTES   \ LOAD "pic.scr" SCREEN$
```

The length given to `LOAD-BYTES` is the most it reads: a shorter file
loads without an error. `SAVE-BYTES` refuses a file that already exists
(`SAVE-BYTES? NextZXOS Open error.`); `NEEDS SAVE-BYTES-FORCE` loads a
version that overwrites it, and no `.bak` copy is kept. Load below
`$E000`: the top 8K is the MMU7 window, where vForth keeps the names of
its words. A file written by BASIC's `SAVE ... CODE` begins with a
128-byte +3DOS header, which tells `LOAD` the type, the address and the
length. `LOAD-BYTES` and `SAVE-BYTES` know nothing of it: they read and
write the bytes alone.

**A bank is reached through MMU7.** `LOAD f BANK n` fills a 16K bank;
vForth sees memory in 8K pages, and bank n is pages 2n and 2n+1. A page
is mapped at `$E000` with `MMU7!`, loaded, and the page that was there
put back:

<!-- no-test -->
```forth
NEEDS PAD"  NEEDS LOAD-BYTES
: LOAD-PAGE  ( page -- )          \ the file name is in PAD
    MMU7@ >R  MMU7!  $E000 8192 LOAD-BYTES  R> MMU7! ;
PAD" half.bin" 40 LOAD-PAGE       \ first half of bank 20
```

Putting the page back is not a detail: the names of the dictionary live
in that window, and the next word typed is looked up there. The second
half of a bank comes from the same file, read on with `F_OPEN` and
`F_READ` (tutorial `042`). Choose a bank nothing else uses: the heap of
vForth is in banks 16 to 19 ([Chapter 23](23-the-memory.md)).

**`CD` and `NEEDS` do not mix.** `NEEDS`, and `INCLUDE lib/...`, look for
their files from the current folder, which at start is vForth's own.
After `CD` somewhere else they find nothing, until `CD` brings you back.
Load what you need first, then move.

**Same names, other meanings.** Forth had these words before NextBASIC
had its commands, and they do something else:

| Word | In NextBASIC | In vForth |
|---|---|---|
| `LOAD` | loads a file | `n LOAD` interprets Screen n of the block file |
| `SAVE` | saves a file | `NEEDS SAVE`: writes the changed Screens to disk |
| `LIST` | lists the program | `n LIST` shows Screen n |
| `ERASE` | deletes a file, or lines | `( a n -- )` zeroes n bytes of memory |
| `MOVE` | moves or renames a file | `( a1 a2 n -- )` copies memory, `NEEDS MOVE` |
| `RENAME` | -- | renames a word of the dictionary |

BASIC's `ERASE m,n` deletes program lines. The Forth way is `FORGET`,
which deletes a word and every word defined after it:

```forth
: MAIN  ." main" ;
FORGET MAIN
MAIN                            \ => MAIN? is undefined.
```

**A disk that is always open.** Besides files, vForth keeps the block
file `!Blocks-64.bin` open from start to end: 16 MB in records of 512
bytes, with no names and no `OPEN`. `n BLOCK` gives the address of block
n in memory, reading it from the card if needed; after a change, `UPDATE`
marks it and `FLUSH` writes it back. Two blocks make a Screen of 16 lines
of 64 characters, which `LIST` shows and `LOAD` interprets. The error
messages of vForth live there too:

```forth
8 BLOCK 13 TYPE                 \ => is undefined.
```

Block 8 begins Screen 4, whose first line is message 0, the one printed
after a word that is not found. `SCREEN-TO-FILE` and `SCREEN-FROM-FILE`
copy a Screen to a text file and back (tutorial `063`).

**Two editors on the machine.** `EDIT` is the editor of the block file:
`NEEDS EDIT`, then `n LIST EDIT` opens Screen n full screen. The cursor
moves with SHIFT and 5 to 8; EDIT followed by a letter gives a command:
`N` and `B` go to the next and the previous Screen, `H` keeps the current
line in `PAD` and `R` puts it back elsewhere, `D` deletes a line, `U`
reads the Screen again from the card, undoing the changes, and `Q`
leaves. Every change marks its block with `UPDATE`, so `FLUSH`, or `BYE`,
writes it back. `LED`, the Large file EDitor, does the same for a text
file: `NEEDS LED`, then `LED name` loads the whole file into free 8K
pages, lines of up to 85 characters, and EDIT followed by `W` writes it
back. `LED` is derived for the most part from `EDIT`, and the commands
are the same; but its features are still experimental, so keep a copy
of a file that matters before editing it with `LED`, and leave with
`FORGET-LED` rather than `FORGET LED`, which would not give the pages
back.

**Leaving vForth.** `BYE` writes back the changed blocks, closes the file
and returns to BASIC; there, `RUN` starts vForth again. `n BASIC` returns
at once, with n as the result of the `USR` that started vForth. Dot
commands cannot be launched from inside vForth, though vForth can itself
be one: `.vforth`.

## Correspondence table

| NextBASIC | vForth | Note |
|---|---|---|
| `LOAD f` (a program) | `INCLUDE file` | The source is compiled. |
| `MERGE f` | `NEEDS word`, `INCLUDE file` | `NEEDS` loads once. |
| `SAVE f` (a program) | -- | The source is already a file. |
| `SAVE f LINE n` | the last line calls the main word | `ZAP` for a standalone program. |
| `LOAD f CODE a,n` | `PAD" f" a n LOAD-BYTES` | `NEEDS PAD"`, `NEEDS LOAD-BYTES`. |
| `SAVE f CODE a,n` | `PAD" f" a n SAVE-BYTES` | Error if the file exists. |
| `.bak` copy | -- | `SAVE-BYTES-FORCE` overwrites. |
| `LOAD`/`SAVE f SCREEN$` | `$4000 6912` with the two above | 6144 for the pixels alone. |
| `LOAD`/`SAVE f LAYER` | `MMU7!` and the two above, page by page | Layer 2 is six 8K pages. |
| `LOAD`/`SAVE f BANK n` | pages `2n` and `2n+1` through `MMU7!` | Put the page back. |
| `LOAD`/`SAVE f DATA a()` | the address and size of the table | Reserve it first with `ALLOT`. |
| `LOAD`/`SAVE f INT`, `INPUT` | -- | Save the memory you need. |
| `VERIFY f` | -- | Tape only. |
| `CAT`, `DIR`, `LS` | `DIR path` | `NEEDS DIR`. Sorted, with size and date. |
| `CAT EXP` | `DIR`; `F_STAT` for the attributes | |
| wildcards | `WILDCARD *.F` before `DIR` | Stays in force for later `DIR`s. |
| `MKDIR`, `RMDIR` | `MAKEDIR path`, `REMOVEDIR path` | `NEEDS` each. |
| `CD`, `PWD` | `CD path`, `PWD` | `NEEDS` before `CD`. |
| `PWD` into a string | `buf F_GETCWD` | Zero-terminated: [Chapter 7](07-strings.md). |
| `COPY f1 TO f2` | -- | A loop of `F_READ` and `F_WRITE`. |
| `COPY f TO SCREEN$` | `VIEW file` | `NEEDS VIEW`. |
| `ERASE f` | `UNLINK file` | No wildcards, no question asked. |
| `MOVE f1 TO f2` | `src dest F_RENAME` | Names zero-terminated: `," name"` then `1+`, [Chapter 7](07-strings.md). |
| `MOVE f TO "+p"` | `F_CHMOD` | |
| `REMOUNT` | `REMOUNT` | Closes the block file too. |
| default drive | the drive letter in the path | `M_GETSETDRV` for the default. |
| `SPECTRUM INK`, `PAPER` | `.INK`, `.PAPER`, `.PERM` in Screen 11 | Set at each start. |
| `SPECTRUM CHR$ n` | `NARROWCHAR`, `WIDECHAR` | [Chapter 14](14-more-about-print-and-input.md). |
| `RUN AT s` | `s SPEED!` | `NEEDS SPEED!`. |
| `ERASE m,n` (lines) | `FORGET word` | |
| `LIST PROC p()` | `SEE word` | `NEEDS SEE`. |
| `autoexec.bas` | Screen 11, `lib/autoexec.f` | |
| `.mem`, `.nextver` | `UNUSED`, `DOSVER` | Dictionary space, not RAM. |
| (not in BASIC) | `n BLOCK`, `UPDATE`, `FLUSH` | The block file. |
| the program editor, EDIT | `n LIST EDIT`, `LED file` | `NEEDS EDIT`, `NEEDS LED`; `LED` is experimental. |
| leaving | `BYE`, `n BASIC` | `RUN` comes back. |

## Side by side

**A table in a file.** Ten squares saved, the table cleared, and the
file loaded back.

```
10 DIM a(10)
20 FOR i=1 TO 10: LET a(i)=i*i: NEXT i
30 SAVE "squares.dat" DATA a()
40 DIM a(10)
50 LOAD "squares.dat" DATA a()
60 PRINT a(5)
```

<!-- no-test -->
```forth
NEEDS PAD"  NEEDS SAVE-BYTES  NEEDS LOAD-BYTES
CREATE SQUARES  10 CELLS ALLOT
: SQUARES!  ( -- )
    10 0 DO  I 1+ DUP *  SQUARES I CELLS + !  LOOP ;
SQUARES!
PAD" squares.dat" SQUARES 10 CELLS SAVE-BYTES
SQUARES 10 CELLS ERASE
PAD" squares.dat" SQUARES 10 CELLS LOAD-BYTES
SQUARES 4 CELLS + @ .           \ => 25
```

`DIM` makes and clears the table in one go; in Forth it is reserved once
with `ALLOT`, and `ERASE` clears it. The file holds twenty bytes, ten
cells, with no type and no name of a table: `LOAD-BYTES` puts them
wherever it is told. Run it a second time and `SAVE-BYTES` stops,
because the file is there.

**A program that starts by itself.** Saved with `SAVE "hello" LINE 10`,
this runs as soon as it is loaded:

```
10 PRINT "Hello"
```

The file `hello.f`, written with an editor:

```forth
: HELLO  ( -- )  ." Hello" CR ;
HELLO
```

`INCLUDE hello.f` compiles `HELLO` and then, on the last line, runs it.
Leave that line out and the file is a library: `INCLUDE` defines the word
and the program calls it when it wants.

**A folder for a game.**

```
10 MKDIR "games"
20 CD "games"
30 SAVE "maze.dat" CODE 32768,1024
40 CD ".."
50 CAT "games"
```

<!-- no-test -->
```forth
NEEDS MAKEDIR  NEEDS CD  NEEDS DIR
NEEDS PAD"  NEEDS SAVE-BYTES
MAKEDIR games
CD games
PAD" maze.dat" 32768 1024 SAVE-BYTES
CD ..
DIR games
```

Every `NEEDS` comes first, while vForth is still in its own folder. The
rest reads as the BASIC does, without quotes. Without `CD` at all,
`PAD" games/maze.dat"` would do the same.

## No equivalent

- **Tapes and disk images**: `LOAD ""`, `LOAD "*"`, `LOAD "d*"`,
  `VERIFY`, `.mkdata`, `.mkswap`.
- **`LOAD`/`SAVE ... INT` and `INPUT`.** There is no fixed set of integer
  variables, nor a keyboard joystick; save the memory that holds them.
- **`COPY` from file to file.** It is a few lines (two files open, a loop
  of `F_READ` and `F_WRITE` on a buffer), but no word is ready; with
  wildcards it becomes a library.
- **`CAT -`, `CAT TAB`, `CAT ASN`, `MOVE ... IN`, `MOVE ... OUT`.**
  Partitions and mounting are set up from BASIC before vForth starts.
- **Printing** (`LLIST`, `LPRINT`, `COPY ... TO LPRINT`): see Chapter 20.
- **`SPECTRUM`**, the 48K mode, snapshots and the screen saver.
- **Line numbers**: `LINE` renumbering and `LINE MERGE`.
- **Dot commands**, `.browse` among them; the Browser, the NMI menu, the
  command line, cartridges, CP/M and esxDOS. They belong to the machine,
  not to the language.

## Further reading

- Tutorial `042` -- file input and output: `PAD"`, `LOAD-BYTES`,
  `SAVE-BYTES`, `F_OPEN`, `F_READ`.
- Tutorial `043` -- folders: `CD`, `PWD`, `DIR`.
- Tutorial `028` -- the block file: `BLOCK`, `LIST`, `LOAD`, `FLUSH`.
- Tutorial `029` -- `EDIT`, the editor of the block file.
- Tutorial `063` -- blocks as a store of data.
- Tutorial `041` -- pages and `MMU7!`.
- Tutorial `059` -- `ZAP`, a program that starts by itself.
- `HELP INCLUDE`, `HELP NEEDS`, `HELP LOAD-BYTES`, `HELP SAVE-BYTES`,
  `HELP DIR`, `HELP CD`, `HELP UNLINK`, `HELP BLOCK`, `HELP FORGET`,
  `HELP EDIT`.
- [Chapter 23](23-the-memory.md) -- the memory, banks and pages.

<!-- nav -->
---

Previous: [Chapter 18 - Sound and Music](18-sound-and-music.md) |
[Contents](README.md) |
Next: [Chapter 20 - Channels, Streams, Drivers and Windows](20-channels-streams-drivers-and-windows.md)
