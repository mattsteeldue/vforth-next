# Chapter 17 - Time and Motion

[From NextBASIC to vForth](README.md)

Manual: Chapter 17, pp. 121-143.

## In short

The clock is the same machine underneath, reached by other means.
`PAUSE n` becomes a loop of `1FRAME`, a core word that waits for the
next frame, or `ms`, which counts milliseconds. `PAUSE 0` is `KEY`.
The frame counter is the same system variable, FRAMES, read with `@`.
`TIME` has no word, but it is two short lines. `TIME$` becomes
`IDE_RTC`, which leaves the date and the time on the stack as numbers.
There is no string to slice. The sprites are the same hardware, and
`NEEDS SPRITE` gives a small engine: fill a structure, then send it to
a slot. What the NextBASIC sprite system does by itself is left to the
program: remembering each sprite, moving it, testing collisions.
`LAYER AT` is a Next register, and the Copper has its own library,
whose instructions have names instead of numbers.

## What changes

**A pause is a loop of frames.** `1FRAME` waits for the next frame
interrupt, 50 or 60 times a second, as `PAUSE 1` does. A longer
pause is a loop:

```forth
: WAIT-FRAMES  ( n -- )  0 ?DO  1FRAME  LOOP ;
5 WAIT-FRAMES
```

`ms` waits for a number of milliseconds, up to 8191, whatever the CPU
speed and the frame rate:

```forth
NEEDS ms
100 ms
```

So `PAUSE 50` is `50 WAIT-FRAMES` or `1000 ms`. The first follows the
display: one second at 50 Hz, less at 60 Hz. The second is a busy loop
that knows nothing of the display, timed on the CPU speed, and it does
not suspend the interrupts: the time the ROM's interrupt takes at every
frame is added to the loop, so `n ms` waits *at least* `n`
milliseconds, a little longer in practice.

**A key does not cut the wait short.** Neither word looks at the
keyboard: a pause that a key can end, as `PAUSE` does, has to say so.
`KEY-SCAN` ([Chapter 14](14-more-about-print-and-input.md)) leaves 255
when no key is down:

```forth
NEEDS KEYBOARD
: PAUSE  ( n -- )
    0 ?DO  1FRAME  KEY-SCAN 255 - IF LEAVE THEN  LOOP ;
10 PAUSE
```

`PAUSE 0` waits for a key with no time limit, and that is `KEY DROP`.
`KEY` waits for a key and takes the character, but shows no cursor. In
the first versions of vForth it did; the part that shows the flashing
cursor and waits has long since become a word of its own, `CURS`,
which waits for a key and leaves it to be read. `CURS KEY` joins the
two waits into one: the cursor flashes until a key is pressed, and
`KEY` takes it at once. `NEEDS WAIT-KEY` gives
`WAIT-KEY`, which shows nothing and leaves the key where it is: like
BASIC, it waits for the keyboard to be free and then for a new key.

**The frame counter is the same.** FRAMES is the system variable at
23672, three bytes, counted up by the interrupt of the ROM. vForth
leaves that interrupt alone, so the counter runs just as it does under
BASIC. `@` reads its two lower bytes, which go round every 21 minutes
at 50 Hz. `TIME` as a command and as a function are two words:

```forth
: RESET-TIMER  ( -- )  0 23672 !  0 23674 C! ;
: TIMER  ( -- u )  23672 @ ;
RESET-TIMER
```

To measure a piece of program there is no need to reset anything: read
`TIMER` before and after, and subtract. The difference is right even
when the counter goes round in between, since `-` works modulo 65536.
As the manual warns, the counter stops whenever the interrupts are off:
during `BEEP`, a disk operation and so on.

**50 or 60 Hz.** Bit 2 of Next register 5 tells which:

```forth
: HZ  ( -- n )  5 REG@ 4 AND IF 60 ELSE 50 THEN ;
HZ .                            \ 50 or 60
```

`TIMER HZ /` is then the number of seconds, on either setting.

