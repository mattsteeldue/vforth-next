# Chapter 4 - Procedures and Subroutines

[From NextBASIC to vForth](README.md)

Manual: Chapter 4, pp. 27-34.

## In short

Everything here carries over, and most of it gets simpler. `GO SUB` with
`RETURN` and `DEFPROC` with `ENDPROC` are two ways of doing one thing, and
Forth has one word for both: the colon definition of
[Chapter 1](01-basic-programming-concepts.md). Parameters and results travel
on the stack, as many as you like in either direction, though the Forth
way is to keep them few and the words short: *factoring*, splitting a
word into small ones, is the habit to acquire. `LOCAL` is mostly not
needed, and when it is there are named locals in a library; `PRIVATE` is a
`VARIABLE`; `REF` is "pass the address"; recursion is `RECURSE`. What you
have to relearn: parameters have no names, nobody checks how many you
passed, and a word cannot be used before it is defined.

## What changes

**A subroutine and a procedure are the same thing.** BASIC has subroutines
that start at a line and take nothing, and procedures that have a name and
take parameters. A Forth word has a name, takes what it wants from the stack
and leaves what it wants there. `GO SUB 500` and `PROC name()` are both
written by typing the name:

```forth
: RULE  ( n -- )  0 ?DO  ." -"  LOOP ;
5 RULE                          \ => -----
```

**There is nothing to jump over.** A BASIC program has to keep its
subroutines out of the way, with a `STOP` or a `GO TO` in front of them, or
it runs on into the first one. A definition is not carried out when it is
read, only stored, so the problem does not exist; neither does the report
`RETURN without GO SUB`.

**Definitions work from the keyboard.** `DEFPROC` is refused as a direct
command. In Forth it is the other way round: `:` works at the prompt, as
above, and it is `IF` and the loops that do not.

**Define before use.** `PROC` finds its `DEFPROC` anywhere in the listing.
A Forth word is looked up when the line that uses it is compiled, so it must
exist by then:

```forth
: MAIN  HELPER ;                \ => HELPER? is undefined.
```

Sources therefore read from the small words at the top to the main one at
the bottom. Two words that call each other need one name to be promised in
advance, with `DEFER`, and filled in later with `IS`:

```forth
NEEDS DEFER
NEEDS IS
DEFER PONG
: PING  ( n -- )  ?DUP IF  ." ping " 1- PONG  THEN ;
: PONG2 ( n -- )  ?DUP IF  ." pong " 1- PING  THEN ;
' PONG2 IS PONG
3 PING                          \ => ping pong ping
```

These two lines are read in opposite directions. `DEFER PONG` looks to the
right: `DEFER` takes the name that follows it. `' PONG2 IS PONG` has to be
read from the right, "`PONG` is `PONG2`": English puts the name first and
what it stands for after, and Forth writes them the other way round,
because what is assigned is a value and must already be on the stack when
`IS` runs. `'` ("tick") looks to the right too: it reads the name `PONG2`
and leaves on the stack the address of that word, which is what `IS` then
stores into `PONG`. This reading in two directions is found all over
Forth: see "Left for the value, right for the name" in
[Chapter 1](01-basic-programming-concepts.md).

**Parameters have no names.** `DEFPROC area(w,h)` names its parameters, and
`PROC area(3,4)` fills them in. A Forth word just finds its arguments on the
stack, where the caller left them, in the order they were written. The list
in brackets after the name is a comment, the *stack comment*: arguments
before the `--`, results after it. Forth ignores it; the reader does not.

```forth
: AREA  ( w h -- area )  * ;
3 4 AREA .                      \ => 12
```

So the arguments come *before* the name, without brackets or commas, and
they can be the result of anything: `3 4 AREA 2 AREA` multiplies three
numbers.

**Results stay on the stack.** `ENDPROC =a,b` hands results back and
`PROC ... TO x,y` puts them into variables. A Forth word returns a value by
not removing it. There is no `TO`: the caller prints the result, passes it
on to the next word, or stores it with `!`. Several results are no different
from one:

```forth
: RECT  ( w h -- area perimeter )
    2DUP *  ROT ROT  + 2* ;
3 4 RECT . .                    \ => 14 12
```

The last result is on top, so the first `.` prints the perimeter.

**Nobody counts the arguments.** There is no `Parameter error`. One argument
too many is left on the stack, to puzzle whatever runs next. One too few
makes the word take something that was not meant for it, and vForth notices
only afterwards, if the stack has been emptied below its bottom:

```forth
NEEDS DEPTH
1 2 3 AREA .                    \ => 6
DEPTH .                         \ => 1
DROP
3 AREA .                        \ => .? Stack is empty.
```

