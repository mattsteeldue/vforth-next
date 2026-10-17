# Chapter 8 - Functions

[From NextBASIC to vForth](README.md)

Manual: Chapter 8, pp. 52-59.

## In short

A BASIC function takes arguments and gives back a result. That is what
every Forth word does: it takes numbers from the stack and leaves numbers
there. So Forth has no functions as a separate thing, and nothing to
learn in order to write one: `DEF FN` is the `:` you already know. The
built-in functions fare differently. `ABS` is there. `SGN` is one line.
`LEN` vanishes, because the length of a string is already on the stack.
`STR$` and `VAL` exist as mechanisms rather than as words: the pictured
numeric output that makes a string from a number, and `>NUMBER` and
`EVALUATE` for the way back. `IN`, the search inside a string, has to be
written.

## What changes

**A function is a word, and the argument comes first.** `FN s(3)` is
`3 SQ`: the argument is on the stack before the word runs, there are no
parentheses, and the result stays on the stack, where `.` or the next
word finds it.

```forth
: SQ  ( x -- y )  DUP * ;
3 SQ .                          \ => 9
```

**Functions have no priority, and composing them is writing them in a
row.** BASIC works out the functions of an expression before the
operators, unless parentheses say otherwise. In Forth a function is a
word like `+` is a word: each acts when it is reached.

```forth
2 SQ SQ .                       \ => 16
3 4 + SQ .                      \ => 49
3 SQ 4 + .                      \ => 13
```

The first line is `FN s(FN s(2))`, read from the inside out in BASIC and
from left to right in Forth. The other two are `FN s(3+4)` and
`FN s(3)+4`: the place of `SQ` says which one you mean.

**The name says nothing about the result.** In BASIC a function that
gives a string ends in `$`. A Forth word leaves whatever it leaves, one
number, a string (that is, two numbers), or several things at once, and
the only record of it is the stack comment. This chapter keeps the `$` in
a few names so that they can be compared with BASIC's.

**`DEF FN` is `:`, with fewer rules.** A `DEF FN` must be a line of the
program and cannot be typed as a command; its body is one expression. A
colon definition can be typed at the prompt and tried at once; it can be
as long as it needs, with `IF` and loops inside; it can take any number of
arguments and leave any number of results. One rule goes the other way: a
`DEF FN` may be anywhere in the listing, while a word must be defined
before the words that use it.

```forth
: MEAN  ( a b -- m )  + 2 / ;
4 10 MEAN .                     \ => 7
```

**No argument, no parentheses.** A BASIC function without arguments
still needs its `()`. A Forth word that takes nothing is written by
itself. And since Forth has no types of word, such a "function" is no
different from a constant or from a word that reads a variable.

**Arguments have no names, so they hide nothing.** In `DEF FN p(x,y)` the
names `x` and `y` cover, for the length of the call, any variables called
`x` and `y`. On the stack an argument is a value without a name: it
cannot be confused with a variable, and a word reads a variable only when
it says so with `@`. If you want named arguments, they are the locals of
[Chapter 4](04-procedures-and-subroutines.md).

**A recursive function says `RECURSE`.** As in Chapter 4: the name of a
word is not yet usable inside its own definition, so the word calls
itself with `RECURSE` (`NEEDS RECURSE`).

```forth
NEEDS RECURSE
: FACT  ( n -- n! )
    DUP 2 < IF  DROP 1  ELSE  DUP 1- RECURSE *  THEN ;
5 FACT .                        \ => 120
7 FACT .                        \ => 5040
8 FACT .                        \ => -25216
8 FACT U.                       \ => 40320
```

The last two lines are a reminder from [Chapter 6](06-expressions.md):
8! is 40320, which fits in a cell only if read as unsigned, and 9! does
not fit at all. Nothing warns you.

**`LEN` is not needed.** A string on the stack is its address and its
length. The length of a counted string in a buffer is its first byte:
`A$ C@`. See [Chapter 7](07-strings.md).

**`ABS` is there, `SGN` is one line.** A comparison leaves -1 for true,
so "is it positive" minus "is it negative", the wrong way round, gives
the sign:

```forth
-7 ABS .                        \ => 7
: SGN  ( n -- -1|0|1 )  DUP 0< SWAP 0> - ;
-7 SGN .                        \ => -1
0 SGN .                         \ => 0
9 SGN .                         \ => 1
```

**`INT` has nothing to do, but watch the negatives.** An integer has no
fraction to throw away. The place where `INT` shows up in a BASIC program
is after a division, and there the two languages differ: `INT` rounds
down, `/` rounds towards zero. `INT (-7/2)` is -4; `-7 2 /` is -3. For
the result BASIC gives, use `FM/MOD`, the division that rounds down. It
wants a double number to divide, hence `S>D`:

```forth
-7 2 / .                        \ => -3
-7 S>D 2 FM/MOD . .             \ => -4 1
```

It leaves the quotient on top and the remainder under it. For positive
numbers there is no difference.

**To round to the nearest, add half the divisor first.** BASIC writes
`INT (x+0.5)`. With integers there is no 0.5 to add after the division,
so half of the divisor is added before it:

```forth
: ROUND/  ( n d -- q )  DUP 2/ ROT + SWAP / ;
29 10 ROUND/ .                  \ => 3
24 10 ROUND/ .                  \ => 2
```

This is for numbers that are not negative.

**`SQR` is `SQRT`, and the root is a whole number.** `NEEDS SQRT` gives
the integer square root, rounded down, of a number from 0 to 65535.
A negative argument is no error: it is read as unsigned.

```forth
NEEDS SQRT
16 SQRT .                       \ => 4
17 SQRT .                       \ => 4
10000 SQRT .                    \ => 100
```

For more digits, take the root of the number multiplied by 100 or by
10000 as a double number, with `DSQRT`; for the real thing there is the
floating-point library of Chapter 9.

**`STR$` is the pictured output.** `.` prints a number and leaves nothing
behind. To have the digits as a string, build them with `<#` ... `#>`,
which leaves the address and length of the text instead of printing it.
The words between work on a double number and produce the digits from
the right: `#S` all of them, `SIGN` a minus if the number given to it is
negative.

```forth
: STR$  ( n -- a u )  DUP ABS 0 <# #S ROT SIGN #> ;
-123 STR$ TYPE                  \ => -123
100 STR$ NIP .                  \ => 3
```

**The string of `STR$` does not last.** The digits are built in a small
work area that every number conversion uses, `.` included. Use the
string, or copy it, before the next number is converted:

```forth
12 STR$ 34 STR$ TYPE TYPE       \ => 3434
```

Two different pairs, the same bytes.

**Another base is a change of `BASE`.** `STR$ (x,16)` needs no second
mechanism: the number base is a variable, `BASE`, and the digits come out
in whatever base it holds. The word below sets it, converts, and puts it
back.

```forth
: BASE$  ( u base -- a u )
    BASE @ >R  BASE !  0 <# #S #>  R> BASE ! ;
100 16 BASE$ TYPE               \ => 64
3 2 BASE$ TYPE                  \ => 11
35 36 BASE$ TYPE                \ => Z
```

To print rather than to keep, `HEX .` and then `DECIMAL` do the same.
There are no fractional places.

**`VAL` is two different things.** BASIC's `VAL` reads the digits of a
number, and it also works out any expression written in the string. In
Forth these are separate. Reading digits is `>NUMBER` (`NEEDS >NUMBER`):
it takes a double number to start from and a string, adds the digits it
finds, and stops at the first character that is not a digit, leaving the
number and what is left of the string.

```forth
NEEDS S"
NEEDS >NUMBER
: VAL  ( a u -- n )  0 0 2SWAP >NUMBER 2DROP DROP ;
: T1  S" 1984" VAL 16 + . ;
T1                              \ => 2000
: T2  S" 12AB" VAL . ;
T2                              \ => 12
: T3  S" -5" VAL . ;
T3                              \ => 0
```

This `VAL` keeps the single-cell number and drops the rest. `12AB` gives
12, with no error; `-5` gives 0, because a minus sign is not a digit.
A version for signed numbers has to look at the first character itself.

**Working out a string is `EVALUATE`.** `EVALUATE` (`NEEDS EVALUATE`)
takes a string and carries it out as if it had been typed. The text is
Forth, so it is postfix, and it understands a sign:

```forth
NEEDS EVALUATE
S" 2 3 *" EVALUATE .            \ => 6
S" -5 3 SQ +" EVALUATE .        \ => 4
```

It is more than `VAL` and `VAL$` together: the text may use any word,
leave any number of results, print, or define new words.

```forth
S" : TWICE  2 * ;" EVALUATE
5 TWICE .                       \ => 10
```

A text that is not good Forth stops with the usual error, as it would
from the keyboard. And since a Forth text has no quotes around its
numbers, the doubled and quadrupled quotes of `VAL$` are not needed.

**`IN` has to be written, and the name is taken.** vForth has no word
that searches a string. Looking for one character is a short loop, shown
in "Side by side"; looking for a substring, backwards, or with a wildcard
are longer ones. The other `IN` of BASIC, the one that reads a port, is
`P@`: [Chapter 22](22-in-out-and-the-next-registers.md).

