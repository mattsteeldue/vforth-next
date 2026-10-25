# Chapter 9 - Mathematical Functions

[From NextBASIC to vForth](README.md)

Manual: Chapter 9, pp. 60-63.

## In short

All the functions of this chapter exist, under names that start with `F`:
`FSIN`, `FCOS`, `FTAN`, `FASIN`, `FACOS`, `FATAN`, `FEXP`, `FLN`, `F**`,
and `PI`. They are not part of the core. They belong to the
floating-point library, which you load and switch on; underneath, it
calls the same calculator in the ROM that BASIC uses, so the mathematics
is BASIC's, with a little less precision. What is new is the rest: a
floating-point number takes two cells on the stack, it has its own words
for everything, `+` and `.` included, and nothing converts between the two
kinds of number for you. And very often a Forth program does not load the
library at all: the second half of this chapter shows how powers, roots,
pi, growth and sines are done with integers.

## What changes

**Floating point is loaded, then switched on.** Two separate steps.
`NEEDS FLOATING` loads the library. The word `FLOATING` then tells the
interpreter to read a number with a dot as a floating-point number, and
`INTEGER` tells it to go back to normal.

```forth
NEEDS FLOATING
FLOATING
7.0 2.0 F/ F.                   \ => 3.5000e0
INTEGER
```

Between `FLOATING` and `INTEGER` a number with a dot (`3.14`, `-0.5`,
`2.0`) or with an exponent (`1.5E3`) is floating point; a number without
either is still an ordinary integer, so loop limits and counts are
written as usual. Outside, a dot means what it meant in
[Chapter 6](06-expressions.md): a double integer. Forgetting `FLOATING`
gives no error, only wrong numbers, and so does forgetting `INTEGER`
afterwards. Make a habit of writing them in pairs.

**A floating-point number is two cells.** It travels on the ordinary
stack and takes two places there, like a double integer. So the stack
words for it are the double ones, `2DUP`, `2DROP`, `2SWAP`, `2OVER`, and a
stack comment calls it `fp`. `x*x` is `2DUP F*`.

**Every operation has its own word.** Nothing on the stack says "this is
floating point": the word you use decides, as it did for signed and
unsigned. The four operations are `F+`, `F-`, `F*` and `F/`; `F.` prints.
Using `+` or `.` on a floating-point number is not an error, and gives
nonsense. The same goes for comparing: `F<` and `F>` compare two numbers,
`F0<` and `F0>` test one against zero.

**The functions keep their BASIC meaning.** Angles are in radians. `FLN`
is the natural logarithm, `FEXP` its inverse. `F**` is the power, with the
base first and the exponent second. `FSQRT` is `SQR`, `FINT` is `INT`,
`FABS` is `ABS`, `FSGN` is `SGN`, `FNEGATE` changes the sign.

```forth
FLOATING
PI F.                           \ => 3.1416e0
2.0 FSQRT F.                    \ => 1.4142e0
1.0 FEXP F.                     \ => 2.7183e0
PI 6.0 F/ FSIN F.               \ => 5.0000e-1
INTEGER
```

**Some names are taken by something else.** `EXP` is a word of the core,
but it is a variable used by the number parser, not the exponential:
that is `FEXP`. `PI` does not exist until the library is loaded. `INT`,
`SIN` and the others have no meaning without the `F`.

**Wrong arguments are caught here.** Unlike integer words, these check:
the square root of a negative number, the logarithm of a number that is
not positive, `FASIN` or `FACOS` of a number outside -1 to 1 stop with
`Invalid floating point.`, and `F/` by zero stops with `Division by
zero.`

**Converting is always a word.** BASIC turns an integer into a
floating-point number, and back, whenever an expression needs it. Here
you say it: `FLOAT` turns a single integer into floating point, `D>F`
does it for a double; `F>D` goes back to a double integer, dropping the
fraction, and `FIX` to a single one.

```forth
FLOATING
42 FLOAT 1.5 F* F.              \ => 6.3000e1
3.7 F>D D.                      \ => 3
INTEGER
```

**`F.` prints in scientific notation.** Always a mantissa, the letter
`e` and an exponent, with four decimal places unless you say otherwise:
`2 PLACES` asks for two. `F.R` prints in a column of a given width, as
`.R` does. To print the way BASIC does for everyday numbers, convert to
an integer first (`F>D D.`), scaling before if you want decimals.

**About seven digits, not nine and a half.** The ROM calculator works
with five bytes for each number; on the Forth stack a number is kept in
four, with a 24-bit mantissa. The results are those of BASIC to about
seven significant digits. Do not expect the last digits of a long
calculation to match.

**Variables and constants are the double ones.** A floating-point
variable needs two cells: `2VARIABLE` (`NEEDS 2VARIABLE`), read with `2@`
and written with `2!`. A constant is `FCONSTANT`. The same words hold a
double integer, which is how they can be shown here:

```forth
NEEDS 2VARIABLE
2VARIABLE BIG
100000. BIG 2!
BIG 2@ D.                       \ => 100000
```