The first line multiplied 2 and 3 and left the 1 behind. The last one
multiplied 3 by whatever lies under the stack, and the complaint came from
`.`, not from `AREA`. While you write a word, `DEPTH` and `.S` (`NEEDS .S`,
shows the whole stack without changing it) are how you check that it takes
and leaves what its stack comment says.

**The number of arguments is fixed.** A parameter cannot be left out and
given a default, as in `DEFPROC name(n=0)`. Write a second word that
supplies the value:

```forth
: RULE32  ( -- )  32 RULE ;
```

When the number really varies, pass the count as the last argument: see
`TOTAL` in "Side by side".

**`RETURN` and `ENDPROC` are `;`, and in the middle they are `EXIT`.** The
`;` that closes a definition is also what returns from it. To leave earlier,
as with an `ENDPROC` half-way down, use `EXIT`; inside a `DO` loop put
`UNLOOP` before it ([Chapter 3](03-looping.md)).

```forth
: SAFE/  ( a b -- q )
    DUP 0= IF  2DROP 0  EXIT THEN
    / ;
7 2 SAFE/ .                     \ => 3
7 0 SAFE/ .                     \ => 0
```

Every way out must leave the same number of items, here one. That is the
rule `PROC ... TO` enforces with a report, and that Forth leaves to you.

**Most locals disappear.** A `LOCAL` in BASIC protects a name: the variable
`i` of a procedure must not spoil the `i` of the program. In Forth an
intermediate value has no name, so there is nothing to protect. It lives on
the stack, and the loop counter `I` belongs to its own loop. The words
`DUP`, `SWAP`, `OVER` and `ROT` do the work of the names, and when one value
is in the way of the others it can be set aside for a moment with `>R` and
taken back with `R>`:

```forth
: DISC  ( a b c -- d )
    ROT * 4 *  >R               \ 4ac, set aside
    DUP *  R> - ;               \ b*b - 4ac
1 5 6 DISC .                    \ => 1
```

**`>R` uses the return stack, and that is where `RETURN` looks.** BASIC's
`GO SUB` stack is hidden. Forth's is open: `>R` moves a value onto it, `R>`
brings it back, `R@` copies it. The address a word returns to is kept there
too, so whatever a word puts on the return stack it must take off before `;`
or `EXIT`, and it cannot move a value across the `DO` or the `LOOP` of a
loop, which keeps its counter in the same place. Break the rule and the word
returns into nowhere.

**Factor: small words, few arguments.** This is the spirit of Forth. A
BASIC subroutine costs a line number and a `GO SUB`, so programs tend to
have few of them, and long. A Forth word costs only a name, and calling it
costs next to nothing, so programs are made of many small ones: a line or
two each, two or three arguments at most, a name that says what the word
does. Splitting a word into smaller ones is called *factoring*, and doing
it again on a word that already works, *refactoring*. When a definition
is hard to follow, the stack too deep to keep in mind, the usual remedy is
not a name for each value but a name for each step:

```forth
: SQUARE  ( n -- n*n )  DUP * ;
: 4*AC    ( a c -- 4ac )  * 4 * ;
: DISC    ( a b c -- d )  ROT 4*AC  SWAP SQUARE  SWAP - ;
1 5 6 DISC .                    \ => 1
5 SQUARE .                      \ => 25
```

Each step can be tried at the prompt on its own, as `SQUARE` is on the
last line, before the word that uses it is written: a small word is tested
in a moment, a long one is debugged for an evening. And the small words
are there to be reused: `SQUARE` will serve again.

**Named locals are a library.** With three or four arguments the stack
shuffling starts to hide the formula, and sometimes factoring does not
help, because the values are all needed together. `NEEDS LOCALS` adds `{`,
which gives the arguments names:

```forth
NEEDS LOCALS
: DISC  ( a b c -- d )  { A B C }
    B B *  4 A * C *  - ;
1 5 6 DISC .                    \ => 1
```

`{` must be the first word of the body, with all the names and the `}` on
the same line; there may be up to eight. The names are listed in the order
the caller wrote the arguments. A local pushes its value, like a `VALUE`,
and is changed with `TO`. Names after a `--` are *results*: they start at
zero, the body sets them with `TO`, and they are left on the stack at every
exit, in the order declared.

```forth
: RECT  ( w h -- area perimeter )  { W H -- SURFACE PERIM }
    W H *  TO SURFACE
    W H + 2*  TO PERIM ;
3 4 RECT . .                    \ => 14 12
```