**The integer functions are the ordinary ones.** NextBASIC has fast
integer forms of some functions, marked with `%`. In Forth those are the
only forms there are: `%ABS` is `ABS`, `%PEEK` is `C@`, `%DPEEK` is `@`,
`%REG` is `REG@`, `%IN` is `P@`, `%RND n` is `n RND` (`NEEDS RND`), and
`BIN` is the `%` prefix. Each is dealt with in its own chapter.

```forth
7 REG@ %00000011 AND .
```

That is `PRINT %REG 7 & BIN 00000011`, the speed of the processor from 0
to 3.

## Correspondence table

| NextBASIC | vForth | Note |
|---|---|---|
| `DEF FN f(x)=e` | `: F  ( x -- y )  e ;` | Works at the prompt. Define before use. |
| `FN f(x)` | `x F` | No parentheses. |
| `FN f(FN g(x))` | `x G F` | In the order they are carried out. |
| `DEF FN f(x,y)=e` | `: F  ( x y -- n )  e ;` | Any number of arguments, and of results. |
| `DEF FN f()=e`, `FN f()` | `: F  ( -- n )  e ;`, `F` | |
| arguments local to the function | values on the stack | No names, nothing to hide. |
| recursive `DEF FN` | `RECURSE` | `NEEDS RECURSE`. |
| `DEF FN f(REF a())` | pass the address | Chapter 4. |
| `LEN a$` | `A$ C@`; of a pair, the top number | |
| `STR$ x` | `<# #S #>` on a double number | `STR$` is defined here. The result does not last. |
| `STR$ (x,base)` | the same, with `BASE` changed | `BASE$` is defined here. |
| `STR$ (x,base,places)` | -- | No fractional places. |
| `VAL a$` (a number) | `0 0 a u >NUMBER` | `NEEDS >NUMBER`. Stops at the first non-digit. |
| `VAL a$` (an expression) | `a u EVALUATE` | `NEEDS EVALUATE`. The text is Forth. |
| `VAL$ a$` | `a u EVALUATE` | |
| `IN (s$,m$)` | -- | `POS`, below, finds one character. |
| `SGN x` | `DUP 0< SWAP 0> -` | `SGN` is defined here. |
| `ABS x` | `ABS` | |
| `INT x` | nothing | Integers only. |
| `INT (a/b)` | `a b /` | For negative results: `a S>D b FM/MOD NIP`. |
| `INT (x+0.5)` | add half the divisor before dividing | `ROUND/` is defined here. |
| `SQR x` | `x SQRT` | `NEEDS SQRT`. Integer root, rounded down. |
| `%ABS`, `%PEEK`, `%DPEEK` | `ABS`, `C@`, `@` | The ordinary words. |
| `%REG n`, `%IN n` | `n REG@`, `n P@` | [Chapter 22](22-in-out-and-the-next-registers.md). |
| `%RND n` | `n RND` | `NEEDS RND`. Chapter 10. |
| `BIN 1010` | `%1010` | |
| `USR`, `USR$` | -- | [Chapter 25](25-using-machine-code.md). |
| `LEFT$`, `RIGHT$`, `MID$`, `TL$` | arithmetic on `a u` | Below. |

## Side by side

**A function of two arguments, and one of none.**

```
10 LET t=20
20 DEF FN m(a,b)=(a+b)/2
30 DEF FN d()=t*2
40 PRINT FN m(4,10)
50 PRINT FN d()
```

```forth
VARIABLE T  20 T !
: DOUBLE-T  ( -- n )  T @ 2* ;
4 10 MEAN .                     \ => 7
DOUBLE-T .                      \ => 40
```

`MEAN` was defined above. `DOUBLE-T` reads the variable because it says
`T @`; `MEAN` could not touch a variable by accident even if one were
called `A` or `B`.

**A recursive function.** The sum of the numbers from 1 to n.

```
10 DEF FN t(n)=n?(0,n+FN t(n-1))
20 PRINT FN t(10)
```

```forth
: TRI  ( n -- sum )  DUP IF  DUP 1- RECURSE +  THEN ;
10 TRI .                        \ => 55
```

BASIC needs the select operator to stop the recursion, because the body
of a `DEF FN` is a single expression. A Forth word has `IF`. When `n` is
zero, `TRI` leaves it as it is, and that zero is the result.

**A number as a string, a string as a number.**

```
10 LET a$=STR$ 1984
20 PRINT LEN a$
30 PRINT VAL a$+16
40 PRINT VAL "2*3"
50 PRINT STR$ (255,16)
```

```forth
1984 STR$ NIP .                 \ => 4
1984 STR$ VAL 16 + .            \ => 2000
S" 2 3 *" EVALUATE .            \ => 6
255 16 BASE$ TYPE               \ => FF
```

