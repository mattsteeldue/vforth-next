# Chapter 2 - Decisions

[From NextBASIC to vForth](README.md)

Manual: Chapter 2, pp. 16-20.

## In short

Everything here carries over, in a different order. `IF`, `ELSE` and `THEN`
keep their names but change places: the condition comes first and `THEN`
goes last. BASIC's three forms of `IF` become one. `ON` becomes `CASE`, or a
jump table built with `EXEC:`, and the select operator `?` becomes a table
of values. What you have to relearn: where `THEN` goes, the fact that true
is -1, and that `<=` and `>=` are each written with two words.

## What changes

**The condition comes first, and `THEN` comes last.** Like every Forth word,
`IF` finds its argument on the stack: the condition is worked out *before*
`IF`, which takes the result and decides. `THEN` does not introduce the
action, it marks where the two ways meet again. Read it as "and then carry
on".

```forth
: SIGN?  ( n -- )
    0< IF  ." negative"  ELSE  ." not negative"  THEN ;
-5 SIGN?                        \ => negative
5 SIGN?                         \ => not negative
```

So `IF c THEN a: ELSE b` is `c IF a ELSE b THEN`. If the word `THEN` in
that position bothers you, vForth accepts `ENDIF` as a synonym.

**There is only one form.** NextBASIC has a short and a medium `IF` that
must fit in one line, and a long one, without `THEN`, that has rules about
what starts a line. In Forth the end of a line means nothing, so the same
`IF ... ELSE ... THEN` is written on one line or on ten, and anything can go
inside it, another `IF` included.

**Decisions live inside definitions.** Like the loops of
[Chapter 3](03-looping.md), `IF` works only while a word is being compiled:

```forth
3 0< IF 1 . THEN                \ => IF? Can't be executed.
```

**`IF` uses up the condition.** The flag is taken off the stack and is gone.
More often than not the number that was tested is gone too, because the
comparison consumed it. When it is needed afterwards, `DUP` it before the
test (`?SGN` in "Side by side" does it).

**True is -1, and anything that is not zero counts as true.** A BASIC
comparison gives 1 or 0. A Forth comparison gives -1 (all sixteen bits set)
or 0:

```forth
3 4 < .                         \ => -1
4 3 < .                         \ => 0
```

`IF` itself only asks "zero or not?", so a number can stand directly for
the condition "is not zero", as in BASIC. Why -1 is the better choice of
true becomes clear with `AND` and `OR`, in Chapter 12.

**The relations are words, and they come after their operands.** `a<b` is
`a b <`. The words `=`, `<` and `>` are in the core; `<>` is loaded with
`NEEDS <>`. There is no `<=` and no `>=`: say the opposite and reverse it
with `0=`, which turns true into false and false into true.

```forth
5 5 > 0= .                      \ => -1
6 5 > 0= .                      \ => 0
```

That is `5<=5` and `6<=5`. With whole numbers there is often a shorter way:
`s>=90` is `s 89 >`.

**`NOT` is there, and it is the same word as `0=`.** The core has a word
`NOT` that does exactly what `0=` does: zero becomes true, anything else
becomes false. Write whichever reads better. `0=` asks "is this number
zero?"; `NOT` reverses a condition, as it does in BASIC, only after it
instead of before.

```forth
5 5 > NOT .                     \ => -1
0 NOT .                         \ => -1
7 NOT .                         \ => 0
```

It is the logical NOT: it does not invert the bits of a number. That is
`INVERT`, in Chapter 6.

**Comparing with zero has words of its own.** `0=`, `0<` and `0>` test the
number on top of the stack against zero. They are shorter and faster than
`0 =`, and they are what a Forth programmer writes by habit.

**No `GO TO` after `THEN`.** `IF c THEN GO TO n` has nowhere to go. What the
jump was for is written in place, between `IF` and `THEN`; and when it was
used to skip the rest of the routine, the word is `EXIT`, which leaves the
definition at once.

**A chain of `ELSE IF` needs one `THEN` for each `IF`.** There is no
`ELSE IF` as a unit: the second `IF` is simply nested in the `ELSE` part of
the first, and each one has to be closed. Three levels are already hard to
read, so Forth offers two ways out: end each case with `EXIT`, or use
`CASE`. Both are shown below.

**`ON` selects by position, `CASE` by value.** `ON n` runs the n-th
statement of its line. `CASE` (`NEEDS CASE`) compares a number with any
values you like, in any order, consecutive or not: key codes, error
numbers, characters. What follows the last `ENDOF` is the `ELSE` part.
The nearest thing to `ON` itself is `EXEC:` (`NEEDS EXEC:`), which runs the
n-th of the words listed after it, counting from 0. It is very fast and
checks nothing: an `n` outside the list crashes the machine, so the range
has to be made safe first.