Give a local a name that no word already has. vForth warns when you do
not (`has already been defined.`), and for good reason: inside the body the
local hides the word, and it goes on hiding it at the prompt until the next
`:` is typed. That is why the result above is called `SURFACE` and not
`AREA`.

Locals are private to their definition and a word that uses them can call
itself, as a BASIC procedure can. They are not free: each call uses return
stack, which is small, and each name uses memory for good. Reach for them
when a word is hard to read without and cannot be factored, not by habit.

**`PRIVATE` is a `VARIABLE`.** A value that must survive from one call to
the next is kept in a variable defined just before the word that uses it,
and `PRIVATE CLEAR` is a store of zero. A private survives `RUN` and is
reset only by `PRIVATE CLEAR` or by loading the program again; a Forth
variable starts at 0, survives until you store into it, and starts at 0
again when the source is loaded again. Nothing hides it: any word defined
later can read it and change it. Real hiding is done with vocabularies
(tutorial 018).

```forth
VARIABLE TICKETS
: TICKET  ( -- n )  1 TICKETS +!  TICKETS @ ;
TICKET . TICKET . TICKET .      \ => 1 2 3
0 TICKETS !
TICKET .                        \ => 1
```

**By reference means "pass the address".** The name of a variable pushes its
address, and `@` turns it into the value. To pass by value write `v @`; to
pass by reference write `v`, and let the word use `@` and `!` itself. No
keyword is needed, and it works for single variables as well as for tables.

```forth
VARIABLE SCORE
: BONUS  ( addr -- )  10 SWAP +! ;
SCORE BONUS
SCORE ?                         \ => 10
```

Passing a table this way costs one cell whatever its size: nothing is ever
copied unless you copy it.

**A word that calls itself says `RECURSE`.** While a definition is being
compiled its own name is not yet in the dictionary (this is what lets a new
word use an older one of the same name), so the call to itself is written
`RECURSE` (`NEEDS RECURSE`).

```forth
NEEDS RECURSE
: FACT  ( n -- n! )
    DUP 2 < IF  DROP 1  EXIT THEN
    DUP 1- RECURSE * ;
5 FACT .                        \ => 120
8 FACT U.                       \ => 40320
8 FACT .                        \ => -25216
```

The numbers are 16-bit cells: 8! still fits as an unsigned number, 9! does
not fit at all. Each level also uses a little return stack, so recursion
that goes hundreds of levels deep is better written as a loop.

**A local error trap is a `CATCH` around the call.** In BASIC each
procedure, subroutine or loop may hold an `ON ERROR` of its own, and an
error not dealt with is passed outwards. `CATCH` works the same way without
being told: a `THROW` goes to the nearest `CATCH` still active, and that
one can pass the error on with another `THROW`. See `OUTER` in "Side by
side".

## Correspondence table

| NextBASIC | vForth | Note |
|---|---|---|
| `GO SUB n` | `name` | The subroutine is a word, defined earlier. |
| `RETURN`, `ENDPROC` | `;` | |
| `RETURN`, `ENDPROC` in the middle | `EXIT` | In a `DO` loop: `UNLOOP EXIT` (`NEEDS UNLOOP`). |
| `DEFPROC name(a,b)` | `: name  ( a b -- )` | The stack comment is only a comment. |
| `PROC name(x,y)` | `x y name` | Arguments first; nothing is counted or checked. |
| `ENDPROC =r` | leave `r` on the stack | |
| `ENDPROC =r1,r2` | leave both | The last one is on top. |
| `PROC name() TO v` | `name v !` | Or use the result where it is. |
| `PROC name() TO v1,v2` | `name v2 ! v1 !` | Store the top one first. |
| a result that is not wanted | `DROP` | It does not go away by itself. |
| `DEFPROC name(n=0)` | `: name0  0 name ;` | A second word supplies the default. |
| `LOCAL v` | nothing: keep the value on the stack | Or `>R` ... `R>`. |
| `LOCAL` for a parameter's work copy | `{ a b c }` | `NEEDS LOCALS`. First word of the body, one line. |
| a local that is the result | `{ a b -- r }` | Starts at 0; pushed at every exit. |
| `LET v=e` for a local | `e TO v` | |
| `PRIVATE v=0` | `VARIABLE v` before the word | Visible to all the words that follow. |
| `PRIVATE CLEAR` | `0 v !` | One store for each variable. |
| `DEFPROC name(REF a())` | pass the address: `a name` | The word uses `@` and `!` on it. |
| a procedure that calls itself | `RECURSE` | `NEEDS RECURSE`. |
| two procedures that call each other | `DEFER name` ... `' word IS name` | `NEEDS DEFER`, `NEEDS IS`. |
| `DEFPROC name(DATA)` and `READ` | pass the count last: `x1 x2 x3 3 name` | |
| `ON ERROR` inside a procedure | `['] word CATCH` in the caller | `NEEDS CATCH`, `NEEDS [']`. |
| `ERROR` in the handler (pass it on) | `THROW` | `NEEDS THROW`. |
| the `GO SUB` stack | the return stack: `>R` `R>` `R@` | Leave it as you found it. |
| `GO TO` in front of the subroutines | - | Nothing to jump over. |
| `Q Parameter error` | - | See "No equivalent". |