**The clock comes as numbers.** `TIME$` gives a string to slice with
`VAL`. vForth asks NextZXOS directly, and the answer arrives on the
stack: `NEEDS IDE_RTC` gives `IDE_RTC ( -- hs time date )`. The time
and the date are packed in the format of MS-DOS, the one of the file
dates on the SD card. The hours are in the top 5 bits of `time`, the
minutes in the middle 6, the seconds in the bottom 5, *halved*:

```forth
: HOURS    ( time -- h )  11 RSHIFT ;
: MINUTES  ( time -- m )  5 RSHIFT 63 AND ;
: SECONDS  ( time -- s )  31 AND 2* ;
34544 DUP HOURS .  DUP MINUTES .  SECONDS .   \ => 16 55 32
```

34544 is the 16:55:32 of the manual's example. The seconds come in
steps of two: for the exact second `NEEDS M_GETDATE` gives
`M_GETDATE ( -- date time hs f )`, where the high byte of `hs` holds the
seconds and `f` is 0 when the clock has answered. `NEEDS .NOW` gives
`.NOW`, which prints date and time as `2023-05-10 16:55`, without the
seconds. A machine with no clock module returns zeros.

**Sprites: the same hardware, a smaller library.** `NEEDS SPRITE`
gives the pieces, and the program puts them together:

- `SPRITES-ON` and `SPRITES-OFF` are `SPRITE PRINT 1` and `0`.
  `SPRITES-ON` does more: it sets the sprite palette to the identity
  (colour i is index i), the transparent colour to 227 as in BASIC,
  and writes 3 into Next register `$15`: sprites on, and over the
  border, as `SPRITE BORDER 1`. That write also resets the order of the
  layers (Chapter 22); a program that changed it sets it again after.
- A pattern is 256 bytes, put in `SPRITE-BUFFER` and sent to the
  sprite RAM with `p SPRITE-INIT`. No bank is needed: the pattern goes
  from any memory, one at a time, and there is no `SPRITE BANK`.
- `SPRITE` is not a command but a structure of 9 bytes, the one the
  library works with. Its fields are `_spriteid` (the pattern, despite
  the name), `_xcoord`, `_ycoord`, `_rotmir` (the flags) and
  `_pattern` (the palette offset, despite the name). `SPRITE s
  SPRITE-UPDATE` sends it to slot `s`:

<!-- no-test -->
```forth
NEEDS SPRITE
SPRITES-ON
152 SPRITE _xcoord !  119 SPRITE _ycoord !  0 SPRITE _spriteid !
SPRITE 0 SPRITE-UPDATE          \ SPRITE 0,152,119,0,1
```

Every `SPRITE-UPDATE` sends all the values, and always makes the
sprite visible. There is no "leave it as it was": what is not changed
in the structure is sent again as it is. The slot is the argument of
`SPRITE-UPDATE`, the pattern is a field. Mixing them up shows extra
sprites rather than an error. `s SPRITE-HIDE` makes a sprite
invisible, and `SPRITE CLEAR` is a loop:
`128 0 DO I SPRITE-HIDE LOOP`.

**The flags are the same bits.** `SPRITE-ROT`, `SPRITE-VFLIP` and
`SPRITE-HFLIP` are bits 1, 2 and 3 of the BASIC flags, ORed into
`_rotmir`:

```forth
NEEDS SPRITE
SPRITE-ROT SPRITE-HFLIP OR .    \ => 10
```

The palette offset, bits 4 to 7 of the BASIC flags, goes into the high
nibble of `_pattern`. Keep it at 0 unless you mean it: the library's
`SPRITE` starts at 0, but a structure of your own made with `ALLOT`
must be cleared with `ERASE`, or the sprite shows the wrong colours.

**The coordinates are those of BASIC.** 320 by 256, the screen
starting at 32,32, the top left corner of the sprite as its position.
`_xcoord` is a whole cell, and `SPRITE-UPDATE` sends its ninth bit.

**The sprite RAM cannot be read back**, as the manual says, and the
library keeps no copy of what it sent. The functions `SPRITE s` and
`SPRITE AT(s,c)` have no counterpart: the program knows where it put
each sprite, and keeps it in its own variables or structures.