**Equal strings compare as 0.** Strings are compared by `COMPARE`
(`NEEDS COMPARE`), which takes two strings, each as an address and a
length, and leaves -1, 0 or 1: before, equal, after. Zero means *equal*, the
opposite of a flag, so the test for equality is `COMPARE 0=`.

```forth
NEEDS COMPARE
NEEDS S"
: T1  S" apple" S" apple" COMPARE . ;
: T2  S" apple" S" pear"  COMPARE . ;
T1                              \ => 0
T2                              \ => -1
```

Strings are the subject of Chapter 7.

## Correspondence table

| NextBASIC | vForth | Note |
|---|---|---|
| `IF c THEN a` | `c IF a THEN` | Inside a definition. |
| `IF c THEN a: ELSE b` | `c IF a ELSE b THEN` | |
| `IF c` ... `ELSE` ... `ENDIF` (long form) | `c IF` ... `ELSE` ... `THEN` | The same construct, on any number of lines. |
| `ENDIF` | `THEN` | vForth accepts `ENDIF` too, with the same meaning. |
| `ELSE IF c2` | `ELSE c2 IF` ... `THEN THEN` | One `THEN` for each `IF`. Or `EXIT`, or `CASE`. |
| `IF c THEN GO TO n` | `c IF` ... `THEN` | Write the code in place. |
| `IF c THEN STOP`, `RETURN`, `ENDPROC` | `c IF EXIT THEN` | Leaves the definition. |
| `a=b` `a<b` `a>b` | `a b =` `a b <` `a b >` | True is -1. |
| `a<>b` | `a b <>` | `NEEDS <>`. |
| `a<=b` | `a b > 0=` | No word of its own. Or `a b > NOT`. |
| `a>=b` | `a b < 0=` | No word of its own. |
| `a=0` `a<0` `a>0` | `a 0=` `a 0<` `a 0>` | |
| `a<>0` | `a` | Any non-zero number is true for `IF`. |
| `NOT c` | `c NOT` or `c 0=` | The same word under two names. See Chapter 12 for `AND` and `OR`. |
| `a>=lo AND a<hi` | `a lo hi WITHIN` | `NEEDS WITHIN`. The upper limit is excluded. |
| `ON n: s0: s1: s2` | `n CASE 0 OF` ... `ENDOF` ... `ENDCASE` | `NEEDS CASE`. Any values, not only 0, 1, 2. |
| the same, as a jump table | `n EXEC: w0 w1 w2 ;` | `NEEDS EXEC:`. No check on `n`. |
| `ON` ... `: ELSE s` | code between the last `ENDOF` and `ENDCASE` | The value is still on the stack there. |
| `n?(e0,e1,e2)` | `CREATE t e0 , e1 , e2 ,` then `n 2 MIN CELLS t + @` | The `MIN` gives "past the end, the last one". |
| `GO TO n?(l0,l1,l2)` | `n EXEC: w0 w1 w2 ;` | |
| `a$=b$` | `COMPARE 0=` | `NEEDS COMPARE`. |
| `a$<b$` | `COMPARE 0<` | |

## Side by side

**Three ways.** Negative, positive or zero.

```
10 INPUT n
20 IF n<0 THEN PRINT "negative": ELSE IF n>0 THEN PRINT "positive": ELSE PRINT "zero"
```

The name is not `SIGN`: that one is in the core, and the number
formatting of [Chapter 8](08-functions.md) uses it to put the minus in
front. Not `SGN` either, which Chapter 8 defines as BASIC's function.
The literal translation nests the second `IF` in the `ELSE` part of the
first. `0<` consumes the number, hence the `DUP`; each branch then has to
dispose of the copy, by using it or by dropping it.

```forth
: ?SGN  ( n -- )
    DUP 0< IF
        DROP ." negative"
    ELSE
        0> IF  ." positive"  ELSE  ." zero"  THEN
    THEN ;
-7 ?SGN                        \ => negative
7 ?SGN                         \ => positive
0 ?SGN                         \ => zero
```

The same word with one case per line. Each case that applies does its work
and leaves; what is still running at the last line is the case left over.

```forth
: ?SGN  ( n -- )
    DUP 0< IF  DROP ." negative"  EXIT THEN
        0> IF       ." positive"  EXIT THEN
    ." zero" ;
-7 ?SGN                        \ => negative
7 ?SGN                         \ => positive
0 ?SGN                         \ => zero
```

