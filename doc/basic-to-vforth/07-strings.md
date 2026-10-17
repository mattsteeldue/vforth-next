# Chapter 7 - Strings

[From NextBASIC to vForth](README.md)

Manual: Chapter 7, pp. 49-51.

## In short

This is the chapter where BASIC does most for you and Forth least. BASIC
has a string *type*: a `$` variable holds text of any length, `+` joins,
`( TO )` slices, and the memory looks after itself. Forth has no string
type at all. A string is a run of bytes in memory, and what travels on the
stack is two numbers: where it starts and how long it is. Slicing turns
out to be simple arithmetic on those two numbers, and is cheaper than in
BASIC. Everything that makes a *new* string (joining, assigning, changing
case) needs room that you provide yourself, and most of the words are four
or five definitions that you write once. They are all in this chapter.

## What changes

**A string is an address and a length.** Wherever BASIC passes a string,
Forth passes two cells: the address of the first character, and the number
of characters on top. Stack comments call the pair `a n`. `TYPE` takes
such a pair and prints it.

```forth
NEEDS S"
: PLANET  ( -- a n )  S" Spectrum" ;
PLANET TYPE                     \ => Spectrum
PLANET NIP .                    \ => 8
```

`S"` (`NEEDS S"`) is the string literal: it leaves the `a n` of the text
up to the next `"`. So `LEN a$` is no function: the length is already
there, and `NIP` throws away the address to leave it alone. Since a string
takes two places on the stack, the stack words for it are the double ones:
`2DUP`, `2DROP`, `2SWAP`, `2OVER`.

**There are three ways to write a text.** `." text"` prints it and leaves
nothing. `S" text"` leaves `a n` and prints nothing. Both work inside
a definition and at the prompt. `," text"` stores the text in the
dictionary, after a `CREATE`, as in [Chapter 5](05-read-data-restore.md).

The text of an `S"` is kept in the heap, a part of memory that vForth
brings into view when it is needed. Use the pair straight away, as every
example here does, or copy the text into a buffer of your own; and do not
write into it.

**A string variable is a buffer you reserve.** `LET a$="..."` finds room
for whatever you assign. In Forth you decide the room once, when you
create the variable, and it never grows. The usual shape is the *counted
string*: one byte with the current length, then the characters.

```forth
CREATE NAME$  32 ALLOT
```

`NAME$` is 32 bytes: a length and up to 31 characters. The `$` is just
part of the name, kept here to make the listings easy to compare. The word
`COUNT` turns the address of a counted string into the `a n` pair:
`NAME$ COUNT TYPE` is `PRINT n$`. A counted string holds 255 characters at
most.

**Assignment is a copy, and you write the word for it.** There is no
ready-made "store this string there", so here it is. It stores the length
in the first byte and copies the characters after it.

```forth
: $!  ( a n dest -- )  2DUP C!  1+ SWAP CMOVE ;
PLANET NAME$ $!
NAME$ COUNT TYPE                \ => Spectrum
NAME$ C@ .                      \ => 8
```

`CMOVE` copies bytes: from, to, how many. `$!` is to strings what `!` is
to numbers. `LET b$=a$` is `A$ COUNT B$ $!`, and the empty string is a
zero in the length byte: `0 NAME$ C!`. Do not try to write an empty
literal: `S" "` is not the empty string, it swallows the rest of the
line.

**Nothing checks the room.** `$!` copies as many characters as it is
given. Forty characters sent to `NAME$` overwrite whatever comes after it
in memory, with no error and no warning. Either make the buffer as long as
the longest text it will ever hold, or cut the text first: `31 MIN` after
a pair keeps at most 31 characters.

**A slice is arithmetic, and it copies nothing.** To drop characters from
the front, move the address forward and shorten the length by as much. To
drop them from the end, shorten the length. That is all a slice is.
vForth has no word for the first operation; in other Forths it is called
`/STRING`, and it takes one line:

```forth
: /STRING  ( a n k -- a2 n2 )  ROT OVER + -ROT - ;
PLANET 2 /STRING TYPE           \ => ectrum
PLANET 3 MIN TYPE               \ => Spe
```

`k /STRING` drops the first `k` characters, so `a$(3 TO )` is
`2 /STRING`. Keeping the first `k` characters is just `k MIN` on the
length: `a$( TO 3)`. The two together give BASIC's general slice, with the
same numbering from 1:

```forth
: SLICE  ( a n from to -- a2 n2 )
    OVER - 1+ >R  1- ROT + NIP  R> ;
PLANET 2 5 SLICE TYPE           \ => pect
PLANET 3 3 SLICE TYPE           \ => e
```

The result is not a new string: it is another pair that points into the
same bytes. Nothing is copied, which makes slicing nearly free; but if the
original changes, so does the slice. And nothing is checked: there is no
`Subscript wrong`, and a slice that runs past the end shows whatever
memory holds there.

**One character is a byte.** `C@` fetches a byte from an address, so the
third character is two bytes after the first. In a counted string the
length byte makes the sum come out like BASIC's: character 3 is at the
address plus 3.

```forth
PLANET DROP 2 + C@ EMIT         \ => e
NAME$ 3 + C@ EMIT               \ => e
```

`C@` leaves the code of the character, a number; `EMIT` prints the
character with that code. Characters and their codes are the subject of
Chapter 13.

**Joining needs a place to put the result.** `a$+b$` makes a third
string, and BASIC finds the room for it. In Forth you append to a buffer
that is long enough. Again one definition does it:

```forth
: $+!  ( a n dest -- )
    >R  DUP R@ C@ +  -ROT
    R@ COUNT + SWAP CMOVE
    R> C! ;
: SUFFIX  ( -- a n )  S"  Next" ;
SUFFIX NAME$ $+!
NAME$ COUNT TYPE                \ => Spectrum Next
NAME$ C@ .                      \ => 13
```

`$+!` copies the new characters after the last one and adds their number
to the length byte, as `+!` adds to a number. It checks the room no more
than `$!` does. Often there is no need to build the string at all: to
*print* two strings one after the other, `TYPE` them one after the other.

**Assigning to a slice is `CMOVE`.** BASIC's assignment to a substring
never changes the length of the string: the new text is cut or padded to
fit. `CMOVE` onto a part of the buffer does the same by nature, because
it copies exactly the number of bytes you say and touches nothing else.

```forth
: STARS  ( -- a n )  S" ******" ;
STARS DROP NAME$ 10 + 4 CMOVE
NAME$ COUNT TYPE                \ => Spectrum ****
```

Six stars were on offer; four were asked for, starting at character 10.
To pad with spaces instead, fill the part first: `BLANK` takes an address
and a length and stores spaces there.

**The modifiers are small loops.** `[+]`, `[-]`, `[<]` and `[>]` have one
ready-made counterpart, `-TRAILING`, which shortens a pair to leave out
the spaces at the end. `UPPER` converts one character. The rest is built
from them, and each is a line or two: see "Side by side". Mind one
difference: `-TRAILING` and a word that skips leading spaces only change
the pair, as a slice does; a word that changes case writes into the
string itself, so it must work on a copy in a buffer, not on a literal.

**Comparing is `COMPARE`.** `a$=b$` and `a$<b$` are `COMPARE 0=` and
`COMPARE 0<` (`NEEDS COMPARE`): see [Chapter 2](02-decisions.md). As
vForth starts, capitals and small letters count as equal:

```forth
NEEDS COMPARE
: SAME?  ( -- )  S" next" S" NEXT" COMPARE . ;
SAME?                           \ => 0
```

Chapter 13 shows how to change that.

**There is a scratch buffer.** `PAD` leaves the address of a work area of
at least 84 bytes that belongs to nobody. It is the place for a string
that is needed for a moment: text typed by the user (Chapter 1 reads it
there with `ACCEPT`), a string being put together before it is printed.
It is overwritten freely, by you and by the system, so nothing is kept
there for long.

## Correspondence table