**`LAYER AT` is a register for each layer.** BASIC moves the current
layer; vForth writes the offset register of the layer you mean:

| Layer | x | y |
|---|---|---|
| Layer 2 | `$16` | `$17` |
| ULA (Layer 0 and 1) | `$26` | `$27` |
| LoRes | `$32` | `$33` |
| tilemap (Layer 3) | `$30` (high bits `$2F`) | `$31` |

`x $16 REG!  y $17 REG!` is `LAYER AT x,y` on Layer 2, with the same
wrap-around. On Layer 2 at 320 points, the ninth bit of x goes in
`$71`.

**The Copper has a library.** `NEEDS COPPER` names the two
instructions. `v h COP-WAIT` waits for line `v` (0 to 311) and position
`h` (0 to 55); `value reg COP-MOVE` writes a value to a Next register
(0 to 127, as in BASIC). The list is written as Forth code between
`COP-STOP`, which stops the Copper and starts the list again from the
first instruction, and `COP-HALT COP-START`. `COP-START` uses the mode
that starts again at every frame, as the manual's example does with
`REG 98,%@11000000`. `COP-NOOP` is the `MOVE 0,0` of the manual, a
short delay.

**Frames from storage or from memory.** The machinery is that of
Chapters 19 and 23: `LOAD-BYTES` reads a file into memory, and a Layer 2
screen is six 8K pages, mapped one at a time with `MMU7!`. A file name
with a number in it is built by hand, since there is no `+` for
strings: see [Chapter 7](07-strings.md). To show frames kept in memory,
a program does not need to copy 48K at all: Next register `$12`
chooses the 16K bank the Layer 2 shows, and one `REG!` flips to
another screen.

## Correspondence table

| NextBASIC | vForth | Note |
|---|---|---|
| `PAUSE n` | `n WAIT-FRAMES` above | `1FRAME` repeated. No key ends it. |
| `PAUSE n`, cut short by a key | `n PAUSE` above | `NEEDS KEYBOARD`. |
| `PAUSE 0` | `KEY DROP`, or `WAIT-KEY` | `NEEDS WAIT-KEY`: no cursor, the key stays. |
| a delay in milliseconds | `n ms` | `NEEDS ms`. Up to 8191. |
| `PEEK 23672+256*PEEK 23673` | `23672 @` | Add `23674 C@` for the third byte. |
| `TIME` (command) | `RESET-TIMER` above | |
| `TIME` (function) | `TIMER` above | |
| `REG 5&@100>>2` | `5 REG@ 4 AND` | Not zero at 60 Hz. `HZ` above. |
| `TIME$` | `IDE_RTC`; `.NOW` prints | `NEEDS IDE_RTC`, `NEEDS .NOW`. Numbers, not a string. |
| `VAL TIME$(12 TO 13)` etc. | `HOURS`, `MINUTES`, `SECONDS` above | Seconds in steps of two. |
| the exact second | `M_GETDATE` | `NEEDS M_GETDATE`. High byte of `hs`. |
| `OPEN #2,"v>t$": .TIME` | `IDE_RTC` | No dot command to capture. |
| `INKEY$` | `KEY`, `KEY-SCAN` | Chapter 14. |
| `SAVE`/`LOAD ... CODE` frames | `SAVE-BYTES`, `LOAD-BYTES` | Chapters 19 and 23. |
| `BANK n COPY TO m` frames | `MMU7!` and `CMOVE`, or `n $12 REG!` | Flipping the bank shown copies nothing. |
| `BANK n LAYER x,y,w,h TO ...` | - | |
| `BANK NEW`, `BANK POKE` for a pattern | `CREATE` and `C,` | Any memory will do. |
| `SPRITE CLEAR` | `128 0 DO I SPRITE-HIDE LOOP` | |
| `SPRITE BANK b` | `p SPRITE-INIT`, one per pattern | From `SPRITE-BUFFER`. |
| `SPRITE PRINT 1`, `0` | `SPRITES-ON`, `SPRITES-OFF` | `SPRITES-ON` also sets palette, transparency, border. |
| `SPRITE BORDER n` | bit 1 of `$15` | `SPRITES-ON` sets it. |
| `SPRITE DIM x1,y1,x2,y2` | `CLIP-SPRITES` below | |
| `SPRITE s,x,y,p,f` | fields of `SPRITE`, then `SPRITE s SPRITE-UPDATE` | Always visible. `s SPRITE-HIDE` hides. |
| flags: rotate, mirrors | `SPRITE-ROT`, `SPRITE-VFLIP`, `SPRITE-HFLIP` in `_rotmir` | |
| flags: palette offset | high nibble of `_pattern` | |
| `rf`, `mx`, `my` (relative sprites, scaling) | - | |
| `SPRITE PALETTE n,i,v` | `%00100000 $43 REG!`, `i $40 REG!`, `v $41 REG!` | 8-bit value; for 9 bits, two writes to `$44`. |
| `SPRITE STOP`, `SPRITE MOVE INT`, `SPRITE RUN` | `1FRAME`, then all the `SPRITE-UPDATE`s | |
| `SPRITE CONTINUE`, `SPRITE PAUSE` | - | The program moves the sprites. |
| `SPRITE s`, `SPRITE AT(s,c)` | - | The program knows. |
| `SPRITE OVER(s1,s2)` | `HIT?` below | |
| `LAYER AT x,y` | `x $16 REG!  y $17 REG!` (Layer 2) | One register pair per layer. |
| Copper: `REG 97`, `REG 98` | `COP-STOP`, `COP-START` | `NEEDS COPPER`. |
| Copper: `REG 96,m: REG 96,l` | `v h COP-WAIT`, `value reg COP-MOVE` | |

