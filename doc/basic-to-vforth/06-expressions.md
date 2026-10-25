# Chapter 6 - Expressions

[From NextBASIC to vForth](README.md)

Manual: Chapter 6, pp. 37-48.

## In short

Every operation of this chapter is there, and almost none is written the
same way. The operator comes *after* its operands, so there is no order of
priority to remember and no parentheses to count. A number is a 16-bit
integer, the kind NextBASIC marks with a `%`, and it is signed unless you
say otherwise: the opposite of BASIC's choice. Bigger numbers take two cells
and are written with a dot. Floating point and scientific notation are a
library, not the default. The bitwise operators are words with names, and
three of BASIC's signs (`!`, `@`, `%`) mean something else here.

## What changes

**The operator comes last.** `2+3` is `2 3 +`. A number goes onto the stack;
a word like `+` takes its two operands from the top of the stack and leaves
the result there, ready for the next word. Nothing is worked out "later":
each word acts as soon as it is read.

```forth
2 3 + .                         \ => 5
10 3 - .                        \ => 7
20 4 / .                        \ => 5
```

The operands keep the order they have in BASIC: `10-3` is `10 3 -`, the
number you take away is the second one.

Everything in this chapter takes its arguments from the left, from the
stack. The words that also read something from the right, such as
`VARIABLE` and `TO`, are the ones that need a *name*: see "Left for the
value, right for the name" in
[Chapter 1](01-basic-programming-concepts.md).

**There is no priority and there are no parentheses.** In `2+3*4` BASIC
multiplies first, because `*` binds tighter than `+`. Forth has no such
rule: the order in which you write the words is the order in which they are
carried out, and that is all there is to know. What BASIC says with
parentheses you say by choosing where the operator goes.

```forth
2 3 4 * + .                     \ => 14
2 3 + 4 * .                     \ => 20
2 3 + 7 4 - * .                 \ => 15
```

These are `2+3*4`, `(2+3)*4` and `(2+3)*(7-4)`. In the third line the two
sums are simply worked out one after the other: both results wait on the
stack until `*` takes them.

To turn a BASIC expression into Forth, start from the innermost
parentheses, write the operands in the same order as in BASIC, and write
each operator as soon as both its operands are on the stack. NextBASIC's
own integer expressions already work from left to right without priority,
so if you write `%` expressions you are half way there.

**The parenthesis is taken.** `(` is a Forth word: it starts a comment that
ends at the next `)`. Typing a BASIC expression with its parentheses gives
no error, just the wrong answer:

```forth
2 ( 3 ) 4 + .                   \ => 6
```

The 3 was a comment.

**Using a value twice means copying it, not naming it.** `x*x` mentions `x`
twice. On the stack there is one copy of it, and `*` will use up two, so
you duplicate it: `DUP *`. `DUP`, `SWAP`, `OVER`, `ROT` and `DROP` are the
words that put the operands where the next operator wants them, and they
are what replaces most of the variable names of a BASIC formula.

```forth
7 DUP * .                       \ => 49
3 10 SWAP - .                   \ => 7
```

While you are learning, `.S` shows the stack without changing it:

```forth
NEEDS .S
1 2 3 .S                        \ => 1 2 3
+ + .                           \ => 6
```

**A number is a 16-bit integer.** BASIC's ordinary numbers are floating
point, and the fast 16-bit integers are the special case that needs a `%`.
Here it is the other way round: the integer is the normal case and has no
mark. So there are no fractions, and `/` drops the remainder.

```forth
7 2 / .                         \ => 3
-7 2 / .                        \ => -3
-7 2 MOD .                      \ => -1
17 5 /MOD . .                   \ => 3 2
```

Division rounds towards zero and the remainder has the sign of the number
being divided. `/MOD` does one division and leaves both results, the
quotient on top.

**Multiply first, then divide, and use `*/` to do it.** With no fractions,
`x/100*20` loses everything the first division throws away. The habit is
to multiply first. But the product may not fit in 16 bits, so Forth has a
word for exactly this: `*/` multiplies two numbers, keeps the product on 32
bits, and divides it by the third.