| NextBASIC | vForth | Note |
|---|---|---|
| `"text"` | `S" text"` | `NEEDS S"`. Leaves `a n`. |
| `PRINT "text"` | `." text"` | Inside a definition or at the prompt. |
| `PRINT a$` | `a n TYPE` | |
| `a$` (a variable) | `CREATE A$ 32 ALLOT` | Counted string: length byte, then the text. Fixed room. |
| the value of `a$` | `A$ COUNT` | Leaves `a n`. |
| `LET a$="text"` | `S" text" A$ $!` | `$!` is defined in this chapter. |
| `LET b$=a$` | `A$ COUNT B$ $!` | A copy. |
| `LET a$=""` | `0 A$ C!` | |
| `LEN a$` | `A$ C@` | For a pair `a n` it is `n`: `NIP`. |
| `a$(n)` | `A$ n + C@` | The code of the character. From a pair: `DROP n 1- + C@`. |
| `a$(m TO n)` | `a n m n SLICE` | Defined here. Copies nothing, checks nothing. |
| `a$( TO n)` | `a n n MIN` | |
| `a$(m TO )` | `a n m 1- /STRING` | Defined here. |
| `a$(m TO n)="text"` | `CMOVE` onto `A$ m +` | The length never changes, as in BASIC. |
| `a$+b$` | `b n A$ $+!` | Appends to `A$`. Defined here. No check of room. |
| `PRINT a$+b$` | `TYPE` twice | No new string is needed. |
| `a$*n` | a loop of `TYPE` | `TIMES`, below. |
| `a$*-1` | a loop of `C@ EMIT`, backwards | `BACKWARDS`, below. |
| `a$[+]` | `UPPER` on each character | `UPCASE`, below. Changes the string in place. |
| `a$[-]` | -- | `LOWCASE`, below. |
| `a$[>]` | `a n -TRAILING` | Changes only the length of the pair. |
| `a$[<]` | -- | `-LEADING`, below. |
| `a$[(f$,r$)]` | -- | See "No equivalent". |
| `a$[~]`, `a$[^]` | -- | See "No equivalent". |
| `{a$}` | -- | No tokens in Forth. |
| `a$=b$` | `COMPARE 0=` | `NEEDS COMPARE`. Case is ignored at start-up. |
| `a$<b$` | `COMPARE 0<` | |
| `3 Subscript wrong` | no error | A slice past the end shows other memory. |

## Side by side

**Slices in a loop.** A word, one letter more on each line.

```
10 LET a$="Spectrum"
20 FOR n=1 TO LEN a$
30   PRINT a$( TO n)
40 NEXT n
```

```forth
: TRIANGLE  ( a n -- )
    1+ 1 DO  DUP I CR TYPE  LOOP  DROP ;
PLANET TRIANGLE
```

```text
S
Sp
Spe
Spec
Spect
Spectr
Spectru
Spectrum
```

The address stays on the stack for the whole loop and `I` is the length:
no slicing word is even needed. Going the other way, one letter less from
the front each time, shows the usual shape of a Forth loop over a string:
work on the pair, then chop off the first character, until the length is
zero.

```forth
: TAILS  ( a n -- )
    BEGIN  DUP WHILE
        CR 2DUP TYPE  1 /STRING
    REPEAT  2DROP ;
PLANET TAILS
```

```text
Spectrum
pectrum
ectrum
ctrum
trum
rum
um
m
```

**Joining.** A greeting made of three pieces.

```
10 LET n$="Spectrum"
20 LET g$="Hello, "+n$+"!"
30 PRINT g$
40 PRINT LEN g$
```

```forth
CREATE G$  40 ALLOT
: GREETING  ( a n -- )
    S" Hello, " G$ $!   G$ $+!   S" !" G$ $+! ;
PLANET GREETING
G$ COUNT TYPE                   \ => Hello, Spectrum!
G$ C@ .                         \ => 16
```

The first piece is stored, the others are appended. The name arrives on
the stack and waits there while `Hello, ` goes in. If the greeting is only
to be printed, none of this is needed:

```forth
: GREET  ( a n -- )  ." Hello, " TYPE ." !" ;
PLANET GREET                    \ => Hello, Spectrum!
```

**Writing over a part.** Hide all of a number but its last four digits.

```
10 LET c$="1234567890123456"
20 LET c$( TO 12)="************"
30 PRINT c$
```

```forth
CREATE CARD$  20 ALLOT
: CARD  ( -- a n )  S" 1234567890123456" ;
CARD CARD$ $!
CARD$ 1+ 12 42 FILL
CARD$ COUNT TYPE                \ => ************3456
```

Twelve equal characters do not have to be copied from anywhere: `FILL`
takes an address, a length and a character code (42 is the star) and
stores that character all along. The `1+` steps over the length byte.

**Trimming and capitals.**

```
10 LET a$="   hello there   "
20 PRINT a$[<>+];"."
```