## Side by side

**Testing the pause.** `TIME` resets the counter, and `display()` shows
it twice, read as FRAMES and as `TIME`, before and after a `PAUSE`:

```
10 INPUT "A number: ";%N
20 TIME : ;Reset timer
30 PROC display()
40 PAUSE %N
50 PROC display()
60 STOP
70 ;
100 DEFPROC display()
110 T1,T2= DPEEK 23672, TIME
120 PRINT T1,T2
130 ENDPROC
```

```forth
: DISPLAY  ( -- )  CR  23672 @ .  TIMER . ;
```

<!-- no-test -->
```forth
RESET-TIMER DISPLAY  100 WAIT-FRAMES  DISPLAY
```

```text
0 0
100 100
```

In Forth the two numbers are the same by definition, since `TIMER` is
`23672 @`. The number of frames is typed on the line, as with any word;
`INPUT` would be Chapter 14. There is no need to define the main
program: a line without loops or `IF` runs at the prompt as it is.

**Hours, minutes, seconds.** `Now()` slices `TIME$` and returns three
numbers:

```
10 T$= TIME $
20 PRINT 't$
30 PROC now() TO h,m,s
40 PRINT "It's ";h;":";m
90 STOP
100 DEFPROC Now()
110 T$= TIME $
120 PRINT 't$
130 hh= VAL (T$(12)+T$(13))
140 mi= VAL (T$(15)+T$(16))
150 ss= VAL (T$(18)+T$(19))
160 ENDPROC =hh,mi,ss
```

```forth
NEEDS IDE_RTC
: NOW  ( -- h m s )
    IDE_RTC DROP NIP
    DUP HOURS  OVER MINUTES  ROT SECONDS ;
```

`IDE_RTC` leaves three values; `DROP NIP` keeps the time only. The
three results stay on the stack, as `ENDPROC =hh,mi,ss` returns three.
To print them as `TIME$` does, with two digits each:

```forth
: .00  ( n -- )  0 <# # # #> TYPE ;
: .HMS  ( h m s -- )
    ROT .00 [CHAR] : EMIT  SWAP .00 [CHAR] : EMIT  .00 ;
16 55 32 .HMS                   \ => 16:55:32
```

`NOW .HMS` prints the time of the clock. The emulator has no
clock, so the line above gives the numbers itself.

