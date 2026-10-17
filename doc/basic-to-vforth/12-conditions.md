# Chapter 12 - Conditions

[From NextBASIC to vForth](README.md)

Manual: Chapter 12, pp. 71-73.

## In short

`AND`, `OR` and `NOT` keep their names and, on the result of a comparison,
their meaning. Two things change. There are no priorities: conditions are
combined in the order they are written. And true is -1 instead of 1, which
makes the "conditional expressions" at the end of the chapter simpler in
Forth than in BASIC: a flag is a mask that keeps a number or wipes it out.
The trap is a number that is not a flag: `AND` and `OR` work on bits, and
two "true" numbers can give false.

## What changes

**The conditions come first, the word that joins them after.** As with
`+` in [Chapter 6](06-expressions.md), `a>0 AND b>0` becomes
`a 0> b 0> AND`: two comparisons, each leaving its flag, then `AND` takes
both.

```forth
: SHOW  ( x answer -- )
    [CHAR] y =  OVER 0> AND
    IF  .  ELSE  DROP ." -"  THEN ;
5 CHAR y SHOW                   \ => 5
-5 CHAR y SHOW                  \ => -
5 CHAR n SHOW                   \ => -
```

`OVER` brings up a copy of `x` for the second test, because the first one
used up the answer. The two `CHAR` are at the prompt and `[CHAR]` inside
the definition, as [Chapter 1](01-basic-programming-concepts.md) explains.

**No priorities, no parentheses.** In BASIC `OR` is weaker than `AND`, which
is weaker than `NOT`, which is weaker than the relations. In Forth each
word acts when it is reached, so the order of writing *is* the order of
evaluation. With `a=1`, `b=0`, `c=0`, BASIC reads `a>0 OR b>0 AND c>0` as
`a>0 OR (b>0 AND c>0)`, which is true. The two readings are two different
lines of Forth:

```forth
1 0> 0 0> 0 0> AND OR .         \ => -1
1 0> 0 0> OR 0 0> AND .         \ => 0
```

The first line is BASIC's reading: the `AND` is done first, because it is
written first. The second is `(a>0 OR b>0) AND c>0`.

**On flags, the ten combinations are the ones you expect.** The manual
asks you to work out four results for `AND`, four for `OR` and two for
`NOT`. Here they are, with -1 for true:

```forth
0 0 AND .  0 -1 AND .  -1 0 AND .  -1 -1 AND .  \ => 0 0 0 -1
0 0 OR .   0 -1 OR .   -1 0 OR .   -1 -1 OR .   \ => 0 -1 -1 -1
0 NOT .  -1 NOT .                               \ => -1 0
```

**On other numbers, they are not.** `AND` and `OR` combine the sixteen
bits of their numbers one by one (Chapter 6). That is the logical result
only when every bit is the same, as in 0 and -1. 1 and 2 are both "true"
for `IF`, yet they have no bit in common:

```forth
1 2 AND .                       \ => 0
: 0<>  ( n -- flag )  0= 0= ;
1 0<> 2 0<> AND .               \ => -1
```

`0= 0=` turns any number into a proper flag: zero stays false, anything
else becomes -1. vForth has no word for it; the line above gives it the
name it has in standard Forth. Use it whenever a number, not a comparison,
stands for a condition and is about to meet `AND`.

**`NOT` is logical, `INVERT` is bitwise.** `NOT` is the same word as `0=`
([Chapter 2](02-decisions.md)): any number that is not zero becomes 0.
`INVERT` (`NEEDS INVERT`) turns every bit over. On a flag the two agree; on
any other number `INVERT` gives another number that is still true:

```forth
NEEDS INVERT
-1 NOT .  -1 INVERT .           \ => 0 0
5 NOT .                         \ => 0
5 INVERT .                      \ => -6
```

**`NOT` goes after what it negates.** `NOT a=b` is `a b = NOT`, and it is
the same as `a b <>` (`NEEDS <>`). As in BASIC you can always remove a
`NOT` by changing the relation, except that Forth has no `<=` and `>=` to
change into: `NOT a<b` stays `a b < NOT`, or `a b < 0=`.

```forth
NEEDS <>
3 4 = NOT .  3 4 <> .           \ => -1 -1
```

**De Morgan's laws hold.** `NOT (p AND q)` is `NOT p OR NOT q`, and
`NOT (p OR q)` is `NOT p AND NOT q`, on flags exactly as in BASIC. Without
parentheses the left-hand side is simply written with `NOT` at the end:

```forth
-1 0 AND NOT .                  \ => -1
-1 NOT 0 NOT OR .               \ => -1
```

**A flag is a mask.** BASIC defines `x AND y` as "x if y is true, else 0"
and has to make it a special rule, because its true is 1. In Forth it is
not a rule at all: -1 has all sixteen bits set, so `x -1 AND` is `x` and
`x 0 AND` is 0.

```forth
7 5 3 > AND .                   \ => 7
7 3 5 > AND .                   \ => 0
```

The same works on a string. A string is an address and a length
([Chapter 7](07-strings.md)); masking the length with a flag leaves either
the string or a string of length 0, the empty string:

```forth
NEEDS S"
: ITEMS  ( n -- )
    DUP .  ." item"  S" s" ROT 1 <> AND TYPE ;
1 ITEMS                         \ => 1 item
3 ITEMS                         \ => 3 items
```

**`OR` has no "x unless y".** BASIC's `x OR y` is "1 if y is true, else
x", useful as a factor that becomes 1. Forth's `OR` sets bits: `x -1 OR` is
-1, whatever `x` was. Write it as a decision, `IF DROP 1 THEN`, or better
avoid the multiplication altogether (see "Side by side").

**Ranges have words of their own.** BASIC writes `a<=x AND x<=b`. In Forth
that is two comparisons, an `AND` and some stack work, so there are two
words that do it in one go. `x a b BETWEEN` (`NEEDS BETWEEN`) includes
both limits; `x a b WITHIN` (`NEEDS WITHIN`) excludes the upper one, which
is the form used with sizes and indexes counted from 0:

```forth
NEEDS BETWEEN
NEEDS WITHIN
10 1 10 BETWEEN .               \ => -1
10 1 10 WITHIN .                \ => 0
10 0 16 WITHIN .                \ => -1
```

## Correspondence table

| NextBASIC | vForth | Note |
|---|---|---|
| `p AND q` | `p q AND` | Logical on flags, bitwise on other numbers. |
| `p OR q` | `p q OR` | The same. |
| `NOT p` | `p NOT` or `p 0=` | Logical. Bitwise is `INVERT` (`NEEDS INVERT`). |
| `NOT a=b` | `a b = NOT`, `a b <>` | `NEEDS <>`. |
| `NOT a<b` | `a b < NOT` | No `>=` to turn it into. |
| `p OR q AND r` | `p q r AND OR` | No priorities: the order of writing. |
| `(p OR q) AND r` | `p q OR r AND` | No parentheses needed. |
| true is 1 | true is -1 | `NEGATE` or `1 AND` to get 1. |
| a number as a condition | `n 0= 0=` | Before `AND` or `OR`. `: 0<> 0= 0= ;` |
| `x AND y` (x if y) | `x f AND` | `f` from a comparison. |
| `x OR y` (1 if y) | `x f IF DROP 1 THEN` | `OR` sets bits: `x -1 OR` is -1. |
| `x$ AND y` | `a u f AND` | The empty string if `f` is false. |
| `(a AND NOT a<b)+(b AND a<b)` | `a b MAX` | `MIN` for the smaller. |
| `a$>b$` | `COMPARE 0>` | `NEEDS COMPARE`. Ignores case until `CASEON`. |
| `a<=x AND x<=b` | `x a b BETWEEN` | `NEEDS BETWEEN`. Both limits included. |
| `a<=x AND x<b` | `x a b WITHIN` | `NEEDS WITHIN`. Upper limit excluded. |

## Side by side

**Two conditions.** A number, printed only if the answer is yes and the
number is positive.

```
10 INPUT "Answer (y/n)? ";a$
20 INPUT "Number? ";x
30 IF a$="y" AND x>0 THEN PRINT x: ELSE PRINT "-"
```

That is `SHOW`, at the top of "What changes". The answer is a single
character there, compared with `=`; for a whole word see the last example.

**The larger of two.** BASIC adds two conditional expressions, one of which
is always 0.

```
10 INPUT a,b
20 PRINT (a AND NOT a<b)+(b AND a<b)
```

The literal translation works in Forth too, because a flag is a mask:

```forth
: LARGER  ( a b -- n )
    2DUP <  >R R@ AND
    SWAP R> NOT AND + ;
3 8 LARGER .  8 3 LARGER .  5 5 LARGER .        \ => 8 8 5
```

It is a fine exercise in stack juggling, and nobody writes it: the word is
`MAX`.