```forth
30000 20 100 */ .               \ => 6000
30000 20 * 100 / .              \ => 101
```

The second line is wrong for the same reason `PRINT %30000*20/100` is.
`*/` is how percentages, scale factors and fractions like 9/5 are written,
and it is the first answer to "but I need decimals".

**Nothing checks for overflow.** As in a `%` expression, a result that does
not fit in 16 bits is cut down to 16 bits without a word of warning.

```forth
32767 1+ .                      \ => -32768
1000 1000 * .                   \ => 16960
70000 .                         \ => 4464
```

The last line shows that even a number typed at the keyboard is cut. (`1+`
is a word, "add one"; so are `1-`, `2+`, `2*` and `2/`.)

**Signed is the default, and the word decides.** NextBASIC's integers are
unsigned, from 0 to 65535, and `SGN {...}` asks for the signed reading.
Forth starts from the other end: `.`, `<`, `/` and `MOD` read a cell as a
number from -32768 to 32767. But a cell has no type, so nothing has to be
converted to get the unsigned reading: you use the unsigned word.

```forth
-32448 U.                       \ => 33088
33088 .                         \ => -32448
-64448 U.                       \ => 1088
```

`U.` prints unsigned. `+`, `-` and `*` give the same sixteen bits whichever
way you read them, so they have no unsigned twin. Comparison and division
do: `U<` compares unsigned, and `UM/MOD` divides an unsigned number (a
double one, hence the extra 0) by an unsigned one.

```forth
0 1 - 0> .                      \ => 0
0 0 1 - U< .                    \ => -1
50000 2 / .                     \ => -7768
50000 0 2 UM/MOD NIP .          \ => 25000
```

The first two lines ask "is 0-1 greater than 0?": no if it is -1, yes if it
is 65535. The trap for a BASIC programmer is the third: a number above
32767 is negative for `/`.

**Dividing by zero is not an error.** NextBASIC stops with `Number too
big`. vForth says nothing and leaves a meaningless result. If the divisor
can be zero, test it first.

```forth
1 0 / .                         \ => -1
```

**A dot makes a number twice as long.** This one has to be learnt early.
A number with a dot in it is not a fraction: it is a *double* integer, 32
bits in two cells, and the dot may be anywhere. `3.5` is the double number
35.

```forth
3.5 .                           \ => 0
.                               \ => 35
3.5 D.                          \ => 35
```

`.` printed only the top cell, the high half, and left the other one on the
stack for the second `.` to find. The words for doubles start with `D` or
have an `M` (mixed) in them: `D.` prints one, `D+` adds two, `M*`
multiplies two single numbers into a double, `S>D` turns a single into a
double. That is where the numbers BASIC holds exactly, up to 2^32-1, go.

```forth
70000. D.                       \ => 70000
100000. 250000. D+ D.           \ => 350000
30000 30000 M* D.               \ => 900000000
-5 S>D D.                       \ => -5
```

**The dot is not even special.** Four other marks do the same job: `,`,
`/`, `-` and `:`. There may be more than one, anywhere after the first
digit, and each says only "this is a double". Where the last one stands is
kept in `DPL`, the count of the digits after it, and the number itself
forgets it. A thousands separator, a date, a time all read as one double
integer:

```forth
1,000,000 D.                    \ => 1000000
2026-10-16 D.                   \ => 20261016
12:30 D.                        \ => 1230
1.2.3 D.                        \ => 123
```

So `3.5` is not three and a half written badly: nothing in the language
reads it as a fraction. Out of the box vForth has no floating-point
numbers at all, only integers one or two cells long.

**Floating point is a library.** `NEEDS FLOATING` loads it and the word
`FLOATING` switches it on: from then on a number with a dot is a floating
point number, and `F+`, `F-`, `F*`, `F/` and `F.` work on it. The word
`INTEGER` switches back. Until you do that there is no scientific notation
either:

