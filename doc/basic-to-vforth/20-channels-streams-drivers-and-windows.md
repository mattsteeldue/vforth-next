# Chapter 20 - Channels, Streams, Drivers and Windows

[From NextBASIC to vForth](README.md)

Manual: Chapter 20, pp. 206-217.

## In short

NextBASIC joins every device to a stream number, and the same `PRINT #`,
`INPUT #` and pointer commands work on all of them. vForth splits the
idea in two. Character output goes to one current stream, chosen with
`n SELECT`: the screen, the printer, or a stream BASIC opened before
vForth started. Files are read and written through a handle, a number
NextZXOS gives back when the file is opened, with the `F_` words:
`F_OPEN`, `F_READ`, `F_WRITE`, `F_SEEK`, `F_FGETPOS`, `F_CLOSE`, all
in the core; a line of text is read a byte at a time. The variable and
memory channels are not needed, drivers are BASIC's business, and user
windows have no counterpart.

## What changes

**There is no `OPEN #`.** A file is not attached to a stream from 0 to
15: `F_OPEN` returns a handle, and the program keeps it, usually in a
`VALUE`. From the prompt `OPEN< name` does it for reading:

```forth
NEEDS VALUE  NEEDS TO
0 VALUE FH
OPEN< help/rnd.txt TO FH
FH F_CLOSE .                    \ => 0
FH F_CLOSE .                    \ => -1
```

`OPEN<` reads the name from the line, without quotes, and stops with
`File not found.` if the file is not there. Every `F_` word leaves a
flag on top, 0 when all went well and -1 when NextZXOS refused: closing
twice is an error, but nothing stops the program. Check the flag, or
drop it knowingly.

**Inside a definition, `F_OPEN`.** `OPEN<` works from the prompt only.
A definition puts the name in `PAD` with `PAD"`, closed by a zero as
NextZXOS wants it ([Chapter 7](07-strings.md)), and calls `F_OPEN` with
a mode, the number that stands for `i>`, `o>` or `u>`:

```forth
NEEDS PAD"
: OPEN-FILE  ( mode -- fh )       \ the name is in PAD
    >R PAD HERE R> F_OPEN 41 ?ERROR ;
PAD" help/rnd.txt" 1 OPEN-FILE TO FH
FH F_CLOSE .                    \ => 0
```

| BASIC | Mode | Meaning |
|---|---|---|
| `"i>f"` | `1` | read an existing file |
| `"o>f"` | `%1110` | write a new file, emptying it if it exists |
| -- | `%0110` | write a new file, error if it exists |
| `"u>f"` | `%0011` | read and write an existing file |

`HERE` is the address of an 8-byte buffer that `F_OPEN` uses only with
+3DOS headers; any free memory will do. `NEEDS OPEN>` gives the
`%1110` mode from the prompt: `OPEN> name`.

**Bytes, not printing.** `F_READ ( a n fh -- n2 f )` reads up to `n`
bytes and `F_WRITE ( a n fh -- n2 f )` writes `n`; `n2` says how many
moved. Nothing is converted: a number becomes text first, with
`<# #S #>`, and the end of a line is a byte the program writes. A file
ends without an error: `F_READ` reads fewer bytes than asked, or none,
where BASIC stops with `8 End of file`. One byte at a time, it is
`NEXT #`:

```forth
CREATE CH  0 C,
: GET-CHAR  ( -- c )                \ next byte of FH, -1 at the end
    CH 1 FH F_READ 46 ?ERROR
    IF  CH C@  ELSE  -1  THEN ;
OPEN< help/rnd.txt TO FH
GET-CHAR . GET-CHAR . GET-CHAR .    \ => 32 32 32
GET-CHAR . GET-CHAR EMIT            \ => 32 R
```

**A line is built from bytes.** `INPUT #n; LINE` has no ready-made
counterpart: the core has `F_GETLINE`, but it is the part of `INCLUDE`
that reads sources, and it needs a buffer prepared the way `INCLUDE`
prepares it, or it writes outside it. `GET-LINE` reads up to the end of
the line, a carriage return (13, as BASIC writes it), a line feed (10,
as PC editors do) or both. It leaves the length, without the end, and a
flag that is false only at the end of the file:

```forth
VARIABLE LASTC                      \ the byte read before
: NEXT-CHAR  ( -- c )               \ GET-CHAR, a LF after a CR skipped
    GET-CHAR  DUP 10 =  LASTC @ 13 = AND
    IF  DROP GET-CHAR  THEN  DUP LASTC ! ;
: EOL?  ( c -- f )   DUP 13 =  OVER 10 = OR  SWAP 0< OR ;
: GET-LINE  ( a max -- n f )        \ the next line of FH into a
    >R 0
    BEGIN  NEXT-CHAR  DUP EOL? 0=
    WHILE  OVER R@ <
        IF  >R 2DUP + R> SWAP C!  1+  ELSE  DROP  THEN
    REPEAT
    R> DROP  0< 0=  OVER 0= 0= OR  ROT DROP ;
CREATE LINEBUF 80 ALLOT
LINEBUF 80 GET-LINE . .         \ => -1 11
LINEBUF 11 TYPE                 \ => ND  u -- u2
LINEBUF 80 GET-LINE . .         \ => -1 0
```

The first line had lost its first five characters to `GET-CHAR`. A
line longer than `max` is cut, and the rest is skipped. The last line
of the file comes with a true flag even without its end; the call after
it gives 0 and false. A loop that prints a whole file needs no count:

```forth
: TYPE-LINES  ( -- )                \ print every line of FH
    BEGIN  LINEBUF 80 GET-LINE
    WHILE  LINEBUF SWAP TYPE CR
    REPEAT  DROP ;
FH F_CLOSE DROP
OPEN< help/rnd.txt TO FH
TYPE-LINES
```

```text
    RND  u -- u2

Returns a pseudo-random number between
0 and u-1. Same formula and same SEED
system variable (23670) as BASIC RND.
See RANDOMIZE to set the seed.

Available after NEEDS RND
```

```forth
FH F_CLOSE .                    \ => 0
```

Reading a byte at a time costs one call to NextZXOS per byte: fine for
text, slow for a large file, which is better read in big pieces with
`F_READ` or whole with `LOAD-BYTES` (Chapter 19).

**`SELECT` moves all the output.** `3 SELECT` sends to the printer
everything printed after it, by `.`, `."`, `TYPE`, `EMIT` and every word
built on them, until `VIDEO` brings it back to the screen. A stream
from 4 to 15 can be selected too, if BASIC opened it before vForth
started (see the last example). Two things to remember:

- vForth selects the screen again whenever it waits for a line at the
  prompt, but it prints its `ok` before that. End the line with
  `VIDEO`, or put the whole job in a definition that ends with it.
- An error leaves the stream selected until the next prompt, and leaves
  files open: `ERROR` and `ABORT` close nothing. A file written and
  never closed may lose its last bytes, as in BASIC.

**Windows.** vForth prints through the ROM, in the system window of the
current layer, so the control codes of the "SW" column of the manual's
table work with `EMITC`: 14 clears, 26 sets the auto-pause, 28, 29 and
30 the double width, the height and the size of the characters. Codes
26, 29 and 30 are in [Chapter 14](14-more-about-print-and-input.md),
the colours in [Chapter 15](15-colours.md). User windows are not
available.

## Correspondence table

