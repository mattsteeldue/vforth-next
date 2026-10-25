# Appendix D - The Calculator

[From NextBASIC to vForth](README.md)

Manual: Appendix D, pp. 303-305.

## In short

NextBASIC has a calculator as an option of the startup menu. vForth
needs none: its prompt is a calculator already, the one that works in
reverse Polish notation, the numbers first and the operation after them.
The running total of the manual is the stack, which keeps the result of
a line for the next one. Variables and functions are the ones of the
language, defined at the same prompt. What changes is the arithmetic:
whole numbers of 16 bits unless you ask for more, and floating point
only through a library.

## What changes

**The prompt is the calculator.** There is no option to choose and
nothing to leave: type a line, press ENTER, and it is carried out. `6+4`
is `6 4 +`, and `.` prints the result and takes it away.

```forth
6 4 + .                         \ => 10
```

**The running total is the stack.** Without the `.`, the result stays
on the stack, and the next line goes on from there: `/5` becomes `5 /`.
`.S` (`NEEDS .S`) shows what is on the stack without taking it away.

```forth
NEEDS .S
6 4 +
.S                              \ => 10
5 / .                           \ => 2
```

A new calculation is simply a new number: there is no need to clear the
total first. What is left on the stack does no harm, and `.` takes the
top one, the last result.

**Whole numbers, 16 bits.** `/` divides and drops the remainder, so it
does the job of `INT` too; `MOD` gives the remainder and `/MOD` both. A
result above 32767 does not fit in a signed cell and comes out
negative, without an error; `U.` prints it unsigned, up to 65535.
[Chapter 6](06-expressions.md) is about the integers.

```forth
97 10 / .                       \ => 9
97 10 MOD .                     \ => 7
200 200 * .                     \ => -25536
40000 U.                        \ => 40000
```

**`PI` with integers is a ratio.** 355/113 is right to six decimals, and
`*/` multiplies before it divides, with a 32-bit result in between, so
nothing is lost. Scale the numbers to keep the decimals you want:

```forth
2 355 113 */ .                  \ => 6
20000 355 113 */ U.             \ => 62831
```

The second line is 2 times pi in units of 1/10000: 6.2831.

**Big numbers are doubles.** `1E6` does not fit in 16 bits. A number
with a dot is a double integer, 32 bits, printed with `D.`:

```forth
1000000. D.                     \ => 1000000
1000000. 250000. D+ D.          \ => 1250000
```

**Decimals and functions need the library.** `NEEDS FLOATING` loads the
floating-point words, which use the ROM's own calculator, and
`FLOATING` switches the reading of `1.5` and `1E6` on
([Chapter 9](09-mathematical-functions.md)). The manual's example, 10
divided by 5, then times `PI`, then times `ATN 60`:

```forth
NEEDS FLOATING
FLOATING
10.0 5.0 F/  PI F*  60.0 FATAN F*  F.
1E6 F.
INTEGER
```

Each operation has its own word, `F/`, `F*`, `FATAN`, and `F.` prints in
scientific notation.

**`LET` is a `VALUE`.** `LET x=10` is `10 VALUE X`; afterwards the
name gives the number, and `TO X` (`NEEDS TO`) changes it. `x+90` and
then `+x*x` on the running total:

```forth
NEEDS VALUE
NEEDS TO
10 VALUE X
X 90 + .                        \ => 100
X 90 +  X X * + .               \ => 200
20 TO X  X .                    \ => 20
```

Names are not case sensitive, and a name already in use as a word is
redefined, with a warning: choose names that do not clash with the
words you need, as the manual says of BASIC's keywords.

**`DEF FN` is a definition.** `DEF FN c(n)=n*n*n` is a word that takes
its argument from the stack:

```forth
: CUBE  ( n -- n^3 )  DUP DUP * * ;
3 CUBE .                        \ => 27
X CUBE .                        \ => 8000
```

Words defined while working on a program can be used at the prompt as
soon as they exist, and the other way round: the calculator and the
program are one dictionary.

**A base for every number.** The prompt also converts between bases, a
job the BASIC calculator does not do: `HEX` and `DECIMAL` change the base
in which numbers are read and printed, `$` and `%` mark a single number.

```forth
$FF .                           \ => 255
255 HEX . DECIMAL               \ => FF
%1010 .                         \ => 10
```

## Correspondence table

| NextBASIC | vForth | Note |
|---|---|---|
| Calculator option of the menu | -- | The prompt is the calculator. |
| `6+4` | `6 4 + .` | Numbers first. |
| the running total | the stack | `.S` shows it, `.` takes it. |
| `/5` on the total | `5 /` | Whole numbers. |
| `INT x` | `/`, `MOD`, `/MOD` | Division drops the fraction. |
| `*PI` | `355 113 */` | Or `PI F*` with `NEEDS FLOATING`. |
| `*ATN 60` | `60.0 FATAN F*` | `NEEDS FLOATING`, then `FLOATING`. |
| `1E6` | `1000000.` and `D.` | A double; `1E6` with `FLOATING`. |
| `LET x=10` | `10 VALUE X` | `NEEDS VALUE`; `TO X` changes it, `NEEDS TO`. |
| `x+90` | `X 90 +` | |
| `DEF FN c(n)=n*n*n` | `: CUBE DUP DUP * * ;` | |
| `FN c(3)` | `3 CUBE` | |
| ENTER alone, a new calculation | -- | A new number starts one. |
| Exit, EDIT | -- | Nothing to leave. |

## No equivalent

- **Editing a line on the screen.** The prompt edits only the line being
  typed, with DELETE; a line already carried out is typed again.
- **Results with decimals by default.** Every number is a whole number
  until `FLOATING` says otherwise; the floating-point words are slower
  and the stack holds a decimal number in two cells.
- **The options menu** (speed, the `32/64/85` display, Exit). The speed
  is a word, `n SPEED!` (`NEEDS SPEED!`,
  [Chapter 22](22-in-out-and-the-next-registers.md)).

## Further reading

- Tutorial `001` -- the stack, arithmetic and `.`: the calculator.
- Tutorial `004` -- number bases, `HEX`, `DECIMAL`, `BASE`.
- Tutorial `015` -- double numbers.
- Tutorial `024` -- floating point.
- `HELP .S`, `HELP */`, `HELP /MOD`, `HELP U.`, `HELP D.`, `HELP VALUE`.
- [Chapter 6](06-expressions.md) -- expressions in reverse Polish
  notation, integers and doubles.
- [Chapter 9](09-mathematical-functions.md) -- the floating-point
  library and its functions.

<!-- nav -->
---

Previous: [Appendix C - Machine Personalities](app-c-machine-personalities.md) |
[Contents](README.md) |
Next: [Keyword index](keyword-index.md)