```forth
: -LEADING  ( a n -- a2 n2 )
    BEGIN
        DUP IF  OVER C@ BL =  ELSE  0  THEN
    WHILE  1 /STRING  REPEAT ;
: UPCASE  ( a n -- )
    BOUNDS ?DO  I C@ UPPER I C!  LOOP ;
: UNTIDY  ( -- a n )  S"    hello there   " ;
: TIDY  ( a n -- )
    -LEADING -TRAILING  NAME$ $!
    NAME$ COUNT UPCASE ;
UNTIDY NIP .                    \ => 17
UNTIDY TIDY
NAME$ COUNT TYPE                \ => HELLO THERE
NAME$ C@ .                      \ => 11
```

`-LEADING` chops off the first character for as long as there is one and
it is a space (`BL` is the code of the space). Trimming only changed the
pair; then the text was copied to `NAME$`, and the copy was put in
capitals where it lies. `BOUNDS` turns a pair into the two limits that
`?DO` wants, so that `I` is the address of each character in turn.

There is no word for small letters, so here is one. A letter from `A` to
`Z` becomes a small one by adding 32 to its code:

```forth
NEEDS WITHIN
: LOWER  ( c -- c2 )  DUP 65 91 WITHIN IF  32 +  THEN ;
: LOWCASE  ( a n -- )
    BOUNDS ?DO  I C@ LOWER I C!  LOOP ;
NAME$ COUNT LOWCASE
NAME$ COUNT TYPE                \ => hello there
```

**Repeating and reversing.**

```
10 PRINT "ab"*3
20 PRINT "Spectrum"*-1
```

```forth
: TIMES  ( a n k -- )
    0 ?DO  2DUP TYPE  LOOP  2DROP ;
: AB  ( -- a n )  S" ab" ;
AB 3 TIMES                      \ => ababab
: BACKWARDS  ( a n -- )
    DUP 0 ?DO  1- 2DUP + C@ EMIT  LOOP  2DROP ;
PLANET BACKWARDS                \ => murtcepS
```

Both words print; neither builds a string. That is the usual choice in
Forth: a new string is made only when it has to be kept.

## No equivalent

- **A string type with its own memory.** No variable grows, no room is
  found for a result, and nothing is given back when a string is no
  longer needed. You reserve the buffers and you know their sizes.
- **Strings longer than 255 characters** as counted strings. A longer
  text is a buffer with its length kept in a cell, or in a `VARIABLE`.
- **`+` that makes a new string.** `$+!` appends to an existing one. (The
  heap has a word `+"` that extends a string kept there; it is not what
  this chapter uses.)
- **Checked subscripts.** No `Subscript wrong` and no `Integer out of
  range`: a wrong slice reads other memory, a wrong store damages it.
- **`[(f$,r$)]`, replacing or deleting characters.** Nothing ready-made.
  It is a loop like `UPCASE` with a table lookup in the middle.
- **`[~]` and `[^]`, the bit 7 terminator.** Forth strings carry their
  length and have no terminator to add or remove.
- **`{a$}`, tokenising.** There are no tokens: a Forth word in a string is
  its letters. Running a string as Forth is `EVALUATE`, in Chapter 8.
- **Fractional repetition**, `a$*1.5`. Print the string once, then the
  first part of it with `MIN` on the length.
- **Searching inside a string.** vForth has no ready-made word for it yet.

## Further reading

- Tutorial `009` -- strings as memory: `CMOVE`, `FILL`, `BLANK`, `COUNT`,
  `,"`, `TYPE`, `-TRAILING`, `PAD`.
- Tutorial `008` -- addresses and bytes: `C@`, `C!`, `ALLOT`.
- Tutorial `003` -- output: `."`, `TYPE`, `EMIT`.
- Tutorial `016` -- input: `ACCEPT`, `UPPER`.
- Tutorial `021` -- `EVALUATE`: a string run as Forth.
- `HELP S"`, `HELP ,"`, `HELP COUNT`, `HELP TYPE`, `HELP CMOVE`,
  `HELP FILL`, `HELP BLANK`, `HELP -TRAILING`, `HELP UPPER`, `HELP BOUNDS`,
  `HELP COMPARE`, `HELP PAD`.
- vForth manual, sections 2.12.6 "Memory" and 2.12.11 "Numbers &
  strings"; the "Heap memory facility" section for where `S"` keeps its
  text.

<!-- nav -->
---

Previous: [Chapter 6 - Expressions](06-expressions.md) |
[Contents](README.md) |
Next: [Chapter 8 - Functions](08-functions.md)