```forth
1E3                             \ => 1E3? is undefined.
```

Loading the library is not enough: it is the word `FLOATING` that turns
the dot into a decimal point. After `NEEDS FLOATING` the user variable
`NMODE` is still 0, and every number is read as before, so `2.5` is still
the double 25 and `1E3` is still undefined. `FLOATING` sets `NMODE` to 1,
`INTEGER` back to 0. Once it is on, only the dot is a decimal point: the
other four marks are an error, and so is a second dot. An exponent may
follow, with or without the dot before it.

```forth
NEEDS FLOATING
2.5 D.                          \ => 25
FLOATING
2.5 F.                          \ => 2.5000e0
1E3 F.                          \ => 1.0000e3
1.E3 F.                         \ => 1.0000e3
1,5 F.                          \ => 1,5? is undefined.
INTEGER
```

Conversions are never automatic: there is no casting, and `INT {...}`
becomes an explicit word. Chapter 9 deals with the library. Before reaching
for it, see whether `*/` and a scaled integer (cents instead of pounds,
tenths of a degree) will do: on this machine they are much faster, and
exact.

**True is -1.** A BASIC comparison gives 1 for true; a Forth one gives -1,
all sixteen bits set (see [Chapter 2](02-decisions.md)). If you do
arithmetic with the result of a comparison, as BASIC programs often do,
turn it into 1 with `NEGATE` or with `1 AND`.

```forth
3 4 < .                         \ => -1
3 4 < NEGATE .                  \ => 1
```

**`AND` and `OR` are the bitwise ones.** BASIC has two families: `&`, `|`
and `^|` work on bits, `AND`, `OR` and `NOT` on truth values. Forth has
one, and it is the bitwise one, with the names of the other: `AND`, `OR`,
`XOR`. On the flags that comparisons leave (-1 and 0) the bitwise result is
also the logical one, which is why -1 was chosen. On other numbers it is
not:

```forth
3 4 < 5 6 < AND .               \ => -1
1 2 AND .                       \ => 0
```

1 and 2 are both "true" for `IF`, yet they have no bit in common. When a
number, not a comparison, stands for a condition, make it a proper flag
first with `0= 0=`. Logical `NOT` is `NOT`, which is the same word as
`0=`; the bitwise one, BASIC's `!`, is `INVERT`. More in Chapter 12.

**`OR` is safe, `AND` is the one to watch.** On any two numbers the
result of `OR` is zero only when both are zero, so it already works as a
logical OR for `IF`. `AND` is the one that needs flags. The BASIC habit
of `*` for AND and `+` for OR does not carry over: cells are 16 bits and
true is -1, so the product of two flags is 1, not a flag, and the trick
fails on ordinary numbers:

```forth
1 2 OR .                        \ => 3
-1 -1 * .                       \ => 1
256 256 * .                     \ => 0
1 -1 + .                        \ => 0
```

256 and 256 are both true, and so are 1 and -1, yet each pair gives 0.
De Morgan's laws offer a cheaper way to a logical AND than turning both
numbers into flags: "a and b" is "not (not a or not b)", and `0=` is
"not". On the stack that reads `0= SWAP 0= OR 0=`:

```forth
1 2  0= SWAP 0= OR 0= .         \ => -1
0 2  0= SWAP 0= OR 0= .         \ => 0
```

The other law, "not (a and b)" is "not a or not b", turns a condition
the other way round when that reads better.

**The signs have other jobs.** Three characters of this chapter are Forth
words that do something else, and none of them complains when misused:

- `!` is not bitwise NOT. It stores a number at an address (`10 A !`).
- `@` does not introduce a binary number. It fetches a number from an
  address. The binary prefix is `%`.
- `%` does not mark an integer expression: every expression is one.

**The bitwise operators are words.** `<<` is `LSHIFT`, `>>` is `RSHIFT`,
`!` is `INVERT` (`NEEDS INVERT`). They take their operands from the stack
like everything else.

