# Chapter 14 - More about PRINT and INPUT

[From NextBASIC to vForth](README.md)

Manual: Chapter 14, pp. 81-94.

## In short

Everything that goes on the screen goes through the same ROM routine as
BASIC's `PRINT`, so the layers, the character sizes, `AT`, `TAB` and the
control codes behave exactly as the manual says: in vForth they are sent
as codes, or with small words that send them. What has no counterpart is
the shape of the two statements. There is no `PRINT` with a list of items
and separators, only words that print one thing each. And there is no
`INPUT` that prints a caption, reads a line and converts it in one go:
`ACCEPT` reads, `EVALUATE` converts. The lower part of the screen, the
`scroll?` question, `SCREEN$` and `INKEY$` are not there.

## What changes

**`PRINT` is a sequence of words.** Each word prints one item: `."` a
text, `.` a number, `EMIT` a character, `CR` a new line. The separators
become words too: `;` is nothing at all, `'` is `CR`, and `,` is the
control code 6, `6 EMITC`.

```forth
." Total: " 42 .                \ => Total: 42
```

`.` always prints a space after the number, so there is no need to put
one in the text that follows. To line numbers up in columns, `.R` prints
a number right-aligned in a field of given width (see "Side by side").

**`AT` and `TAB` are words.** `r c .AT` (`NEEDS .AT`) is `PRINT AT r,c;`
with the arguments in the same order, row then column. `n .TAB`
(`NEEDS .TAB`) is `PRINT TAB n;`. Both just send the control codes 22 and
23 with their arguments, so the rules are the ROM's: the rows and columns
of the current layer and character width, and `TAB` reduced modulo the
number of columns.

```forth
NEEDS .AT
NEEDS .TAB
: STAR  ( -- )  11 16 .AT  ." *" ;
: HEADING  ( -- )  CR ." Name" 12 .TAB ." Score" ;
```

`STAR` is `PRINT AT 11,16;"*"`. The emulator that checks this guide has
no screen to position on, so the two words are defined here but not run:
try them on the machine.

**An error in the arguments ends in BASIC.** `PRINT AT 22,31` in BASIC
stops with `5 Out of screen`. In vForth the same check is made by the
same ROM, and the report it raises leaves Forth altogether: you find
yourself at the BASIC prompt, and `RUN` brings vForth back. The same
happens with any control code given a wrong argument. Keep the arguments
in range: rows 0 to 21 and columns 0 to 31 on Layer 0.

**Character size, as in BASIC.** On the layers other than 0, codes 30 and
29 set the width and the height of the characters. `WIDECHAR`
(`NEEDS WIDECHAR`) and `NARROWCHAR` (`NEEDS NARROWCHAR`) send `30 8` and
`30 4`; for any other size send the codes yourself:

<!-- no-test -->
```forth
30 EMITC 6 EMITC                \ characters 6 pixels wide
29 EMITC 1 EMITC                \ double height
```

**No `scroll?`.** vForth never stops a listing to ask. After every
character it prints it sets the system variable SCR CT (23692), the one
that `POKE 23692,255` sets in BASIC, back to 255:

```forth
23692 C@ .                      \ => 255
```

So the `POKE` of the manual is already done, permanently, and changing
the variable has no effect. When a listing must stop, stop it yourself
(see `KEY` below). On the other layers code 26 still sets the scroll
prompt of the window: `26 EMITC 0 EMITC`.

**`INPUT` comes apart.** BASIC's `INPUT` prints a caption, reads a line
in the lower part of the screen and converts it to the type of the
variable. In vForth these are three separate steps, and you choose what
goes in each:

- the caption is an ordinary `."`, printed where the cursor is;
- `ACCEPT ( a n -- n2 )` reads at most `n` characters into the buffer at
  `a`, where the cursor is: there is no separate lower screen;
- the text is converted, if it must be a number, by `EVALUATE`.

**`ACCEPT` counts one more.** The number it leaves is the number of
characters typed *plus one*: typing `Simon` gives 6. The length of the
string is `ACCEPT 1-`. Tutorial `016` does the same.

<!-- no-test -->
```forth
CREATE BUF 80 ALLOT
: INPUT$  ( -- a u )  BUF 80 ACCEPT 1-  BUF SWAP ;
." Your name? " INPUT$ CR ." Hello, " TYPE
```

That is `INPUT "Your name? ";LINE n$: PRINT "Hello, ";n$`. Every string
read by `ACCEPT` is a `LINE` input: there are no quotes to type.

**`EVALUATE` reads numbers, and expressions too.** BASIC lets you answer
`a+2` to an `INPUT` that wants a number. `EVALUATE` (`NEEDS EVALUATE`)
does the same with Forth: it interprets the string as if you had typed
it at the prompt, so it accepts a number, a variable, or a whole phrase.

