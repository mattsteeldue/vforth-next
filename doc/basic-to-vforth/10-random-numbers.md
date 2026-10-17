# Chapter 10 - Random Numbers

[From NextBASIC to vForth](README.md)

Manual: Chapter 10, pp. 64-66.

## In short

This chapter carries over almost unchanged. `RND` (`NEEDS RND`) is the
integer form that NextBASIC writes `RND (n)` or `%RND n`: you give it a
number and it leaves a random integer from 0 to one less than that.
`RANDOMIZE` (`NEEDS RANDOMIZE`) sets the starting point. Both work on the
same system variable as BASIC, with the same formula. The one thing
missing is the plain `RND` that gives a fraction between 0 and 1, and
that is by choice: the manual itself recommends the integer form.

## What changes

**`RND` takes its range from the stack.** `n RND` leaves a number from 0
to `n-1`, so `6 RND` is one of 0, 1, 2, 3, 4, 5. Like any Forth word it
comes after its argument.

```forth
NEEDS RND
NEEDS WITHIN
: DICE  ( -- n )  6 RND 1+ ;
DICE 1 7 WITHIN .               \ => -1
```

Each call to `DICE` gives a number from 1 to 6; the last line only
checks that it is so, with the `WITHIN` of Chapter 2.

**There is no `RND` between 0 and 1.** vForth's numbers are integers, so
a random fraction has nowhere to go. Ask straight away for the integer
you want. BASIC programs written the old way multiply and truncate,
`INT (RND*n)`: that is `n RND`. When the fraction itself is wanted, scale
it as in [Chapter 9](09-mathematical-functions.md): `1000 RND` is a
random number of thousandths, and BASIC's `1.3+0.7*RND` becomes
`700 RND 1300 +`, a number from 1300 to 1999.

**`RANDOMIZE` always takes a number.** `n RANDOMIZE` starts the sequence
at a known place, so that a program under test behaves the same at each
run:

```forth
NEEDS RANDOMIZE
1 RANDOMIZE
100 RND . 100 RND . 100 RND .   \ => 0 17 87
1 RANDOMIZE
100 RND . 100 RND . 100 RND .   \ => 0 17 87
```

BASIC's `RANDOMIZE` with no argument, which takes its seed from the time
the machine has been on, has no counterpart of its own: without a number
on the stack the word would take whatever happens to be there. Do
what BASIC does, by hand. The frame counter that BASIC reads is the
system variable FRAMES, at address 23672:

<!-- no-test -->
```forth
23672 @ RANDOMIZE
```

Do it once, at the start of the program, and preferably after waiting
for a key: the moment the player presses it is the only truly unknown
quantity in the machine.

**It is the same generator, kept in the same place.** `RND` uses BASIC's
formula and keeps its state in BASIC's system variable SEED, at address
23670; `RANDOMIZE` simply stores a number there. The sequence has 65536
values and then repeats. Since vForth runs on top of NextBASIC, a seed
set before leaving BASIC is the one Forth starts from.

The cycle can be seen. Within it each of the 65536 values of SEED comes
exactly once, so one value per pixel, its low 9 bits as the column and
its high 7 as the row, lights every pixel of a band 512 by 128 once and
only once, with no gap and no repeat: "A screen filled at random" in
[Chapter 16](16-graphics.md) does it, in BASIC and in Forth, and shows
the generator back at its starting value after 65536 steps.

**There is a second generator.** `RANDOM` (`NEEDS RANDOM`) leaves a
random 16-bit number and `n CHOOSE` (`NEEDS CHOOSE`) a number from 0 to
`n-1`. They are the classic Forth pair, with a formula of their own, and
they use the same SEED, so `RANDOMIZE` serves them too. Either generator
will do; keep to one in a program, or the two will step on each other's
sequence.

```forth
NEEDS CHOOSE
1 RANDOMIZE
10 CHOOSE . 10 CHOOSE . 10 CHOOSE .     \ => 5 9 8
```

**No abbreviation.** BASIC accepts `RAND` for `RANDOMIZE`. If you miss
it, it is one definition: `: RAND  RANDOMIZE ;`.

## Correspondence table