## Side by side

**A subroutine.** A heading with a line under it, twice.

```
10 LET n=5: GO SUB 100
20 LET n=12: GO SUB 100
30 STOP
100 REM a line of n dashes
110 FOR i=1 TO n: PRINT "-";: NEXT i
120 PRINT
130 RETURN
```

The variable `n`, which was there only to carry a number into the
subroutine, becomes the argument of `RULE`, defined above:

```forth
5 RULE                          \ => -----
12 RULE                         \ => ------------
```

**A procedure with two results.** Area and perimeter of a rectangle.

```
10 PROC rect(3,4) TO a,p
20 PRINT a;" ";p
30 STOP
40 DEFPROC rect(w,h)
50 ENDPROC =w*h,2*(w+h)
```

`RECT` is defined twice under "What changes", with the stack and with
locals. To keep the results instead of printing them, store the top one
first:

```forth
VARIABLE SIZE
VARIABLE EDGE
3 4 RECT  EDGE !  SIZE !
SIZE ? EDGE ?                   \ => 12 14
```

**A value kept between calls.** Numbered tickets.

```
5 PRIVATE CLEAR
10 FOR i=1 TO 3: PROC ticket(): NEXT i
20 STOP
30 DEFPROC ticket()
40   PRIVATE t=0
50   t+=1
60   PRINT "Ticket ";t
70 ENDPROC
```

The Forth word is `TICKET`, shown above. It leaves the number instead of
printing it, so the same word serves a caller that wants to print and one
that wants to compute:

```forth
0 TICKETS !
: .TICKET  ( -- )  ." Ticket " TICKET . ;
.TICKET                         \ => Ticket 1
.TICKET                         \ => Ticket 2
```

**By reference.** Double every element of an array.

```
10 DIM a(3)
20 FOR i=1 TO 3: LET a(i)=i: NEXT i
30 PROC double(a(),3)
40 PRINT a(1);" ";a(2);" ";a(3)
50 STOP
60 DEFPROC double(REF t(),n)
70   LOCAL i
80   FOR i=1 TO n: LET t(i)=t(i)*2: NEXT i
90 ENDPROC
```

```forth
CREATE NUMS  1 , 2 , 3 ,
: DOUBLE  ( addr n -- )
    CELLS BOUNDS DO
        I @ 2*  I !
    2 +LOOP ;
: .NUMS  ( -- )  NUMS 3 CELLS BOUNDS DO  I @ .  2 +LOOP ;
NUMS 3 DOUBLE
.NUMS                           \ => 2 4 6
```

`NUMS` pushes the address of the table, and that address is what `DOUBLE`
receives. `BOUNDS` turns an address and a size in bytes into the limit and
the start of a `DO` loop, which then steps through the cells two bytes at a
time: `I` is not an index here, it is the address of each element. Tables
are the subject of Chapters 5 and 11.

**Recursion.** The greatest common divisor of two numbers.

```
10 PROC gcd(48,18) TO g
20 PRINT g
30 STOP
40 DEFPROC gcd(a,b)
50   LOCAL r
60   IF b=0 THEN ENDPROC =a
70   PROC gcd(b,a MOD b) TO r
80 ENDPROC =r
```

```forth
: GCD  ( a b -- gcd )
    ?DUP IF  SWAP OVER MOD  RECURSE  THEN ;
48 18 GCD .                     \ => 6
17 5 GCD .                      \ => 1
```

`?DUP` duplicates `b` only when it is not zero. If it is zero, `a` is
already the answer and is already where the answer has to be. Otherwise
`SWAP OVER MOD` turns `a b` into `b` and the remainder of `a/b`, which are
the arguments of the next call. The local `r` of the BASIC version has no
counterpart: the result of the inner call is left where the outer one would
have put it. The word comes with vForth, too: `NEEDS GCD` loads this same
definition, with `TUCK` in place of `SWAP OVER`.