**Ranges.** A score from 0 to 100.

```
10 INPUT "Score? ";s
20 IF s>=90
30   PRINT "excellent"
40 ELSE IF s>=60
50   PRINT "pass"
60 ELSE
70   PRINT "fail"
80 ENDIF
```

```forth
: GRADE  ( score -- )
    DUP 89 > IF  DROP ." excellent"  EXIT THEN
        59 > IF       ." pass"       EXIT THEN
    ." fail" ;
95 GRADE                        \ => excellent
90 GRADE                        \ => excellent
60 GRADE                        \ => pass
59 GRADE                        \ => fail
```

`GRADE` asks for nothing: the score is whatever is on the stack. That is
what lets the four lines after it try the word at the limits of each range.

**One of several, by number.** A menu.

```
10 INPUT "Choice (0-2)? ";c
20 ON c: PRINT "load": PRINT "save": PRINT "quit": ELSE PRINT "what?"
```

```forth
NEEDS CASE
: CHOICE  ( n -- )
    CASE
        0 OF  ." load"  ENDOF
        1 OF  ." save"  ENDOF
        2 OF  ." quit"  ENDOF
        ." what?"
    ENDCASE ;
1 CHOICE                        \ => save
7 CHOICE                        \ => what?
```

`ENDCASE` removes the number when no `OF` matched, so the default part must
leave it where it is. The values after `CASE` are compared one by one, from
the top. When they really are 0, 1, 2 and speed matters, `EXEC:` goes
straight to the n-th word:

```forth
NEEDS EXEC:
: .LOAD  ." load" ;
: .SAVE  ." save" ;
: .QUIT  ." quit" ;
: CHOICE  ( n -- )
    0 MAX 2 MIN
    EXEC: .LOAD .SAVE .QUIT ;
1 CHOICE                        \ => save
7 CHOICE                        \ => quit
```

Here `0 MAX 2 MIN` forces the number into the range 0 to 2 before `EXEC:`
sees it. An `ELSE` part would take one more word in the list and a
`3 MIN`.

**One value of several.** The select operator.

```
10 INPUT n
20 PRINT n?(1,2,5,10,20,50)
```

```forth
CREATE COINS  1 , 2 , 5 , 10 , 20 , 50 ,
: COIN  ( n -- value )  5 MIN  CELLS COINS + @ ;
2 COIN .                        \ => 5
9 COIN .                        \ => 50
```

`CREATE` names a place in memory and each `,` stores one number there, so
`COINS` is a table of six cells. `COIN` works out the address of cell `n`
and fetches it; the `5 MIN` reproduces the rule that an index past the end
gives the last value. Tables are the subject of Chapters 5 and 11.

## No equivalent

- **`IF` as a direct command.** Define a word, even a throwaway one.
- **`IF c THEN GO TO n`, `GO TO n?(...)`.** There are no lines to jump to:
  see [Chapter 1](01-basic-programming-concepts.md). The select operator
  used to choose *where to go* becomes `EXEC:`, which chooses *what to do*.
- **`<=` and `>=` as single words.** Use `> 0=` and `< 0=`.
- **`ON` with a value that is rounded and checked.** `CASE` compares exact
  16-bit integers; `EXEC:` does not check at all.
- **The select operator on strings**, `n?("zero","one","two")`. A table of
  values holds numbers. To print one of several texts use `CASE` with a
  `."` in each branch; to keep several strings in a table see Chapter 7.

## Further reading

- Tutorial `006`, sections 1-3 -- flags, `IF`, `ELSE`, `THEN` and nesting.
- Tutorial `011` -- `AND`, `OR`, `XOR` and the other bitwise words.
- Tutorial `013` -- `CASE`, `OF`, `ENDOF`, `ENDCASE`.
- Tutorial `010` -- tables built with `CREATE` and `,`.
- Tutorial `009` -- strings, for `COMPARE`.
- `HELP IF`, `HELP ELSE`, `HELP THEN`, `HELP 0=`, `HELP NOT`, `HELP <>`,
  `HELP WITHIN`, `HELP CASE`, `HELP EXEC:`, `HELP COMPARE`.
- vForth manual, sections 2.12.3 "Comparison" and 2.12.7 "Flow control".

<!-- nav -->
---

Previous: [Chapter 1 - Basic Programming Concepts](01-basic-programming-concepts.md) |
[Contents](README.md) |
Next: [Chapter 3 - Looping](03-looping.md)