```forth
NEEDS EVALUATE
NEEDS S"
VARIABLE A  14 A !
: T1  S" 42" EVALUATE . ;
: T2  S" A @ 2 +" EVALUATE . ;
T1                              \ => 42
T2                              \ => 16
```

Put it together with `INPUT$` and you have BASIC's `INPUT` for numbers:

<!-- no-test -->
```forth
: INPUT#  ( -- n )  INPUT$ EVALUATE ;
." How many? " INPUT# 2 * .
```

The answer is Forth, so it is `A @ 2 +`, not `a+2`. A word that does not
exist stops the program with `is undefined`, as BASIC stops with
`Variable not found`.

**`INKEY$` becomes `KEY`, or a scan.** `KEY ( -- c )` waits for a key and
leaves its code: it is `PAUSE 0: LET k$=INKEY$`, the usual way BASIC
waits for a key. A read that does *not* wait is not in the core. `?TERMINAL`
tells only whether BREAK is pressed. `NEEDS KEYBOARD` gives `KEY-SCAN`,
which reads the keyboard matrix straight away and leaves the *index* of
the key held down, 0 to 39, or 255 when none is:

```forth
NEEDS KEYBOARD
KEY-SCAN .                      \ => 255
```

The index is not a character: `.KEY` prints the name of the key, and the
table at the top of `inc/KEYBOARD.f` gives the order. For a game it is
what you want anyway, since it also sees keys that `INKEY$` hides, like
the two shifts on their own.

**Joysticks are ports.** `INPUT 1` and `INPUT 2` read the joysticks.
In vForth read their ports with `P@`: 31 for the first Kempston joystick,
55 for the second. The bits are the same: 1 right, 2 left, 4 down, 8 up,
16 fire.

<!-- no-test -->
```forth
: FIRE?  ( -- flag )  31 P@ 16 AND 0= 0= ;
```

**Choosing your own keys.** `INPUT -n` stores a key in the "keyboard
joystick" of NextZXOS. vForth does not use it; `NEEDS KEYBOARD` lets you
capture a key and test it later:

<!-- no-test -->
```forth
NEEDS KEYBOARD
2VARIABLE RIGHT-KEY
: DEFINE-RIGHT  ( -- )
    ." Press a key for right" CR
    GET-KEY DUP .KEY  KEY#>RM RIGHT-KEY 2! ;
: RIGHT?  ( -- flag )  RIGHT-KEY 2@ KEY-PRESSED? ;
```

`GET-KEY` waits for a fresh key press and leaves its index; `KEY#>RM`
turns it into a port and a bit mask, which `KEY-PRESSED?` tests in a few
microseconds, every frame of a game.

## Correspondence table

| NextBASIC | vForth | Note |
|---|---|---|
| `PRINT "text"` | `." text"` | Inside a definition or at the prompt. |
| `PRINT n` | `n .` | A space follows the number. |
| `PRINT n` in a field | `n w .R` | Right-aligned in `w` columns. |
| `;` | -- | Words simply follow each other. |
| `'` | `CR` | |
| `,` | `6 EMITC` | |
| `PRINT AT r,c;` | `r c .AT` | `NEEDS .AT`. Row, then column. |
| `PRINT TAB n;` | `n .TAB` | `NEEDS .TAB`. |
| `CHR$ 22`, `CHR$ 23` | `22 EMITC`, `23 EMITC` + arguments | What `.AT` and `.TAB` do. |
| `CHR$ 30;CHR$ n` | `30 EMITC n EMITC` | `WIDECHAR` (8), `NARROWCHAR` (4). |
| `CHR$ 29;CHR$ n` | `29 EMITC n EMITC` | |
| `CHR$ 26;CHR$ n` | `26 EMITC n EMITC` | Not on Layer 0. |
| `CLS` | `CLS` | |
| `POKE 23692,n` | -- | vForth sets SCR CT to 255 after every character. |
| `scroll?` | -- | Never asked. |
| `INPUT "text";v` | `." text"` and then the read | |
| `INPUT LINE a$` | `buf n ACCEPT 1-` | `ACCEPT` counts one more. |
| `INPUT n` (a number) | `INPUT$ EVALUATE` | `NEEDS EVALUATE`. Defined above. |
| an expression typed to `INPUT` | the same: `EVALUATE` | The expression is Forth. |
| `INPUT AT r,c;...` | `r c .AT` then `ACCEPT` | No lower screen. |
| `PAUSE 0: k$=INKEY$` | `KEY` | Waits. |
| `INKEY$` without waiting | `KEY-SCAN` | `NEEDS KEYBOARD`. A key index, 255 for none. |
| BREAK pressed? | `?TERMINAL` | |
| `INPUT 1`, `INPUT 2` | `31 P@`, `55 P@` | Same bits. |
| `INPUT -n` | `GET-KEY KEY#>RM`, then `KEY-PRESSED?` | `NEEDS KEYBOARD`. |
| `SCREEN$ (r,c)` | -- | |
| `PRINT POINT x,y;` | -- | |