```forth
NEEDS INVERT
1201 3 RSHIFT .                 \ => 150
150 3 LSHIFT .                  \ => 1200
%10101010 %01101011 OR .        \ => 235
%10101010 %01101011 XOR .       \ => 193
%11100011 %10 AND .             \ => 2
15 INVERT U.                    \ => 65520
```

`RSHIFT` fills with zeros from the left. `2/` shifts one place and keeps
the sign bit, so it halves negative numbers too:

```forth
-8 2/ .                         \ => -4
-8 1 RSHIFT .                   \ => 32764
```

There are no fractional bits behind a number, so what is shifted out is
gone, as in a `%` expression. The two's complement of a number is `NEGATE`,
which is the same as `INVERT 1+`.

**The number base is a setting, and it works both ways.** A `$` in front
makes one number hexadecimal and a `%` makes it binary, wherever it is
written. `HEX` changes the base itself: from then on every number you type
*and every number printed* is hexadecimal, until `DECIMAL`. `BINARY`
(`NEEDS BINARY`) does the same for base 2.

```forth
$E3 .                           \ => 227
255 HEX . DECIMAL               \ => FF
NEEDS BINARY
5 BINARY . DECIMAL              \ => 101
```

Forgetting the `DECIMAL` is a classic: the machine seems to have forgotten
how to count. Literals have no fractional part in any base.

**A name can be almost anything.** A BASIC name is letters and digits and
starts with a letter; an integer variable is one letter. A Forth name is
any run of characters without a space: digits first, hyphens, asterisks,
question marks. No name is reserved, there are no keywords, and capitals
and small letters are the same. vForth even looks a word up in the
dictionary *before* trying to read it as a number:

```forth
VARIABLE HI-SCORE
9000 hi-score !
HI-SCORE ?                      \ => 9000
: 42  ." the answer" ;
42                              \ => the answer
FORGET 42
42 .                            \ => 42
```

Nobody defines `42`, but `1+`, `2*` and `0=` are ordinary words named this
way, and that is why the space between `1` and `+` matters: `1 +` is two
words, `1+` is one.

**A quote inside a text.** `."` ends at the first `"`, and doubling it does
not help. Print the character by its code, 34:

```forth
: SAY  ." She said " 34 EMIT ." hi" 34 EMIT ;
SAY                             \ => She said "hi"
```

## Correspondence table