| NextBASIC | vForth | Note |
|---|---|---|
| streams 0 and 1 (`"k"`) | `KEY`, `ACCEPT` | Input is always the keyboard. |
| stream 2 (`"s"`) | `VIDEO` | Same as `2 SELECT`. |
| stream 3 (`"p"`) | `3 SELECT` ... `VIDEO` | |
| `PRINT #n;...` | `n SELECT` ... `VIDEO` | For every word that prints. |
| `LPRINT` | `3 SELECT` ... `VIDEO` | |
| `LLIST` | `3 SELECT n LIST VIDEO` | One Screen. |
| `COPY f TO #n` | `n SELECT VIEW file VIDEO` | `NEEDS VIEW`. |
| `CAT #n`, `PWD #n` | `n SELECT DIR VIDEO` | |
| `OPEN #n,"i>f"` | `OPEN< f`, or `1` with `F_OPEN` | Leaves a handle. |
| `OPEN #n,"o>f"` | `OPEN> f`, or `%1110` with `F_OPEN` | `NEEDS OPEN>`. |
| `OPEN #n,"u>f"` | `%0011` with `F_OPEN` | |
| `CLOSE #n` | `fh F_CLOSE` | Leaves a flag. |
| `PRINT #n` to a file | `a n fh F_WRITE` | Bytes; text made first. |
| `INPUT #n; LINE a$` | `a max GET-LINE` | Defined above, on `F_READ`. |
| `NEXT #n TO v` | `GET-CHAR` | Defined above, on `F_READ`. |
| `NEXT #0` | `KEY` | |
| `RETURN #n TO v`, `POINT #n` | `fh F_FGETPOS ( -- d f )` | A double: no limit. |
| `GO TO #n,p` | `d fh F_SEEK` | From the start of the file. |
| `DIM #n TO v` | `buf fh F_FSTAT`, size at `buf 7 +` | `NEEDS F_FSTAT`. |
| `8 End of file` | `F_READ` reads fewer bytes | No error. |
| `ON ERROR` | the flag, `n ?ERROR`, `CATCH` | `NEEDS CATCH`. |
| `"v>a$"` | `<# ... #>`, a buffer | The output is a string already. |
| `"m>a,n"` | `CMOVE` to the memory | |
| `.install`, `.uninstall` | -- | Run them in BASIC first. |
| `DRIVER` | -- | `M_DRVAPI` from code. |
| `"d>"` (serial) | `NEEDS UART-SYS` | The UART directly. |
| `"w>..."` | -- | System window codes only. |

## Side by side

**Writing and reading a file.** Three lines written, the file closed,
and read back.

```
10 OPEN #4,"o>notes.txt"
20 FOR i=1 TO 3
30 PRINT #4;"Line ";i
40 NEXT i
50 CLOSE #4
60 OPEN #4,"notes.txt"
70 FOR i=1 TO 3
80 INPUT #4; LINE a$: PRINT a$
90 NEXT i
100 CLOSE #4
```

<!-- no-test -->
```forth
NEEDS OPEN>  NEEDS S"
: PUT  ( a n -- )   FH F_WRITE 47 ?ERROR DROP ;
: NOTES  ( -- )
    4 1 DO
        S" Line " PUT
        I 0 <# #S #> PUT  13 CH C!  CH 1 PUT
    LOOP ;
OPEN> notes.txt TO FH  NOTES  FH F_CLOSE .
OPEN< notes.txt TO FH  TYPE-LINES  FH F_CLOSE .
```

```text
Line 1
Line 2
Line 3
0
```

`PRINT #` turns the number into text and ends the line by itself; in
Forth both are the program's job. The line ends with 13, as BASIC
writes it, so lines 60-100 of the BASIC listing read the Forth file
too. `TYPE-LINES`, from above, stops at the end of the file; BASIC
counts the lines, or compares the position with the size, because
reading past the end is an error. `OPEN>` empties a file that is
already there, so the example runs again without errors, where
`SAVE-BYTES` would stop (Chapter 19).

**Going back to a place.** The position is noted, two lines are read,
and the file goes back to read again the line after the noted place.
The BASIC listing reads `notes.txt`, written by the previous one; the
Forth lines read the help file, whose lines end with 10.

```
10 OPEN #4,"notes.txt"
20 INPUT #4; LINE a$
30 RETURN #4 TO p
40 INPUT #4; LINE a$: INPUT #4; LINE a$
50 GO TO #4,p
60 INPUT #4; LINE a$: PRINT p;" ";a$
70 CLOSE #4
```

```forth
NEEDS 2VARIABLE
2VARIABLE SPOT
OPEN< help/rnd.txt TO FH
LINEBUF 80 GET-LINE 2DROP  LINEBUF 80 GET-LINE 2DROP
FH F_FGETPOS DROP SPOT 2!
SPOT 2@ D.                      \ => 18
LINEBUF 80 GET-LINE 2DROP  LINEBUF 80 GET-LINE 2DROP
SPOT 2@ FH F_SEEK .             \ => 0
LINEBUF 80 GET-LINE . .         \ => -1 38
LINEBUF 38 TYPE                 \ => Returns a pseudo-random number
FH F_CLOSE DROP
```