```forth
3 8 MAX .  8 3 MAX .  3 8 MIN .                 \ => 8 8 3
```

**A factor that becomes 1.** A price with 15% tax, unless the goods are
zero rated.

```
10 INPUT "Net price? ";n
20 INPUT "Zero rated (y/n)? ";v$
30 PRINT n*(1.15 OR v$="y")
```

The price is in pence, so that it stays an integer. The first version
decides; the second uses the flag as a mask on the tax, which is added
instead of multiplied: in Forth the conditional expression that comes
naturally is the one with `AND`.

```forth
: GROSS  ( net zero? -- gross )
    0= IF  115 100 */  THEN ;
200 0 GROSS .  200 -1 GROSS .                   \ => 230 200
: GROSS  ( net zero? -- gross )
    0=  OVER 15 100 */  AND  + ;
200 0 GROSS .  200 -1 GROSS .                   \ => 230 200
```

**A string that may be empty.** Singular and plural.

```
10 FOR n=0 TO 2
20   PRINT n;" item";("s" AND n<>1)
30 NEXT n
```

```forth
: COUNTS  ( -- )  3 0 DO  I ITEMS SPACE  LOOP ;
COUNTS                          \ => 0 items 1 item 2 items
```

**Two words in order.** The relation is printed as two strings, of which
one at most is not empty.

```
10 LET a$="pear": LET b$="apple"
20 IF b$<a$ THEN LET t$=a$: LET a$=b$: LET b$=t$
30 PRINT a$;" ";("<" AND a$<b$);("=" AND a$=b$);" ";b$
```

```forth
NEEDS COMPARE
: ORDER  ( a1 u1 a2 u2 -- )
    2OVER 2OVER COMPARE 0> IF  2SWAP  THEN
    2OVER TYPE SPACE
    2OVER 2OVER COMPARE >R
    S" <" R@ 0< AND TYPE  S" =" R> 0= AND TYPE
    SPACE TYPE 2DROP ;
: T1  S" pear" S" apple" ORDER ;
: T2  S" fig" S" fig" ORDER ;
: T3  S" Pear" S" apple" ORDER ;
T1                              \ => apple < pear
T2                              \ => fig = fig
T3                              \ => apple < Pear
```

`T3` is where the two languages part. BASIC compares character codes, and
every capital comes before every small letter, so it would print
`Pear < apple`. vForth's `COMPARE` ignores case until `CASEON` is given,
and puts the words in dictionary order. The character set, and `CASEON`,
are the subject of Chapter 13.

**The exercise.** "If `a` equals neither `b` nor `c`".

```
10 INPUT a,b,c
20 IF a<>b AND a<>c THEN PRINT "neither": ELSE PRINT "one of them"
```

```forth
: NEITHER?  ( a b c -- flag )
    2 PICK <>  -ROT <>  AND ;
5 3 4 NEITHER? .  5 5 4 NEITHER? .  5 3 5 NEITHER? .    \ => -1 0 0
```

By De Morgan, the same is `NOT (a=b OR a=c)`: `2 PICK = -ROT = OR NOT`.

## No equivalent

- **Priorities and parentheses.** None needed: write the conditions in the
  order they are to be combined.
- **A logical `AND` and `OR`.** There is only the bitwise pair. Feed them
  flags, or make flags first with `0= 0=`.
- **`x OR y` as "x unless y".** Use `IF`, or turn the multiplication into an
  addition masked with `AND`.
- **`0<>`.** Not in vForth; `: 0<> 0= 0= ;`.

## Further reading

- Tutorial `006` -- flags and `IF`.
- Tutorial `011` -- `AND`, `OR`, `XOR`, `INVERT` and masks.
- Tutorial `002` -- `MAX` and `MIN`.
- Tutorial `009` -- strings, for `COMPARE`.
- `HELP AND`, `HELP OR`, `HELP NOT`, `HELP 0=`, `HELP INVERT`, `HELP <>`,
  `HELP BETWEEN`, `HELP WITHIN`, `HELP MAX`, `HELP COMPARE`.
- [Chapter 2](02-decisions.md) -- comparisons, `IF`, `NOT`.
- [Chapter 6](06-expressions.md) -- `AND`, `OR` and `XOR` on bits.

<!-- nav -->
---

Previous: [Chapter 11 - Arrays](11-arrays.md) |
[Contents](README.md) |
Next: [Chapter 13 - The Character Set](13-the-character-set.md)