## Side by side

**A table.** Squares and cubes in three columns.

```
10 FOR n=1 TO 5
20   PRINT n;TAB 6;n*n;TAB 12;n*n*n
30 NEXT n
```

The literal translation uses `.TAB`:

```forth
: POWERS  ( -- )
    6 1 DO
        CR  I .  6 .TAB  I I * .  12 .TAB  I I * I * .
    LOOP ;
```

The Forth way to line up numbers is `.R`, which pads on the left, so that
units stand under units. It needs no screen position at all, and works
just as well on a printer or in a file:

```forth
: POWERS  ( -- )
    6 1 DO
        CR  I 3 .R  I I * 6 .R  I I * I * 6 .R
    LOOP ;
POWERS
```

```text
  1     1     1
  2     4     8
  3     9    27
  4    16    64
  5    25   125
```

**Asking for a number.** A caption, an answer, a result.

```
10 INPUT "How many? ";n
20 PRINT n;" doubled is ";n*2
```

<!-- no-test -->
```forth
: DOUBLE  ( -- )
    ." How many? " INPUT# CR
    DUP . ." doubled is " 2 * . ;
```

`INPUT#` is the word defined in "What changes". The caption is printed
where the cursor stands, and the answer is typed right after it.

**A typewriter.** Every key is printed until ENTER.

```
10 PAUSE 0: LET k$=INKEY$
20 IF k$=CHR$ 13 THEN STOP
30 PRINT k$;: GO TO 10
```

<!-- no-test -->
```forth
: TYPEWRITER  ( -- )
    BEGIN  KEY DUP 13 <>  WHILE  EMIT  REPEAT  DROP ;
```

`KEY` waits by itself, so the `PAUSE 0` disappears; `BEGIN ... WHILE ...
REPEAT` is the loop of [Chapter 3](03-looping.md). `NEEDS <>` first.

**Waiting for a key, with a message.** The listing that stops every 20
lines, since vForth never asks `scroll?`:

```
5 POKE 23692,-1
10 FOR n=1 TO 100
20   PRINT n
30   IF n/20=INT (n/20) THEN PRINT "Press a key": PAUSE 0
40 NEXT n
```

<!-- no-test -->
```forth
: LISTING  ( -- )
    101 1 DO
        I . CR
        I 20 MOD 0= IF  ." Press a key"  KEY DROP CR  THEN
    LOOP ;
```

Without line 5, BASIC asks `scroll?` before the first "Press a key" has
appeared: the `POKE` of SCR CT to 255 (`-1` is the same byte) keeps it
quiet, and the program stops only where it chooses. In vForth that
`POKE` is always done already.

## No equivalent

- **`PRINT` items and separators.** A sequence of words does the same.
- **The lower part of the screen, `INPUT AT`.** `ACCEPT` reads where the
  cursor is; place it first with `.AT`.
- **The `scroll?` question and `POKE 23692`.** vForth never asks; stop a
  listing with `KEY` where you want.
- **`SCREEN$`.** Not in vForth. It would compare the 8 bytes at a screen
  position with the ROM font, a candidate for a small word.
- **`PRINT POINT x,y;`**, text at pixel coordinates. Not in vForth.
- **`INKEY$` as a character without waiting.** `KEY-SCAN` gives the key,
  not the character.
- **The keyboard joystick of NextZXOS.** Read the keys with
  `NEEDS KEYBOARD`.

## Further reading

- Tutorial `003` -- `."`, `.`, `EMIT`, `CR`.
- Tutorial `014` -- pictured numeric output, `.R` and its relatives.
- Tutorial `016` -- `ACCEPT`, `KEY` and reading numbers.
- Tutorial `030` -- `.AT` and `.TAB` on the ULA screen.
- Tutorial `031` -- screen control: `INVERSE`, `OVER`, `PAGE`.
- Tutorial `051` -- `NEEDS KEYBOARD`, scanning keys for a game.
- Tutorial `021` -- `EVALUATE`.
- Tutorial `071` -- codes 29 and 30, the size of the characters.
- `HELP ."`, `HELP .R`, `HELP .AT`, `HELP .TAB`, `HELP ACCEPT`,
  `HELP KEY`, `HELP EVALUATE`, `HELP ?TERMINAL`, `HELP P@`.
- [Chapter 13](13-the-character-set.md) -- control codes and `EMITC`.
- Chapter 20 and tutorial `070` -- streams: printing somewhere else
  than the screen.

<!-- nav -->
---

Previous: [Chapter 13 - The Character Set](13-the-character-set.md) |
[Contents](README.md) |
Next: [Chapter 15 - Colours](15-colours.md)