| NextBASIC | vForth | Note |
|---|---|---|
| `a+b` `a-b` `a*b` `a/b` | `a b +` `a b -` `a b *` `a b /` | 16-bit integers. `/` rounds towards zero. |
| `a MOD b` | `a b MOD` | The sign is that of `a`. |
| quotient and remainder | `a b /MOD` | Remainder below, quotient on top. |
| `a+b*c` | `a b c * +` | No priority: the order written is the order done. |
| `(a+b)*c` | `a b + c *` | No parentheses: `(` starts a comment. |
| `(a+b)*(c-d)` | `a b + c d - *` | |
| `x*x` | `x DUP *` | |
| `a*b/c` | `a b c */` | The product is kept on 32 bits. |
| `-a` | `a NEGATE` | A literal is typed with its sign: `-5`. |
| `a+1` `a-1` `a*2` `a/2` | `a 1+` `a 1-` `a 2*` `a 2/` | One word each, and faster. |
| `%` integer expression | any expression | Integers are the normal case. |
| floating-point expression | `F+` `F-` `F*` `F/` | `NEEDS FLOATING`, then `FLOATING`. Chapter 9. |
| `2.34e2` | -- | Only with the floating-point library. |
| `!a` | `a INVERT` | `NEEDS INVERT`. `!` is "store". |
| `a<<n` `a>>n` | `a n LSHIFT` `a n RSHIFT` | By one place: `2*`, `2/` (`2/` keeps the sign). |
| `a&b` `a\|b` `a^\|b` | `a b AND` `a b OR` `a b XOR` | |
| `a AND b`, `a OR b` | `a b AND`, `a b OR` | The same words: bitwise, logical only on -1 and 0. |
| `a AND b` on any numbers | `a b 0= SWAP 0= OR 0=` | De Morgan; `OR` needs no help. |
| `NOT a` | `a NOT` or `a 0=` | Logical: zero gives -1, anything else 0. |
| true = 1 | true = -1 | `NEGATE` or `1 AND` to get 1. |
| `$E3` | `$E3` | Or `HEX E3 DECIMAL`. |
| `@11100011`, `BIN 11100011` | `%11100011` | Or `BINARY` ... `DECIMAL`, with `NEEDS BINARY`. `@` is "fetch". |
| integers up to 4294967295 | double numbers: `70000.` | `D+`, `D.`, `M*`, `S>D`, `DNEGATE`. Tutorial 015. |
| `SGN {...}` (signed) | the default | `.` `<` `/` `MOD` are signed. |
| unsigned (BASIC's default) | `U.` `U<` `UM*` `UM/MOD` | `+` `-` `*` serve both. |
| two's complement | `NEGATE` | By hand: `INVERT 1+`. |
| `INT {...}` and casting | explicit words | `S>D` single to double; `F>D`, `D>F` with the library. |
| `%a+=n` | `n A +!` | For a `VARIABLE`. |
| `%a>>=n` and the like | `A @ n RSHIFT A !` | Fetch, work, store. |
| `""` inside a string | `34 EMIT` | |
| division by zero: `Number too big` | no error | Test the divisor. |

## Side by side

**A formula.** Celsius to Fahrenheit.

```
10 INPUT "Celsius? ";c
20 PRINT c*9/5+32
```

```forth
: C>F  ( celsius -- fahrenheit )  9 5 */ 32 + ;
100 C>F .                       \ => 212
-40 C>F .                       \ => -40
37 C>F .                        \ => 98
```

The formula became a word that takes its number from the stack, so it can
be tried on three values at once, and used inside other words. `9 5 */` is
"times nine fifths". BASIC answers 98.6 for 37 degrees; the integer version
drops the fraction. To keep one decimal, work in tenths of a degree and put
the point in only when printing:

```forth
: C>F10  ( celsius -- tenths )  90 5 */ 320 + ;
: .TENTHS  ( n -- )  0 <# # 46 HOLD #S #> TYPE ;
37 C>F10 .                      \ => 986
37 C>F10 .TENTHS                \ => 98.6
100 C>F10 .TENTHS               \ => 212.0
```

`<#` ... `#>` builds the text of a number digit by digit, from the right:
`#` produces one digit, `46 HOLD` puts in a dot, `#S` produces the rest. It
is the subject of tutorial 014; this version is for numbers that are not
negative.

**Parentheses.** Two sums, then their product.

```
10 LET a=2: LET b=3: LET c=7: LET d=4
20 PRINT (a+b)*(c-d)
```

With the numbers typed in the order of the formula there is nothing to
move:

```forth
2 3 + 7 4 - * .                 \ => 15
```

As a word, the four numbers arrive all together and the first sum has to
wait under the second:

```forth
: F  ( a b c d -- n )  -  -ROT  +  * ;
2 3 7 4 F .                     \ => 15
```

`-` works out `c-d`; `-ROT` tucks it under `a` and `b`; `+` adds them; `*`
finishes. When a word needs more shuffling than this, it is a sign that it
should be split in two.

**Packing bits.** The four fields of a colour attribute in one byte: ink in
bits 0 to 2, paper in bits 3 to 5, bright in bit 6, flash in bit 7.

```
10 %i=7: %p=1: %b=1: %f=0
20 PRINT %(f<<7)|(b<<6)|(p<<3)|i
```

```forth
: ATTR  ( ink paper bright flash -- attr )
    7 LSHIFT  SWAP 6 LSHIFT OR
    SWAP 3 LSHIFT OR  OR ;
7 1 1 0 ATTR .                  \ => 79
```

And back again, with masks:

```forth
: INK@    ( attr -- ink )    7 AND ;
: PAPER@  ( attr -- paper )  3 RSHIFT 7 AND ;
: BIT?    ( n bit -- flag )  1 SWAP LSHIFT AND 0= 0= ;
79 INK@ .                       \ => 7
79 PAPER@ .                     \ => 1
79 6 BIT? .                     \ => -1
79 7 BIT? .                     \ => 0
```

`BIT?` builds the mask by shifting a 1 into place, and `0= 0=` turns "some
bit left" into a proper flag. To set a bit use `OR` with the mask, to clear
it `AND` with the mask inverted, to flip it `XOR`.

**Signed and unsigned.** Half of 50000.

```
10 %a=50000
20 PRINT %a/2
30 PRINT % SGN {a/2}
```

```forth
50000 0 2 UM/MOD NIP .          \ => 25000
50000 2 / .                     \ => -7768
```

The same two answers, with the defaults exchanged: BASIC needs `SGN {...}`
to get the signed one, Forth needs the unsigned word to get the other.

**A number that does not fit.** The seconds in a day.

```
10 PRINT 24*60*60
```

```forth
24 60 * 60 * .                  \ => 20864
24 60 * 60 M* D.                \ => 86400
```

The minutes in a day, 1440, fit in a cell; the seconds do not. `M*`
multiplies two single numbers and leaves a double one, and `D.` prints it.
Nothing warned about the first line: knowing how big a result can get is
the programmer's job.

## No equivalent

- **Priority and parentheses.** There is nothing to replace them with and
  nothing to miss: the order of the words is the order of the work.
- **Floating point as the default, and scientific notation.** A library,
  loaded on purpose: see Chapter 9.
- **Fractional binary and hexadecimal literals**, such as `$64.c`. In
  Forth a dot makes the number a double integer.
- **Automatic conversion between kinds of number.** A single cell, a double
  number and a floating-point number are told apart only by the words you
  use on them, and every conversion is a word you write.
- **An error for division by zero or overflow.** Test before dividing;
  use doubles or `*/` where a product may be large.
- **An unsigned `/` on single numbers.** `UM/MOD` takes a double dividend:
  put a 0 on top of a single one, as in the example above.
- **`<=`, `>=`.** See [Chapter 2](02-decisions.md): `> 0=` and `< 0=`.
- **Operator-assignments other than `+=`.** `+!` adds to a variable; for
  the others fetch, work and store.
- **Strings in expressions.** Joining and comparing strings is the subject
  of Chapter 7.

## Further reading

- Tutorial `001` -- the stack, the four operations, `.`.
- Tutorial `002` -- `DUP`, `SWAP`, `OVER`, `ROT` and the other stack words.
- Tutorial `004` -- number bases: `HEX`, `DECIMAL`, `BASE`, the prefixes.
- Tutorial `011` -- `AND`, `OR`, `XOR`, `INVERT`, the shifts, masks.
- Tutorial `015` -- double numbers and the mixed words `M*`, `UM/MOD`.
- Tutorial `014` -- `<#` `#` `#S` `HOLD` `#>`: printing a number your way.
- Tutorial `064` -- scaled integers at work, without floating point.
- Tutorial `024` -- the floating-point library.
- `HELP */`, `HELP /MOD`, `HELP MOD`, `HELP U.`, `HELP INVERT`,
  `HELP LSHIFT`, `HELP RSHIFT`, `HELP 2/`, `HELP NEGATE`, `HELP M*`,
  `HELP UM/MOD`, `HELP S>D`, `HELP D.`, `HELP HEX`, `HELP BINARY`,
  `HELP BASE`, `HELP DPL`.
- vForth manual, sections 2.12.5 "Integer Arithmetics" and 2.12.11
  "Numbers & strings"; sections 4.2 and 4.3 for how single and double
  numbers are stored; section 3.9 "Floating-Point Option".

<!-- nav -->
---

Previous: [Chapter 5 - READ, DATA, RESTORE](05-read-data-restore.md) |
[Contents](README.md) |
Next: [Chapter 7 - Strings](07-strings.md)