**A sprite pattern.** A pattern is 16 rows of 16 pixels, one byte
each: the colour, in the eight bits RRRGGGBB, with `$E3` for a pixel
that is not drawn. In BASIC the 256 numbers go into `DATA` lines, read
with `READ` and put into a bank with `BANK POKE`. In Forth the numbers
go straight into memory as the source is read. A row of 16 numbers is
on the stack at the end of the line, and a word stores them, the last
one first:

```forth
: ROW!  ( n1 ... n16 a -- )
    15 +  16 0 DO  SWAP OVER C!  1-  LOOP  DROP ;
: ROW,  ( n1 ... n16 -- )  HERE ROW!  16 ALLOT ;
CREATE PROBE  1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 ROW,
PROBE C@ .  PROBE 15 + C@ .     \ => 1 16
```

The numbers need not be written as numbers. A constant with a name of
one letter for each colour, and the pattern can be drawn in the source,
one row per line: here a little man walking to the right.

```forth
$E3 CONSTANT _                  \ transparent
$88 CONSTANT h                  \ hair, brown
$F6 CONSTANT o                  \ skin
$00 CONSTANT k                  \ eye and shoes, black
$E0 CONSTANT s                  \ shirt, red
$03 CONSTANT t                  \ trousers, blue
CREATE WALKER
_ _ _ _ _ _ h h h h _ _ _ _ _ _ ROW,
_ _ _ _ _ h h h h h h _ _ _ _ _ ROW,
_ _ _ _ _ h o o o o _ _ _ _ _ _ ROW,
_ _ _ _ _ o o o o k _ _ _ _ _ _ ROW,
_ _ _ _ _ o o o o o o o _ _ _ _ ROW,
_ _ _ _ _ _ o o o o _ _ _ _ _ _ ROW,
_ _ _ _ _ s s s s s s s _ _ _ _ ROW,
_ _ _ _ s s s s s s s s s _ _ _ ROW,
_ _ _ s s _ s s s s s _ s s _ _ ROW,
_ _ o _ _ _ s s s s s _ _ _ o _ ROW,
_ _ _ _ _ _ t t t t t _ _ _ _ _ ROW,
_ _ _ _ _ t t t _ t t t _ _ _ _ ROW,
_ _ _ _ _ t t t _ _ t t t _ _ _ ROW,
_ _ _ t t t _ _ _ _ _ t t t _ _ ROW,
_ k k k _ _ _ _ _ _ _ _ k k k _ ROW,
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ ROW,
WALKER 255 + C@ .               \ => 227
```

BASIC comes close with a string for each row, a letter for each colour,
as the listing below does. But there the letter is only a letter: the
program looks it up in a table while it runs, pixel by pixel. In Forth
the constant is the value, and `ROW,` takes it as it would take a
number, once, while the source is read.

The second pattern, the other half of the step, differs from the first
in seven rows: the arms, which hang down, and the legs, which close.
Copy the first and change those rows:

```forth
CREATE WALKER2  256 ALLOT
WALKER WALKER2 256 CMOVE
: ROW2!  ( n1 ... n16 r -- )  16 * WALKER2 + ROW! ;
_ _ _ _ _ s s s s s s s _ _ _ _  7 ROW2!
_ _ _ _ _ s s s s s s s _ _ _ _  8 ROW2!
_ _ _ _ _ _ s s s s s _ _ _ _ _  9 ROW2!
_ _ _ _ _ _ _ t t t _ _ _ _ _ _ 11 ROW2!
_ _ _ _ _ _ _ t t t _ _ _ _ _ _ 12 ROW2!
_ _ _ _ _ _ _ t t t _ _ _ _ _ _ 13 ROW2!
_ _ _ _ _ _ _ k k k k k _ _ _ _ 14 ROW2!
WALKER2 14 16 * + 7 + C@ .      \ => 0
```

Then both go to the sprite RAM, as patterns 0 and 1:

<!-- no-test -->
```forth
NEEDS SPRITE
: PATTERN!  ( a p -- )  SWAP SPRITE-BUFFER 256 CMOVE  SPRITE-INIT ;
WALKER 0 PATTERN!  WALKER2 1 PATTERN!
```