| NextBASIC | vForth | Note |
|---|---|---|
| `RND (n)`, `%RND n` | `n RND` | `NEEDS RND`. From 0 to `n-1`. |
| `INT (RND*n)` | `n RND` | |
| `1+INT (RND*6)` | `6 RND 1+` | |
| `a+INT (RND*(b-a+1))` | `a b RND-IN` | Defined below. From `a` to `b`, both included. |
| `RND` (a fraction) | -- | Ask for a scaled integer: `1000 RND`. |
| `RANDOMIZE n` | `n RANDOMIZE` | `NEEDS RANDOMIZE`. |
| `RANDOMIZE`, `RANDOMIZE 0` | `23672 @ RANDOMIZE` | The seed taken from FRAMES, by hand. |
| `RAND` | -- | `: RAND  RANDOMIZE ;` |
| the system variable SEED | `23670 @`, `23670 !` | Shared with BASIC. |
| (not in BASIC) | `RANDOM`, `n CHOOSE` | `NEEDS RANDOM`, `NEEDS CHOOSE`. Another formula. |

## Side by side

In the Forth listings each example begins with `1 RANDOMIZE`, so that the
numbers shown are the ones you will get. Leave it out, or seed from
FRAMES, in a real program.

**A die with twenty faces.** The icosahedron of role-playing games,
thrown twice.

```
10 FOR n=1 TO 2
20   PRINT 1+RND (20);" ";
30 NEXT n
```

```forth
: D20  ( -- n )  20 RND 1+ ;
: THROW  ( -- )  D20 .  D20 . ;
1 RANDOMIZE
THROW                           \ => 1 4
THROW                           \ => 18 12
```

`D20` is `DICE` with 20 in place of 6: the number of faces is the
argument of `RND`, and `1+` moves the range from 0-19 to 1-20.

**A number in a range.** From 10 to 20, both included.

```
10 PRINT 10+RND (11)
```

```forth
: RND-IN  ( lo hi -- n )  OVER - 1+ RND + ;
1 RANDOMIZE
10 20 RND-IN . 10 20 RND-IN . 10 20 RND-IN .        \ => 10 11 19
```

`RND-IN` works out how many values there are, `hi-lo+1`, asks `RND` for
one of them and adds the lower limit. In BASIC that sum has to be done in
your head each time, and written as 11.

**Tossing a coin.** How many heads in a hundred tosses, and in a
thousand more?

```
10 LET h=0
20 FOR n=1 TO 100
30   LET h=h+RND (2)
40 NEXT n
50 PRINT h
```

```forth
: HEADS  ( tosses -- heads )  0 SWAP 0 ?DO  2 RND +  LOOP ;
1 RANDOMIZE
100 HEADS .                     \ => 45
1000 HEADS .                    \ => 531
```

`2 RND` is 0 or 1; the count stays on the stack and each toss is added to
it. No variable is needed. To *act* on a toss instead of counting it,
`2 RND IF ... ELSE ... THEN`: 0 is false and 1 is true.

**Is the die fair?** Six hundred throws, counted face by face.

```
10 DIM t(6)
20 FOR n=1 TO 600
30   LET d=1+RND (6)
40   LET t(d)=t(d)+1
50 NEXT n
60 FOR d=1 TO 6: PRINT t(d);" ";: NEXT d
```

```forth
CREATE TALLY  6 CELLS ALLOT
: THROWS  ( n -- )
    TALLY 6 CELLS ERASE
    0 ?DO  1  6 RND CELLS TALLY +  +!  LOOP ;
: .TALLY  ( -- )  6 0 DO  I CELLS TALLY + @ 5 .R  LOOP ;
1 RANDOMIZE
600 THROWS
.TALLY                  \ => 88 94 112 88 114 104
```

`TALLY` is an array of six cells, the subject of the next chapter. The
random number is used directly as the index, from 0 to 5, so here the
`1+` of `DICE` would only be in the way. `ERASE` sets the six counters to
zero, which `DIM` does by itself.

## No equivalent

- **`RND` as a fraction between 0 and 1.** Use `n RND` with the range, or
  the scale, that you need.
- **`RANDOMIZE` with no argument.** Fetch FRAMES yourself.
- **`RAND`.** No abbreviations in Forth; define it if you want it.

## Further reading

- `HELP RND`, `HELP RANDOMIZE`, `HELP RANDOM`, `HELP CHOOSE`.
- Tutorial `051` and tutorial `056` use `RANDOM` and `CHOOSE` in
  passing; no tutorial is devoted to random numbers yet.
- Tutorial `008` -- `@` and `!` on system variables.
- [Chapter 11](11-arrays.md) -- arrays, used here for the tally.
- [Chapter 16](16-graphics.md) -- "A screen filled at random": the
  cycle of 65536 values of `RND`, drawn one pixel per value.

<!-- nav -->
---

Previous: [Chapter 9 - Mathematical Functions](09-mathematical-functions.md) |
[Contents](README.md) |
Next: [Chapter 11 - Arrays](11-arrays.md)