**It is slow, and Forth programmers avoid it.** Every operation goes
through the ROM calculator. For a table of results printed once, that
does not matter. Inside a game loop or a drawing routine it does, and
there the Forth habit is to stay with integers: scale the numbers so
that the fraction you need becomes whole (cents, tenths of a degree,
thousandths), use `*/` to multiply by a ratio without losing the
intermediate product, and take sines from a table. The examples below
show each of these next to its floating-point form.

**`NO-FLOATING` removes the library.** It takes the library out of the
dictionary and gives the interpreter back its integer-only number
reader. Words of yours defined after `NEEDS FLOATING` go with it.

## Correspondence table

| NextBASIC | vForth | Note |
|---|---|---|
| a number with a fraction | the same, between `FLOATING` and `INTEGER` | `NEEDS FLOATING`. Two cells. |
| `a+b` `a-b` `a*b` `a/b` | `F+` `F-` `F*` `F/` | Operands first, as always. |
| `-a` | `FNEGATE` | |
| `a^b` | `a b F**` | |
| `a^n`, `n` a whole number | a loop of `*` | `**`, below. No library needed. |
| `EXP x` | `FEXP` | `EXP` is another word. |
| `LN x` | `FLN` | |
| `LN x/LN a` | `x FLN a FLN F/` | |
| `PI` | `PI` | With integers: the ratio 355/113 in `*/`. |
| `SIN x` `COS x` `TAN x` | `FSIN` `FCOS` `FTAN` | Radians. |
| `ASN x` `ACS x` `ATN x` | `FASIN` `FACOS` `FATAN` | |
| degrees to radians, and back | `DEG>RAD`, `RAD>DEG` | Ready-made. |
| `SQR x` | `FSQRT` | With integers: `SQRT`, `DSQRT`. |
| `INT x` | `FINT` | Still floating point. `F>D` gives an integer. |
| `ABS x`, `SGN x` | `FABS`, `FSGN` | |
| `a<b`, `a>b` | `F<`, `F>` | |
| `a<0`, `a>0` | `F0<`, `F0>` | |
| `PRINT x` | `F.` | Scientific notation. `n PLACES` sets the decimals. |
| integer to floating point | `FLOAT` (single), `D>F` (double) | Never automatic. |
| floating point to integer | `FIX` (single), `F>D` (double) | The fraction is dropped. |
| `LET x=...` | `2VARIABLE X`, `X 2!`, `X 2@` | `NEEDS 2VARIABLE`. |
| a named value | `FCONSTANT` | |
| `A Invalid argument` | `Invalid floating point.` | Only in the library. |

## Side by side

Each example gives the BASIC listing, then the floating-point words, then
the way it is done with integers. The floating-point listings take
`NEEDS FLOATING` as already given.

**A power.**

```
10 PRINT 2^10
```

```forth
FLOATING
2.0 10.0 F** F.                 \ => 1.0240e3
INTEGER
```

When the exponent is a whole number, a power is a multiplication repeated,
and it needs no library:

```forth
: **  ( n u -- n^u )  1 SWAP 0 ?DO  OVER *  LOOP  NIP ;
2 10 ** .                       \ => 1024
3 4 ** .                        \ => 81
7 0 ** .                        \ => 1
2 16 ** .                       \ => 0
```

The last line is the usual warning: 65536 does not fit in a cell, and
nothing says so.

**Growth at compound interest.** A sum at 5 per cent, year after year.

```
10 FOR y=0 TO 10 STEP 5
20   PRINT y,1000*1.05^y
30 NEXT y
```

```forth
FLOATING
: SAVINGS  ( years -- fp )  FLOAT 1.05 2SWAP F**  1000.0 F* ;
INTEGER
10 SAVINGS F>D D.               \ => 1628
```

The definition is compiled while floating-point numbers are switched on;
it can be used afterwards in either state. With integers, each year is
"times 105, divided by 100", which is what `*/` is for:

```forth
: YEARS  ( n years -- n2 )  0 ?DO  105 100 */  LOOP ;
1000 10 YEARS .                 \ => 1623
10000 10 YEARS .                \ => 16284
```

The exact answer is 1628.89. The first line loses up to a unit every
year, because each division drops its fraction, and after ten years it is
five units out. The second line starts from the same sum counted in
tenths: 1628.4. That is the general remedy. Carry more digits than you
mean to show, and the error stays in the digits you do not show.

**A circle.** Circumference and area for a given radius.

```
10 INPUT r
20 PRINT 2*PI*r,PI*r*r
```

```forth
FLOATING
: CIRC  ( fp -- fp2 )  2.0 F* PI F* ;
: AREA  ( fp -- fp2 )  2DUP F* PI F* ;
INTEGER
FLOATING 2.5 CIRC F. INTEGER    \ => 1.5708e1
FLOATING 2.5 AREA F. INTEGER    \ => 1.9635e1
```

With integers pi is a ratio. 355/113 is 3.1415929, right to six decimal
places, and both numbers fit comfortably in a cell:

```forth
: CIRC  ( r -- c )  2* 355 113 */ ;
: AREA  ( r -- a )  DUP * 355 113 */ ;
100 CIRC .                      \ => 628
10 AREA .                       \ => 314
100 AREA .                      \ => 31415
```