There is no file to save first, and no bank to reserve. Running the
program again does not use up memory as `BANK NEW` does: the patterns
are part of the program. To keep them in a file, `SAVE-BYTES` writes
the 256 bytes as they are (Chapter 19).

**A sprite that walks.** The two patterns take turns while the man
crosses the screen from left to right, two pixels at a time, and then
disappears. It is always the same sprite, slot 0; what changes at every
step is the pattern it shows. The BASIC program first draws the two
patterns itself, from the same rows as the Forth source:

```
10 GO TO 100
20 FOR i=1 TO 16: FOR c=1 TO 16: FOR n=1 TO 6
30 IF r$(i,c)=k$(n) THEN OUT 91,v(n)
40 NEXT n: NEXT c: NEXT i: RETURN
100 DIM r$(16,16): DIM v(6): LET k$="_hokst"
110 FOR i=1 TO 6: READ v(i): NEXT i
120 FOR i=1 TO 16: READ r$(i): NEXT i
130 OUT 12347,0: GO SUB 20
140 FOR j=1 TO 7: READ i: READ r$(i): NEXT j
150 OUT 12347,1: GO SUB 20
200 SPRITE PRINT 1
210 FOR %x=32 TO 288 STEP 2
220 SPRITE 0,%x,128,%x/8&1,1
230 PAUSE 2
240 NEXT %x
250 SPRITE 0,0,0,0,0
300 DATA 227,136,246,0,224,3
310 DATA "______hhhh______","_____hhhhhh_____"
320 DATA "_____hoooo______","_____ooook______"
330 DATA "_____ooooooo____","______oooo______"
340 DATA "_____sssssss____","____sssssssss___"
350 DATA "___ss_sssss_ss__","__o___sssss___o_"
360 DATA "______ttttt_____","_____ttt_ttt____"
370 DATA "_____ttt__ttt___","___ttt_____ttt__"
380 DATA "_kkk________kkk_","________________"
400 DATA 8,"_____sssssss____",9,"_____sssssss____"
410 DATA 10,"______sssss_____",12,"_______ttt______"
420 DATA 13,"_______ttt______",14,"_______ttt______"
430 DATA 15,"_______kkkkk____"
```

`OUT 12347,p` chooses pattern `p` on port `$303B`, and each `OUT 91`
sends one pixel of it to port `$5B`, 256 for a pattern. Lines 300 to 380
are the first pattern, with the six colours of `k$` in the same order
in line 300; lines 400 to 430 are the seven rows of the second pattern
that differ from the first. Integer expressions are worked out strictly
from left to right, so `%x/8&1` is `(x/8)&1`: the pattern changes every
8 pixels, 0, 1, 0, 1. The last flag 0 of line 250 makes the sprite
invisible. The Forth word expects the two patterns already sent, by
`WALKER 0 PATTERN!  WALKER2 1 PATTERN!` above.

<!-- no-test -->
```forth
NEEDS SPRITE
: WALK  ( -- )
    SPRITES-ON  128 SPRITE _ycoord !
    290 32 DO
        I              SPRITE _xcoord !
        I 8 / 1 AND    SPRITE _spriteid !
        2 WAIT-FRAMES  SPRITE 0 SPRITE-UPDATE
    2 +LOOP
    0 SPRITE-HIDE ;
```

`2 +LOOP` is `STEP 2`, and the loop stops before 290, after 288 as in
BASIC. The update comes right after the wait, at the start of a frame,
so the sprite does not change while it is being drawn. The slot, 0, is
written once in `SPRITE 0 SPRITE-UPDATE` and never changes; the pattern
is a field of the structure. Giving the pattern number as the slot, as
in `SPRITE I 1 AND SPRITE-UPDATE`, would not animate the man: it would
light a second sprite in slot 1 and leave it on the screen.

**Batching.** `SPRITE STOP ... SPRITE MOVE INT` has the same shape:
wait for the frame, then send every sprite at once.

<!-- no-test -->
```forth
: MOVE-ALL  ( -- )
    1FRAME
    SPRITE 0 SPRITE-UPDATE  \ ... one per sprite
    ;
```

