# Chapter 16 - Graphics

[From NextBASIC to vForth](README.md)

Manual: Chapter 16, pp. 113-120.

## In short

The drawing statements carry over almost one for one: `PLOT`, `CIRCLE`
and `POINT` keep their names, `DRAW` becomes `DRAW-LINE`, and there is
a `PAINT` that BASIC does not have. They live in a library,
`NEEDS GRAPHICS`, which works on every layer of
[Chapter 15](15-colours.md). Three things change, and they cause most
of the surprises: the first coordinate is the row, not the column;
the origin is always the top left corner; there is no `PLOT` position,
so a line is given both ends. Colour items inside a statement become
a value, `ATTRIB`, set before drawing. `LAYER ERASE`, `LAYER CLEAR`,
the arcs of `DRAW` and the `TILE` commands have no words.

## What changes

**Graphics is a library.** `NEEDS GRAPHICS` loads the drawing words
for all six layers at once, and sets them up for the layer the screen
is in. From then on `LAYER0`, `LAYER10`, `LAYER11`, `LAYER12`,
`LAYER13` and `LAYER2` change the layer *and* point every drawing word
at the code for that layer. A program that uses only one layer can
load less: `NEEDS LAYER11-GRAPHICS` (or any other layer's name) loads
the common part and the code of that layer only, and switches to it.
The library also redefines `.INK`, `.PAPER` and the other colour words
of Chapter 15, so that they update the drawing colour as well.
`0 GRAPHICS` goes back to `LAYER12` and takes the library out of the
dictionary.

**The row comes first.** In the library the first coordinate, called
`x`, is the *vertical* one, counted from the top, and the second, `y`,
the horizontal one, counted from the left. Both start at 0. To avoid
mixing the two conventions, this chapter calls them row and column:

<!-- no-test -->
```forth
NEEDS GRAPHICS
LAYER11
96 128 PLOT                     \ row 96, column 128: the centre
```

**The origin is always at the top left.** BASIC puts it at the bottom
left on Layer 0, with 176 rows of pixels (0 to 175) above the lower
screen, and at the top left on the other layers. vForth has no lower
screen, so Layer 0 has 192 rows like the others, and row 0 is always
the top. A `PLOT bx,by` of a Layer 0 program becomes:

```forth
: B>XY  ( bx by -- row col )  175 SWAP - SWAP ;
10 20 B>XY SWAP . .             \ => 155 10
```

On the other layers the conversion is only a `SWAP`. The good side is
that a vForth drawing does not turn upside down when the layer
changes, as the manual shows that a BASIC one does. Only the size of
the screen changes, and the library keeps it in two values: `V-RANGE`
rows and `H-RANGE` columns (512 on `LAYER12`, 128 and 96 on `LAYER10`).

**There is no `PLOT` position.** `DRAW x,y` of BASIC starts where the
last statement left off and moves *by* `x`,`y`. `DRAW-LINE` takes the
two ends, and the end comes first:

<!-- no-test -->
```forth
191 255 0 0 DRAW-LINE           \ from the top left corner (0,0)
                                \ to the bottom right (191,255)
```

A program that draws like a pen keeps the last point in two values of
its own. Then the BASIC habit of relative steps is three short words:

<!-- no-test -->
```forth
NEEDS VALUE
NEEDS TO
0 VALUE PEN-ROW  0 VALUE PEN-COL
: MOVE-TO  ( row col -- )  TO PEN-COL  TO PEN-ROW ;
: LINE-TO  ( row col -- )  2DUP PEN-ROW PEN-COL DRAW-LINE  MOVE-TO ;
: LINE-BY  ( drow dcol -- )  PEN-COL +  SWAP PEN-ROW +  SWAP LINE-TO ;
75 0 MOVE-TO  35 80 LINE-BY     \ PLOT 0,100: DRAW 80,-35 (Layer 0)
```

The `-35` of BASIC goes *down* the Layer 0 screen, so it becomes `35`
rows: in vForth a positive row step always goes down.

**Points off the screen are ignored.** BASIC stops with an error on
Layer 0 and draws off the screen elsewhere. vForth does neither: on
every layer `PLOT` checks the point with `COORD-CHECK` and skips it in
silence if it is outside. A line or a circle that leaves the screen is
drawn up to the edge, with no error. The same check is there for you:
`row col COORD-CHECK` leaves a flag above the two numbers.

**The colour is a value, not an item.** `PLOT INK 2;x,y` has no
form: set the colour first, and every drawing word uses it until you
change it. The colour is the value `ATTRIB`, and what it means depends
on the layer. On the layers with attributes (`LAYER0`, `LAYER11`,
`LAYER13`) it is a whole attribute byte, paper and ink as in Chapter 15,
and each pixel drawn writes it into its cell: paper included, not the
ink only, as BASIC does unless told otherwise. On `LAYER10` and
`LAYER2` it is the palette index of the pixel, 0 to 255. With the
library loaded, `.INK` and `.PAPER` change `ATTRIB` too, so either way
works:

<!-- no-test -->
```forth
LAYER11
2 .INK  6 .PAPER                \ red on yellow, for text and pixels
1 6 8 * + TO ATTRIB             \ blue on yellow, for pixels only
```

**`POINT` returns the pixel, not a flag.** On the layers with one bit
per pixel it returns 128 for a pixel that is set and 0 for one that is
not, where BASIC returns 1 and 0. On `LAYER10` and `LAYER2` it returns
the palette index, as `POINT ... TO` does in BASIC, and -1 for a point
off the screen. There is no `TO` form: `POINT` is an ordinary word
that leaves its result on the stack, on every layer.

<!-- no-test -->
```forth
LAYER0 CLS
175 0 POINT .  175 0 PLOT  175 0 POINT .
```

```text
0 128
```

If a program wants BASIC's 0 and 1, `0= 0= 1 AND` makes them, and
`0= 0=` alone gives a Forth flag.

**`OVER 1` and `INVERSE 1` are words, not items.** `PLOT OVER 1` is
`XPLOT`: it flips the pixel. For a whole line, the library lets you
change what `PLOT` does to the byte of the screen: it calls the
deferred word `PLOTOP`, normally `L0-SET` (OR), and `L0-XOR` makes it
flip. `DRAW OVER 1` becomes:

<!-- no-test -->
```forth
: XLINE  ( row2 col2 row1 col1 -- )
    ['] L0-XOR IS PLOTOP  DRAW-LINE  ['] L0-SET IS PLOTOP ;
```

Draw the same `XLINE` twice and it is gone, writing or no writing
under it, just as the manual describes. (On the layers with attributes
the cells it crossed keep the colour of `ATTRIB`, as in BASIC they keep
the ink.) The manual's warning holds:
draw it again with the same four numbers, in the same order, or a few
pixels stay. `PLOT INVERSE 1`, which clears the pixel, is a third
operator. `NEEDS GRAPHICS` has it as `L0-RES`; with a one-layer
module, write it:

```forth
NEEDS INVERT
: UNSET  ( pattern byte -- byte' )  SWAP INVERT AND ;
128 255 UNSET .                 \ => 127
```

and `' UNSET IS PLOTOP` before drawing, `' L0-SET IS PLOTOP` after.
`PLOTOP` works on the layers with one bit per pixel (`LAYER0`,
`LAYER11`, `LAYER12`, `LAYER13`). On `LAYER10` and `LAYER2` there is
nothing to combine: drawing with the paper colour in `ATTRIB` clears
a pixel, and `XPLOT` inverts its palette index.

**`PAINT` fills an area.** NextBASIC has no fill command, as the
manual says. vForth has one: `NEEDS PAINT`, after the graphics library,
and `row col PAINT` fills the region around that point with `ATTRIB`.
On the layers with one bit per pixel the region ends at any pixel that
is set. On `LAYER10` and `LAYER2` it ends at pixels of the `ATTRIB`
colour, so the outline must be drawn in the colour you fill with:

<!-- no-test -->
```forth
NEEDS PAINT
LAYER2  CLS
224 TO ATTRIB                   \ red
96 128 40 CIRCLE  96 128 PAINT
```

**`CIRCLE` on HiRes.** `row col r CIRCLE` draws the whole circle, as in
BASIC. On `LAYER12`, where a pixel is half as wide as it is tall, `r`
is counted in columns and the library halves it in the vertical
direction, so the circle comes out round.

## Correspondence table

| NextBASIC | vForth | Note |
|---|---|---|
| (graphics always there) | `NEEDS GRAPHICS` | Or `NEEDS LAYER11-GRAPHICS` etc., one layer only. |
| `LAYER 0`, `LAYER 1,n`, `LAYER 2,1` | `LAYER0`, `LAYER10` ... `LAYER13`, `LAYER2` | With the library loaded, they also switch the drawing words. |
| `PLOT x,y` (Layer 0) | `175 y - x PLOT` | Row first, from the top. `B>XY` above. |
| `PLOT x,y` (other layers) | `y x PLOT` | |
| `DRAW x,y` | `row2 col2 row1 col1 DRAW-LINE` | Both ends. For relative steps, `LINE-BY` above. |
| `DRAW x,y,a` | - | No arcs. See "No equivalent". |
| `CIRCLE x,y,r` | `row col r CIRCLE` | |
| `POINT (x,y)` | `row col POINT` | 128 or 0, not 1 or 0. |
| `POINT x,y TO v` | `row col POINT` | Palette index on `LAYER10`, `LAYER2`. |
| `PLOT INK c;...` | `c .INK` or `b TO ATTRIB` before | Lasts until changed. |
| `PLOT OVER 1;x,y` | `row col XPLOT` | |
| `DRAW OVER 1;...` | `XLINE` above | `PLOTOP` set to `L0-XOR`. |
| `PLOT INVERSE 1;...` | `' L0-RES IS PLOTOP` | `UNSET` above with one-layer modules. |
| errors off the screen | none | `PLOT` skips the point. `COORD-CHECK` tests it. |
| screen size | `V-RANGE`, `H-RANGE` | Rows and columns of the current layer. |
| (no fill command) | `row col PAINT` | `NEEDS PAINT`. |
| `LAYER ERASE x1,y1,x2,y2,c` | `FILL-RECT` below | With `PLOT`, so slower. |
| `LAYER DIM x1,y1,x2,y2` | `CLIP-L2` below | Registers `$1C` and `$18`; `$1A` for Layers 0 and 1. |
| `LAYER CLEAR` | - | |
| stipple UDGs | UDGs as in Chapter 13 | |
| `TILE`, `TILE BANK`, `TILE DIM` | - | Layer 3 tilemaps are another thing: tutorial `058`. |
| Layer 2 at 320x256 and 640x256 | `NEEDS LAYER22-GRAPHICS`, `NEEDS LAYER24-GRAPHICS` | BASIC has no statements for them. 640x256 is still experimental. |

## Side by side

**A hyperbola.** The graph of `y=1/x`, on Layer 0, with the origin in
the middle of the screen: 50 pixels for each unit of x, 30 for each
unit of y.

```
10 FOR n=0 TO 255
20   LET x=(n-128)/50
30   IF x<>0 THEN LET y=88+30/x: IF y>=0 AND y<=175 THEN PLOT n,y
40 NEXT n
```

`30/x` is `30*50/(n-128)`, that is `1500/(n-128)`: whole numbers only,
and a single division.

```forth
1500 50 / .  1500 -50 / .       \ => 30 -30
```

<!-- no-test -->
```forth
: HYPERBOLA  ( -- )
    256 0 DO
        I 128 - ?DUP IF  87 1500 ROT / -  I PLOT  THEN
    LOOP ;
```

Two points need care, in BASIC as in Forth. At `x=0` the function is not
defined: BASIC would stop with `Number too big`, and `/` gives -1
without a word. `IF x<>0` skips it, and in Forth `?DUP IF` does, since it
leaves nothing to divide when the difference is 0. Near zero, `1/x`
leaves the screen: BASIC's `PLOT` stops with `Integer out of range`, so
the listing checks `y` first, while the library's `PLOT` ignores a point
outside the screen without an error. `87 ... -` turns the height into
a row, as for every curve of this chapter.

**The logarithm, out of the hyperbola.** `y=x*LN (ABS x)`, the same
screen and the same scale. The function is not defined at 0 either,
but it goes to 0 there, and it is odd: the left half is the right half
turned upside down.

```
10 FOR n=0 TO 255
20   LET x=(n-128)/50
30   IF x<>0 THEN PLOT n,88+30*x*LN (ABS x)
40 NEXT n
```

Forth has no logarithm without the floating-point library
([Chapter 9](09-mathematical-functions.md), `FLN`). But the logarithm
is the area under the hyperbola: `LN a` is the area under `1/t` from 1
to `a`. Walking along the x axis one pixel at a time, from `u` to
`u+1`, the area grows by a thin slice, very nearly `2/(2u+1)`. So the
logarithm can be added up slice by slice: no table and no floating
point. `LN50` holds `LN (u/50)`, 5000 times larger:

```forth
NEEDS VALUE
NEEDS TO
NEEDS +TO
0 VALUE LN50
: SLICE  ( u -- n )  2* 1+ 10000 SWAP / ;
: XLNX  ( u -- y )  3 *  LN50 25000 */ ;
: LN-UP  ( u -- )  0 TO LN50  50 ?DO  I SLICE +TO LN50  LOOP ;
100 LN-UP  LN50 .  100 XLNX .   \ => 3442 41
```

`LN-UP` adds the slices from 50 to `u`. From 50 to 100 pixels `x` goes
from 1 to 2: `LN50` is then `LN 2`, 0.6884 instead of 0.6931, and
`y=2*LN 2` is 41 pixels. `XLNX` is
`30*x*LN x` with `x=u/50`: `30/50*u*LN50/5000`, which is
`3*u*LN50/25000`. `*/` keeps the product in a double number, so
`3*u*LN50` can pass 32767 without harm.

<!-- no-test -->
```forth
: TWIN  ( u -- )                \ the point at u and its mirror at -u
    DUP XLNX                    ( u y )
    87 OVER -  2 PICK 128 +  PLOT
    87 +  128 ROT -  PLOT ;
: XLNX-GRAPH  ( -- )
    0 TO LN50  128 50 DO  I TWIN  I SLICE +TO LN50  LOOP
    0 TO LN50  1 49 DO  I SLICE NEGATE +TO LN50  I TWIN  -1 +LOOP ;
```

The first loop walks right from `x=1`, where the logarithm is 0, adding
a slice after each point; the second walks left from there towards 0,
taking a slice off before each point. Each point is drawn twice by
`TWIN`, at `u` and, upside down, at `-u`. The curve stays within a
pixel and a half of the one BASIC draws, and the walk to the left stops
at `x=0.02`, the last pixel before the point where the function is not
defined.

**A screen filled at random.** One random number picks a whole pixel:
its low 9 bits are the column, 0 to 511, and its high 7 bits the row,
0 to 127, in the 512 by 192 of `LAYER 1,2`. 65536 numbers, one for
each pixel of a band 512 wide and 128 high:

```
10 LAYER 1,2: CLS
20 FOR n=1 TO 65536
30   LET r=INT (RND*65536)
40   PLOT r-512*INT (r/512),32+INT (r/512)
50 NEXT n
60 PAUSE 0
```

On the 48K Spectrum `RND` was the new value of the system variable
SEED divided by 65536, so `INT (RND*65536)` was SEED itself and this
listing lit every pixel of the band. NextBASIC's `RND` is another
generator, of 32 bits ([Chapter 10](10-random-numbers.md)):
`INT (RND*65536)` is the upper half of its state, some values come out
twice and others never, and on the Next the listing lights only about
63% of the band, what 65536 draws at random are expected to hit.
vForth's `RND` keeps the 48K formula, and in Forth the step of the
generator is a word of its own, `NEXT-SEED`, which `NEEDS RND` loads
with `RND`:

```forth
NEEDS RND
23670 CONSTANT SEED
: NEXT-RND  ( -- u )  SEED @ NEXT-SEED  DUP SEED ! ;
: STEPS  ( n -- )  0 ?DO  NEXT-RND DROP  LOOP ;
1 SEED !  65535 STEPS  SEED @ .  \ => 25340
1 STEPS  SEED @ .               \ => 1
```

<!-- no-test -->
```forth
NEEDS GRAPHICS
: RND-FILL  ( -- )
    LAYER12 CLS
    256 0 DO  256 0 DO
        NEXT-RND  DUP 9 RSHIFT 32 +  SWAP 511 AND  PLOT
    LOOP  LOOP ;
```

The two nested loops of 256 make the 65536 steps. `LAYER12` is vForth's
own text screen, the same 512 by 192 as `LAYER 1,2`; `PLOT` takes the
row first.

The Forth screen shows something about `RND` itself. The generator is a
cycle: each value of SEED gives the next, and after 65536 steps it is
back where it started, as the two lines above show from 1. Within one
cycle no value comes twice, so no pixel is drawn twice and none is
missed: the band fills up completely, with no gap left at the end. A
better test of that is `2DUP POINT IF ... THEN` before `PLOT`, which
would catch a pixel already lit. Run it a second time and the very
same dots appear in the very same order: a random sequence that
repeats is the price of a generator of 16 bits, as the 48K's was.
NextBASIC's, of 32 bits, repeats only after 4294967295 numbers, and for
the same reason cannot fill the band: within 65536 draws some values
come twice.

**A frame that leaves no trace.** Four lines along the edges of the
screen; draw them, and draw them again.

```
10 GO SUB 100
20 PAUSE 0
30 GO SUB 100
40 STOP
100 PLOT OVER 1;0,0: DRAW OVER 1;255,0: DRAW OVER 1;0,175
110 DRAW OVER 1;-255,0: DRAW OVER 1;0,-174
120 RETURN
```

<!-- no-test -->
```forth
: RIM  ( -- )
    175   0  175 254 XLINE          \ bottom
    175 255    1 255 XLINE          \ right
      0 255    0   1 XLINE          \ top
      0   0  174   0 XLINE ;        \ left
: TRACE  ( -- )  RIM  KEY DROP  RIM ;
```

BASIC's bottom left corner is row 175, column 0; its top right corner
is row 0, column 255. Every pixel of the frame must be flipped once,
or a corner flipped twice stays dark when it should be lit, and lit
when it should be gone. `DRAW` does not plot the point it starts from,
so the four `DRAW`s meet at the corners without overlapping, and only
the last stops one pixel short, to leave the first corner to `PLOT`.
`DRAW-LINE` plots both its ends: each side of `RIM` stops one pixel
before the next corner.

**Filling a rectangle.** `LAYER ERASE` fills on LoRes and Layer 2
only. Horizontal lines do it on every layer, slower:

<!-- no-test -->
```forth
: FILL-RECT  ( row1 col1 row2 col2 -- )
    ROT 2SWAP 1+ SWAP           \ col2 col1 row2+1 row1
    ?DO  I 2 PICK  I 3 PICK  DRAW-LINE  LOOP
    2DROP ;
LAYER2  28 TO ATTRIB  120 100 130 140 FILL-RECT
```

The colour is `ATTRIB`, as for every drawing word; 28 is a green on
Layer 2. For speed on Layer 2, the framebuffer can be filled a row at
a time with `FILL` once its 8K page is mapped through `MMU7!`
([Chapter 23](23-the-memory.md)), or with the DMA of tutorial `054`.

**A clipping window.** `LAYER DIM` on Layer 2 writes four registers,
and so does the Forth version:

```forth
: CLIP-L2  ( row1 col1 row2 col2 -- )
    ROT SWAP                    \ row1 row2 col1 col2
    1 $1C REG!                  \ start again from the first one
    SWAP $18 REG!  $18 REG!     \ columns: left, right
    SWAP $18 REG!  $18 REG! ;   \ rows: top, bottom
0 0 191 255 CLIP-L2
```

The four writes go to the same register, `$18`, one after the other;
`$1C` with bit 0 set makes the next write the first. For Layers 0 and
1 the register is `$1A`, reset with bit 2 (`4 $1C REG!`); the sprites
have `$19` and bit 1. The window is in the order of the registers:
columns first.

## No equivalent

- **Arcs (`DRAW x,y,a`).** No word draws part of a circle. The turning
  point of `TURN` above draws one: start it at the right angle, and
  stop it after the right number of steps.
- **`LAYER ERASE`** as a single fast word. `FILL-RECT` above is the
  slow form; the fast one depends on the layer.
- **`LAYER CLEAR`.** Layer, palettes, clipping windows and the order of
  the layers are separate registers (Chapters 15 and 22); there is no
  word that resets them all.
- **`TILE`, `TILE BANK`, `TILE DIM`**: drawing a Layer 2 or LoRes
  screen from a map of tiles. vForth has the hardware tilemap of
  Layer 3 instead (`lib/layer3.f`, tutorial `058`), which BASIC does
  not reach directly.
- **The `PLOT` position**, and with it `DRAW` after `CIRCLE`. The pen
  words above do the job when needed.
- **Colour items inside the statement.** `ATTRIB` and the colour words
  are set before.

## Further reading

- Tutorial `036` -- `PLOT`, `DRAW-LINE`, `CIRCLE`, `XPLOT` on the ULA
  screen.
- Tutorial `037` -- the same on Layer 2, 256 colours.
- Tutorial `038` -- all six layers, `POINT`, `COORD-CHECK`, `PAINT`.
- Tutorial `052` -- loading one layer only: `LAYER11-GRAPHICS` and the
  others.
- Tutorial `054` -- the DMA, for fast fills and copies.
- Tutorial `058` -- the Layer 3 tilemap.
- Tutorial `065` -- a drawing made with a sine table.
- `HELP GRAPHICS`, `HELP PLOT`, `HELP DRAW-LINE`, `HELP CIRCLE`,
  `HELP XPLOT`, `HELP ATTRIB`, `HELP COORD-CHECK`, `HELP H-RANGE`,
  `HELP LAYER22-GRAPHICS`.
- [Chapter 22](22-in-out-and-the-next-registers.md) -- the Next registers,
  clipping windows included.

<!-- nav -->
---

Previous: [Chapter 15 - Colours](15-colours.md) |
[Contents](README.md) |
Next: [Chapter 17 - Time and Motion](17-time-and-motion.md)