The radius can be in any unit: millimetres if you need tenths of a
centimetre.

**A square root with decimals.**

```
10 PRINT SQR 2
```

```forth
FLOATING
2.0 FSQRT F.                    \ => 1.4142e0
INTEGER
```

The integer root of 2 is 1. But the root of 2 000 000 is 1000 times the
root of 2, so scale first and read the result in thousandths. `DSQRT`
takes a double number:

```forth
NEEDS DSQRT
2000000. DSQRT .                \ => 1414
200000000. DSQRT .              \ => 14142
```

**A sine.** How high is the end of a 200-pixel line drawn at 30 degrees,
and at 60?

```
10 FOR a=30 TO 60 STEP 30
20   PRINT 200*SIN (a*PI/180)
30 NEXT a
```

```forth
FLOATING
: HEIGHT  ( degrees -- fp )  FLOAT DEG>RAD FSIN  200.0 F* ;
INTEGER
30 HEIGHT F>D D.                \ => 100
60 HEIGHT F>D D.                \ => 173
```

A program that draws does this thousands of times, and it never needs
more than a few hundred different angles. So the sines are worked out
once, on paper or by a BASIC program, multiplied by 10000 and put in a
table. This one goes from 0 to 90 degrees in steps of 10:

```forth
CREATE SINES
    0 , 1736 , 3420 , 5000 , 6428 ,
    7660 , 8660 , 9397 , 9848 , 10000 ,
: SIN10  ( tens-of-degrees -- sine*10000 )  CELLS SINES + @ ;
: COS10  ( tens-of-degrees -- cosine*10000 )  9 SWAP - SIN10 ;
3 SIN10 .                       \ => 5000
200 3 SIN10 10000 */ .          \ => 100
200 6 SIN10 10000 */ .          \ => 173
200 6 COS10 10000 */ .          \ => 100
```

`*/` multiplies by the sine and divides by its scale in one step. The
cosine comes from the same table, read from the other end. A finer table
is only a longer one; the other three quarters of the circle come from
this one by symmetry. Tutorial 065 draws a whole picture this way.

**Sines without a table.** When the angles come one after the other, as
along a curve, even the table can go. A point that turns round a circle
by a small step at a time has the sine as its height and the cosine as
its distance from the centre, and each step needs only two
multiplications. Here a step is 1/256 of a turn, and 201/8192 is that
angle in radians:

```forth
NEEDS VALUE
NEEDS TO
NEEDS +TO
0 VALUE SINE  0 VALUE COSINE
: START-WAVE  ( amplitude -- )  100 * TO COSINE  0 TO SINE ;
: TURN  ( -- )
    COSINE 201 8192 */ +TO SINE
    SINE 201 8192 */ NEGATE +TO COSINE ;
: TURNS  ( n -- )  0 ?DO  TURN  LOOP ;
80 START-WAVE  64 TURNS  SINE 100 / .   \ => 80
64 TURNS  SINE 100 / .          \ => 0
```

A quarter of the way round (64 steps) the height is the full 80, and
halfway it is back to 0. `SINE` and `COSINE` are kept 100 times larger
than the result so that the small steps do not vanish in the integer
division; `100 /` brings them back. The new `SINE` is used at once to
update `COSINE`: that order is what keeps the circle closed, turn after
turn. It is an old trick, known as Minsky's circle algorithm (HAKMEM,
item 149, 1972). The heights stay within two units of the real sine.
With the `PLOT` of [Chapter 16](16-graphics.md), a whole wave across
the screen is one loop:

<!-- no-test -->
```forth
: WAVE  ( -- )
    80 START-WAVE
    256 0 DO  87 SINE 100 / -  I PLOT  TURN  LOOP ;
```

## No equivalent

- **Floating point as the ordinary kind of number.** It is a library, a
  mode of the interpreter, and a set of words apart.
- **Automatic conversion** between integers and floating point.
- **Nine and a half digits.** About seven, in four bytes.
- **`PRINT` choosing the notation.** `F.` always prints mantissa and
  exponent.
- **An `=` for floating-point numbers.** There are `F<` and `F>`. Two
  results of different calculations are rarely equal to the last bit
  anyway: test whether their difference is small.
- **Fixed point as a part of the language.** vForth has it as another
  library, `NEEDS FIXED88`: numbers with 8 bits before the point and 8
  after, in one cell. Tutorial 064 explains the idea.

## Further reading

- Tutorial `024` -- the floating-point library, word by word.
- Tutorial `064` -- scaled integers: the Mandelbrot set without floating
  point.
- Tutorial `065` -- a fixed-point sine table at work.
- Tutorial `015` -- double numbers, which share the stack words and the
  variables of floating point.
- `HELP FLOATING`, `HELP */`, `HELP SQRT`, `HELP DSQRT`, `HELP 2VARIABLE`.
- vForth manual, section 3.9 "Floating-Point Option"; section 4.4 for
  how a floating-point number is stored in two cells.

<!-- nav -->
---

Previous: [Chapter 8 - Functions](08-functions.md) |
[Contents](README.md) |
Next: [Chapter 10 - Random Numbers](10-random-numbers.md)