A program with several sprites keeps one structure for each: `CREATE
ALIEN SPRITE-OB ALLOT  ALIEN SPRITE-OB ERASE`, then `ALIEN 3
SPRITE-UPDATE`.

**A collision test.** `SPRITE OVER(s1,s2)` compares two boxes of 16 by
16. With the positions in the program's own hands, so does this:

```forth
: HIT?  ( x1 y1 x2 y2 -- flag )
    ROT - ABS 16 < >R  - ABS 16 < R> AND ;
10 10 20 25 HIT? .              \ => -1
10 10 30 10 HIT? .              \ => 0
```

Two sprites touch when they are less than 16 points apart in both
directions. The overlap that BASIC allows is a smaller number in place
of 16. For a range of sprites, loop over their structures.

**Clipping the sprites.** `SPRITE DIM` writes four values to one
register, like `LAYER DIM` in Chapter 16, and in the order of the
hardware, which is not BASIC's:

```forth
: CLIP-SPRITES  ( x1 y1 x2 y2 -- )
    ROT SWAP                    \ x1 x2 y1 y2
    2 $1C REG!                  \ start again from the first one
    2SWAP SWAP $19 REG! $19 REG!  SWAP $19 REG! $19 REG! ;
0 0 255 191 CLIP-SPRITES
```

The window is counted inside the screen, not in the 320 by 256 of the
sprite positions, and it has no effect while the sprites are over the
border: `SPRITES-ON` puts them there. To use it, write 1 into `$15`
after `SPRITES-ON`: sprites on, under the border.

**An earthquake.** For fifty frames the text screen shakes by a few
pixels, in both directions at random, and then goes back in place:

```
10 LAYER 1,1: CLS: PRINT AT 10,10;"EARTHQUAKE!"
20 FOR %n=1 TO 50
30 LAYER AT %RND 8,%RND 8
40 PAUSE 1
50 NEXT %n
60 LAYER AT 0,0: LAYER 0
```

```forth
NEEDS RND
: QUAKE  ( -- )
    50 0 DO  8 RND $26 REG!  8 RND $27 REG!  1FRAME  LOOP
    0 $26 REG!  0 $27 REG! ;
QUAKE  $26 REG@ .  $27 REG@ .   \ => 0 0
```

BASIC moves the current layer, but not Layer 0: there `LAYER AT` stops
with `Invalid mode`. `LAYER 1,1` is the same ULA screen, 256 by 192,
seen as Layer 1, and `LAYER 0` at the end goes back. vForth writes the
offset registers of the ULA, `$26` and `$27` in the table above. The ULA is
also the screen vForth types on: `LAYER12` is a Layer 1 mode, so
`QUAKE` shakes the prompt itself, with no change of mode and nothing to
load. `8 RND` is `%RND 8`, from 0 to 7 ([Chapter 10](10-random-numbers.md)).
The offset wraps around: what leaves the screen on one side comes back
on the other, so the shake shows a thin strip of the opposite edge.
`1FRAME` is the `PAUSE 1`: without a wait the Forth loop would be over
long before the screen could be seen to move, since fifty pairs of
writes to a register take no time at all.

**The Copper.** Bars of colour in the border, eight lines each, in
eight shades of red from black to bright and again, from the top of the
screen down. The list is built by a loop: for each band, a wait for its
first line and two writes, palette index 16 into register 64 (`$40`)
and the colour into register 65 (`$41`):

```
10 BORDER 0: PAPER 7: CLS
20 REG 67,0: REG 98,0: REG 97,0
30 FOR %b=0 TO 38
40 REG 96,%208+(b>>5): REG 96,%(b*8)&255
50 REG 96,64: REG 96,16
60 REG 96,65: REG 96,%b&7*32
70 NEXT %b
80 REG 96,255: REG 96,255
90 REG 98,192
100 PAUSE 0
110 REG 98,0: REG 64,16: REG 65,0
```