In the second line the string made by `STR$` is used at once by `VAL`,
which is the safe way to use it.

**Searching for a character.**

```
10 LET a$="ZX Spectrum Next"
20 PRINT IN (a$," ")
30 PRINT IN (a$,"N")
40 PRINT IN (a$,"q")
```

```forth
: /STRING  ( a u k -- a2 u2 )  ROT OVER + -ROT - ;
: POS  ( a u c -- n )
    >R  OVER SWAP
    BEGIN  DUP WHILE
        OVER C@ R@ = IF
            DROP SWAP - 1+  R> DROP EXIT
        THEN
        1 /STRING
    REPEAT
    R> DROP  2DROP DROP 0 ;
: MACHINE  ( -- a u )  S" ZX Spectrum Next" ;
MACHINE BL POS .                \ => 3
MACHINE CHAR N POS .            \ => 13
MACHINE CHAR q POS .            \ => 0
```

`POS` is the loop of Chapter 7 that chops the first character off until
the string is empty, with a test in the middle. The character looked for
waits on the return stack; the starting address stays at the bottom, so
that when the character is found the difference between the two addresses
is its position. `/STRING` is the same word as in Chapter 7. `BL` is the
code of the space and `CHAR N` the code of the letter N.

**`LEFT$`, `RIGHT$`, `MID$`, `TL$`.** The functions other BASICs have,
which the manual suggests writing with `DEF FN`.

```
10 DEF FN l$(a$,n)=a$( TO n)
20 DEF FN t$(a$)=a$(2 TO )
30 PRINT FN l$("ZX Spectrum Next",4)
40 PRINT FN t$("ZX Spectrum Next")
```

```forth
: LEFT$   ( a u n -- a u2 )   MIN ;
: RIGHT$  ( a u n -- a2 u2 )  OVER MIN >R  + R@ -  R> ;
: MID$    ( a u from n -- a2 u2 )  >R 1- /STRING R> MIN ;
: TL$     ( a u -- a2 u2 )    DUP IF  1 /STRING  THEN ;
MACHINE 4 LEFT$ TYPE            \ => ZX S
MACHINE 4 RIGHT$ TYPE           \ => Next
MACHINE 4 8 MID$ TYPE           \ => Spectrum
MACHINE TL$ TYPE                \ => X Spectrum Next
MACHINE 99 RIGHT$ TYPE          \ => ZX Spectrum Next
```

They are the slices of Chapter 7 under other names: none of them copies
a character. `RIGHT$` here gives the last `n` characters, as in most
BASICs. The `MIN` in `LEFT$`, `RIGHT$` and `MID$` and the `IF` in `TL$`
keep the result inside the string when more is asked for than there is,
so they are safe on an empty string as well.

## No equivalent

- **A function as something different from a procedure.** Both are colon
  definitions; the difference is only whether they leave something.
- **`STR$` with fractional places**, and `STR$` of a floating-point
  number. The pictured output works on integers; a decimal point is put
  in by hand with `HOLD`, as in Chapter 6.
- **`VAL` of an infix expression.** `EVALUATE` runs Forth: `"2*3"` has to
  be written `2 3 *`.
- **`IN` with a start position, backwards, or with a wildcard.** To start
  further on, give `POS` a slice. The rest is to be written.
- **`SQR` with decimals** on integers; an error for a negative argument.
- **Checks on the argument.** No `Invalid argument`: a word given a wrong
  value gives a wrong result.

## Further reading

- Tutorial `005` -- `:` and `;`, stack comments.
- Tutorial `014` -- `<#` `#` `#S` `HOLD` `SIGN` `#>`.
- Tutorial `004` -- `BASE`, `HEX`, `DECIMAL`.
- Tutorial `021` -- `EVALUATE`.
- Tutorial `061` -- `RECURSE` and named locals.
- Tutorial `009` -- strings as address and length.
- Tutorial `015` -- double numbers, `FM/MOD` and `SM/REM`.
- `HELP ABS`, `HELP SQRT`, `HELP DSQRT`, `HELP <#`, `HELP #S`,
  `HELP SIGN`, `HELP #>`, `HELP BASE`, `HELP >NUMBER`, `HELP NUMBER`,
  `HELP EVALUATE`, `HELP RECURSE`, `HELP FM/MOD`.
- vForth manual, sections 2.12.5 "Integer Arithmetics", 2.12.9
  "Definition related" and 2.12.11 "Numbers & strings".

<!-- nav -->
---

Previous: [Chapter 7 - Strings](07-strings.md) |
[Contents](README.md) |
Next: [Chapter 9 - Mathematical Functions](09-mathematical-functions.md)