The position is a double number, so it goes in a `2VARIABLE` and is
printed with `D.`: a file can be longer than 65535 bytes. `F_SEEK`
always counts from the start of the file. The size, which BASIC gets
with `DIM #`, comes from `F_FSTAT`, which fills an 11-byte buffer; the
size is its last four bytes, low cell first:

<!-- no-test -->
```forth
NEEDS F_FSTAT
: FSIZE  ( fh -- d )
    LINEBUF SWAP F_FSTAT 44 ?ERROR
    LINEBUF 7 + @  LINEBUF 9 + @ ;
OPEN< help/rnd.txt TO FH
FH FSIZE D.                     \ => 191
FH F_CLOSE DROP
```

**Printing on the printer, or into a file.**

```
5 OPEN #3,"s"
10 LPRINT "Squares"
20 FOR i=1 TO 5: LPRINT i*i;" ";: NEXT i
30 LPRINT
40 CLOSE #3
```

`LPRINT` writes to stream 3, and on a Next with no printer attached the
program stops there. Line 5 sends stream 3 to the screen, so the
listing can be tried anyway; remove it, and line 40, when a printer is
there. `CLOSE #3` gives stream 3 back to the printer.

<!-- no-test -->
```forth
: SQUARES  ( -- )
    ." Squares" CR
    6 1 DO  I I * .  LOOP CR ;
3 SELECT SQUARES VIDEO
```

`SQUARES` prints on the screen; the printer is chosen from outside,
and the same word serves both. With no printer, `3 SELECT` stops as
`LPRINT` does: give `OPEN #3,"s"` in BASIC before `RUN`, as in line 5
above. Any stream BASIC has opened works the same way. In BASIC, before `RUN` starts vForth (or after `BYE`, and
`RUN` again), give the direct command `OPEN #13,"o>words.txt"`; then,
in vForth, `13 SELECT WORDS VIDEO`; and back in BASIC `CLOSE #13`. The
list of words is in `words.txt`. The wrapper program `Forth18.bas`
already holds the `OPEN #` and the `CLOSE #` in two comments.

## No equivalent

- **`OPEN #` and `CLOSE #` on streams 0 to 15.** vForth cannot attach a
  stream to a channel; files have handles instead, and the streams
  `SELECT` reaches are the ones BASIC opened.
- **`INPUT #n` and `NEXT #n` from a stream.** Input comes from the
  keyboard only; from a file it is `F_READ`.
- **The variable and memory channels.** BASIC needs them to catch the
  output of a command in a string. In Forth `<# ... #>` builds a string
  directly, and the NextZXOS calls leave their results on the stack
  (`F_GETCWD`, `IDE_RTC`).
- **Installing drivers and `DRIVER`.** Drivers are installed from BASIC
  before vForth starts; no word calls `M_DRVAPI`, which can be done from
  machine code ([Chapter 25](25-using-machine-code.md)). The serial port
  is reached directly, with `NEEDS UART-SYS` (tutorial `047`), not
  through the `d>` channel.
- **User windows**: position and size of their own, justification,
  saving and restoring the contents, `INPUT #` in a window, a character
  set per window. Only the system window and its control codes are
  there.

## Further reading

- Tutorial `042` -- file input and output: `PAD"`, `LOAD-BYTES`,
  `SAVE-BYTES`, `F_OPEN`, `F_READ`, the error numbers.
- Tutorial `070` -- streams: `SELECT`, `VIDEO`, a word that prints
  anywhere, a stream opened by BASIC.
- Tutorial `003` -- output words, and the current stream.
- Tutorial `031` -- screen control codes.
- Tutorial `047` -- the UART.
- `HELP SELECT`, `HELP VIDEO`, `HELP F_OPEN`,
  `HELP F_READ`, `HELP F_WRITE`, `HELP F_SEEK`, `HELP F_FGETPOS`,
  `HELP F_CLOSE`, `HELP OPEN<`.
- [Chapter 19](19-nextzxos-and-alternatives.md) -- whole files at once:
  `LOAD-BYTES` and `SAVE-BYTES`.

<!-- nav -->
---

Previous: [Chapter 19 - NextZXOS and alternatives](19-nextzxos-and-alternatives.md) |
[Contents](README.md) |
Next: [Chapter 21 - Optional Features](21-optional-features.md)