Each instruction is two bytes, the high one first, written to register
96. A wait has bit 15 set, the position in bits 14-9 and the line in
bits 8-0: 208 is 128 plus twice 40, a position in the flyback after the
right border, so the colour changes out of sight and not part-way along
a line. The Copper counts its lines from the top of the paper, not from
the top of the picture: the top border comes last, lines 256 to 311 at
50Hz, and a line above 255 needs bit 8, the `b>>5` added to 208. Hence
39 bands and not 32: with the waits stopping at line 248, the last
colour stayed on through the top border, a red block above the paper.
Index 16 is paper 0, the colour of the border here; `PAPER 7` keeps it
out of the screen. `%b&7*32` is `(b&7)*32`, the three red bits of the
colour; since 256 is a multiple of eight lines, the band at the top of
the picture is black. 255,255 ends the list. 192 in register 98 starts
the Copper again at every frame; any key stops it, and the last line
puts black back.

<!-- no-test -->
```forth
NEEDS COPPER  NEEDS LAYER0  NEEDS .PAPER  NEEDS .BORDER
: BAND  ( b -- )                \ eight lines, a shade of red
    DUP 8 * 40 COP-WAIT
    16 $40 COP-MOVE  7 AND 32 * $41 COP-MOVE ;
: BARS  ( -- )
    LAYER0  7 .PAPER  0 .BORDER  CLS  0 $43 REG!
    COP-STOP  39 0 DO  I BAND  LOOP  COP-HALT  COP-START
    KEY DROP
    COP-STOP  16 $40 REG!  0 $41 REG! ;
```

The list is code, with the names of the operations: `COP-WAIT` puts
line and position in the right bits, and `COP-HALT` is the 255,255.
`$43` chooses the palette that `$40` and `$41` write; `SPRITES-ON`
points it at the sprites, and `0 $43 REG!` brings back the first ULA
palette. Tutorial `054` makes stripes in the border in another way, by
sending bytes to port `$FE` with the DMA: those are not tied to the
beam, and their edges move from one frame to the next, while the
Copper's stand still.

## No equivalent

- **Automatic sprite movement**: `SPRITE CONTINUE`, `SPRITE PAUSE`
  and the function `SPRITE CONTINUE s`. Limits, steps, bouncing and
  animation are the program's own loop, as in `WALK` above.
- **Relative, composite and unified sprites**, and **scaling** (`rf`,
  `mx`, `my`). They use a fifth attribute byte that the library does
  not send; the structure has an `_anchor` field, unused.
- **Reading a sprite back**: `SPRITE s`, `SPRITE AT(s,c)`.
- **`SPRITE OVER` on a range**: `HIT?` above tests two sprites, and a
  loop does the rest.
- **4-bit sprites**, which BASIC does not use either. The hardware can
  be reached with ports and registers, but the library has no words.
- **`BANK n LAYER`**, copying a rectangle between the screen and a
  bank ([Chapter 23](23-the-memory.md)).
- **A clock string** with the seconds: `.NOW` prints without them, and
  nothing leaves the time as a string. `.HMS` above prints it.
- **`PAUSE` interrupted by a key** as a ready word: `PAUSE` above.

## Further reading

- Tutorial `032` -- `ms`, frame-synchronised loops, a stopwatch.
- Tutorial `072` -- the real-time clock: the MS-DOS fields, the day of
  the week, a clock on screen.
- Tutorial `039` -- the first sprites, with the registers written by
  hand.
- Tutorial `053` -- the sprite engine that became `NEEDS SPRITE`: slot
  and pattern, the palette offset.
- Tutorial `045` -- the Copper.
- Tutorial `046` -- loading pictures from files.
- `HELP 1FRAME`, `HELP ms`, `HELP WAIT-KEY`, `HELP KEY-SCAN`,
  `HELP M_GETDATE`, `HELP COPPER`, `HELP COP-WAIT`, `HELP COP-MOVE`,
  `HELP REG!`.
- [Chapter 22](22-in-out-and-the-next-registers.md) -- the Next registers,
  sprite ports included.
- [Chapter 23](23-the-memory.md) -- memory pages, for frames kept in memory.

<!-- nav -->
---

Previous: [Chapter 16 - Graphics](16-graphics.md) |
[Contents](README.md) |
Next: [Chapter 18 - Sound and Music](18-sound-and-music.md)