**Any number of parameters.**

```
10 PROC total("Sum: ",4,8,15,16)
20 STOP
30 DEFPROC total(t$,DATA)
40   LOCAL n
50   LOCAL s=0
60   REPEAT: WHILE DATA
70     READ n: s+=n
80   REPEAT UNTIL 0
90   PRINT t$;s
100 ENDPROC
```

```forth
: TOTAL  ( n1 .. nk k -- sum )
    0 SWAP  0 ?DO  +  LOOP ;
4 8 15 16  4 TOTAL .            \ => 43
0 TOTAL .                       \ => 0
```

A word cannot ask how many arguments it was given, because the stack does
not record where they begin. The caller says so, with a count on top.
`0 SWAP` slips the starting total under the count, and each turn of the loop
adds one more number to it.

**Trapping an error locally, and passing it on.**

```
10 ON ERROR PRINT "outer": ON ERROR: STOP
20 PROC inner()
30 PRINT "not reached"
40 STOP
50 DEFPROC inner()
60   ON ERROR PRINT "inner ";: ERROR
70   PRINT 1/0
80 ENDPROC
```

```forth
NEEDS CATCH
NEEDS THROW
NEEDS [']
: CHECKED/  ( a b -- q )
    DUP 0= IF  -10 THROW  THEN  / ;
: RISKY  ( -- )  1 0 CHECKED/ . ;
: INNER  ( -- )
    ['] RISKY CATCH
    ?DUP IF  ." inner "  THROW  THEN ;
: OUTER  ( -- )
    ['] INNER CATCH
    ?DUP IF  ." outer " .  THEN ;
OUTER                           \ => inner outer -10
RISKY                           \ => RISKY? Division by zero.
```

`/` does not stop on a zero divisor: `1 0 /` quietly gives -1
([Chapter 6](06-expressions.md)). So the error that BASIC raises by itself
is raised here by hand: `CHECKED/` tests the divisor and throws -10, the
standard code for division by zero, before dividing. Where `SAFE/` above
gives a substitute result, `CHECKED/` gives up and leaves the decision to
the caller.

`INNER` catches the error, says so, and throws the same number again;
`OUTER` catches that and stops it there. Called on its own, with no `CATCH`
around it, `RISKY` ends in the usual report. The trap is not *inside* the
word that may fail, as `ON ERROR` is: it is in the word that calls it.

## No equivalent

- **Default values and omitted parameters.** Every word takes a fixed number
  of arguments. Write a second word that supplies the missing one.
- **`Q Parameter error`.** Neither the number of arguments nor what they are
  is checked. The stack comment is the only declaration: keep it true.
- **Taking only some of the results.** `PROC ... TO` may name fewer
  variables than `ENDPROC` returns. In Forth every result is on the stack
  and has to be used or dropped.
- **A named work variable that is neither parameter nor result.** The names
  between `{` and `}` are arguments or, after `--`, results. Anything else
  stays on the stack or goes through `>R` and `R>`.
- **Local strings and local arrays.** A local is one cell. A string takes
  two, its address and its length, and they can be two locals; a local array
  (`LOCAL z()` and `DIM`) has no counterpart.
- **`PRIVATE` as real privacy.** A `VARIABLE` is visible to everything
  defined after it. Vocabularies (tutorial 018) are the way to hide names.
- **`BANK n PROC`.** vForth words are not split over memory banks: see
  [Chapter 23](23-the-memory.md).

## Further reading

- Tutorial `005` -- `:` and `;`, stack comments, building words from words.
- Tutorial `002` -- `DUP`, `SWAP`, `OVER`, `ROT`: what replaces the names.
- Tutorial `012` -- the return stack, `>R`, `R>`, `R@`, and its rules.
- Tutorial `061` -- named locals: `{ ... }`, results after `--`, the cost.
- Tutorial `026` -- `CATCH` and `THROW`.
- Tutorial `018` -- vocabularies, for names that must stay hidden.
- Tutorial `008` -- addresses, `@` and `!`: the ground under "by reference".
- `HELP :`, `HELP EXIT`, `HELP RECURSE`, `HELP LOCALS`, `HELP DEFER`,
  `HELP DEPTH`, `HELP .S`, `HELP BOUNDS`, `HELP CATCH`, `HELP THROW`.
- vForth manual, sections 2.12.2 "Stack manipulation" and 2.12.9
  "Definition related".

<!-- nav -->
---

Previous: [Chapter 3 - Looping](03-looping.md) |
[Contents](README.md) |
Next: [Chapter 5 - READ, DATA, RESTORE](05-read-data-restore.md)
