# Chapter 5 - READ, DATA, RESTORE

[From NextBASIC to vForth](README.md)

Manual: Chapter 5, pp. 35-36.

## In short

None of the three keywords exists in vForth, and all that they do carries
over. BASIC scatters `DATA` lines through the program and reads them in
order, with a pointer you cannot see. Forth puts the values in a *table*: a
stretch of memory with a name, built with `CREATE` and `,`, from which any
element can be fetched at any time. `READ` becomes a fetch, `RESTORE`
becomes "start again from index 0", and reading in sequence, when that is
really what you want, takes two short definitions. What you have to relearn:
a table does not know where it ends, nor what is in it.

## What changes

**The data has a name.** `CREATE` gives a name to the next free place in
memory, and `,` stores one number there and moves on. From then on the name
pushes the address of the first value.

```forth
CREATE PRIMES  2 , 3 , 5 , 7 , 11 , 13 ,
PRIMES @ .                      \ => 2
```

All the `DATA` lines of a BASIC program form one list. In Forth there are as
many tables as you care to name, each one separate from the others.

**The comma is a word.** In `DATA 2,3,5` the commas separate. In Forth `,`
is a word that takes the number before it and stores it, so it needs a space
on each side and it follows *every* number, the last one too. Leave the last
comma out and the last number stays on the stack instead of going into the
table.

**The values are worked out when the table is built.** Anything that leaves
a number can stand before a `,`:

```forth
CREATE SIZES  8 , 8 2 * , 8 8 * ,
SIZES 2 CELLS + @ .             \ => 64
```

BASIC evaluates the expressions of a `DATA` line each time it reads them;
here the table holds the three results and nothing else.

**You fetch by index, in any order.** Element `i` lives `i` cells after the
start, counting from 0, and `CELLS` turns a number of cells into a number of
bytes (two for each). There is no pointer to move and nothing has to be
read first:

```forth
: PRIME  ( i -- n )  CELLS PRIMES + @ ;
4 PRIME .                       \ => 11
0 PRIME .                       \ => 2
```

**A table can do its own indexing.** Writing a word like `PRIME` for every
table soon gets tedious. `DOES>` lets you define a new kind of table once,
and say in the same place what its tables do when their name is used:

```forth
: TABLE:  ( -- )  CREATE  DOES>  SWAP CELLS + @ ;
TABLE: SQUARE  0 , 1 , 4 , 9 , 16 , 25 ,
3 SQUARE .                      \ => 9
5 SQUARE .                      \ => 25
```

`TABLE: SQUARE` creates `SQUARE`, the commas fill it as before, and
`3 SQUARE` runs the words after `DOES>` with the address of the table on top
of the index. Tutorial 010 explains the mechanism.

**There is no `READ` pointer, unless you make one.** Reading the next value
each time needs somewhere to remember the position, and that is a variable:

```forth
VARIABLE NEXT#
: RESTORE  ( -- )  0 NEXT# ! ;
: READ  ( -- n )  NEXT# @ PRIME  1 NEXT# +! ;
READ . READ . READ .            \ => 2 3 5
RESTORE
READ .                          \ => 2
```

That is the whole of BASIC's machinery, for one table. `RESTORE n`, which
moves the pointer to the `DATA` of a given line, becomes a store of any
index you like: `3 NEXT# !` makes the next `READ` give 7. More often the
variable is not needed at all, because a loop already has a counter.

**A table does not know where it ends.** There is no `Out of DATA`. A fetch
past the last element returns whatever lies in memory after the table,
without complaint, and a store there damages the next definition. The
program has to know the size, and the surest way is to let Forth count it
when the table is built: `HERE` is the next free address, so right after the
last comma the difference from the start is the size in bytes.

```forth
CREATE EVENS  2 , 4 , 6 , 8 ,
HERE EVENS - 2 /  CONSTANT #EVENS
#EVENS .                        \ => 4
```

The line with `HERE` must come immediately after the table: any definition
in between would be counted as part of it.

**A table does not know what it holds.** A `DATA` list may mix numbers and
strings, and NextBASIC can ask which kind comes next. A table is bytes: the
program that built it knows that the first cell is a price and that a name
follows it. Mixed data is laid out as a *record* of a fixed shape, as in the
last example below.

**Small numbers can take one byte.** `,` stores a 16-bit cell. For values
from 0 to 255 `C,` stores a single byte and `C@` fetches it: the table is
half the size and the index needs no `CELLS`.

**A string is stored with its length.** `,"` takes the text up to the next
`"` and stores it as a *counted string*: one byte with the length, then the
characters. `COUNT` turns the address of a counted string into the address
of its first character and the length, which is what `TYPE` wants.

```forth
CREATE TODAY  ," January 1st"
TODAY COUNT TYPE                \ => January 1st
```

After the characters `,"` stores one byte more, a zero, which the length
does not count. It is not wasted: NextZXOS wants its file names closed by
a zero, and [Chapter 7](07-strings.md) tells the rest. Here a string is
a table of bytes like any other, read with `C@`, and the zero at the end
is a *sentinel*, the same trick as the `-1` a BASIC program puts at the
end of its `DATA` to know when to stop reading. A loop that reads
characters until it finds the zero needs no length:

```forth
: ZTYPE  ( a -- )  BEGIN  COUNT ?DUP WHILE  EMIT  REPEAT  DROP ;
TODAY 1+ ZTYPE                  \ => January 1st
```

`TODAY 1+` skips the length byte. `COUNT` fetches a character and steps
to the next one; the zero ends the loop.

Strings of different lengths cannot be found by multiplying an index, so a
list of strings is built as a table of *addresses*: see "Side by side".

**A table can be written to.** `DATA` is read-only. A table is ordinary
memory, and `!` changes an element as easily as `@` reads it. A table whose
values are all computed later is made with `ALLOT`, which reserves bytes
without filling them: `CREATE SCORES 10 CELLS ALLOT`. That is the array of
[Chapter 11](11-arrays.md).

**It works at the prompt.** A `DATA` line typed as a direct command is
wasted. `CREATE` and `,` are ordinary words: a table can be built by hand,
tried, and thrown away with `FORGET`.

## Correspondence table

| NextBASIC | vForth | Note |
|---|---|---|
| `DATA n1,n2,n3` | `CREATE t  n1 , n2 , n3 ,` | A comma after every number. |
| `DATA` with expressions | the same: `8 8 * ,` | Worked out once, when the table is built. To work them out at each `READ`, see "No equivalent". |
| `READ v` (element `i`) | `t i CELLS + @` | `i` counts from 0. Any order. |
| `READ a,b,c` | one fetch for each | |
| `READ` in a `FOR` loop | `t n CELLS BOUNDS DO  I @` ... `2 +LOOP` | `I` is the address of each element. |
| `READ`, the next one each time | a variable as index | See `READ` above. |
| `RESTORE` | `0 p !` | `p` is your own index variable. |
| `RESTORE n` | `k p !` | Or simply another table. |
| number of items | `HERE t - 2 /` right after the table | Nothing checks it for you. |
| `DATA "text"` | `CREATE s  ," text"` | Counted string, 255 characters at most, closed by a zero. |
| `READ a$: PRINT a$` | `s COUNT TYPE` | |
| `DATA` of small numbers | `C,` to store, `C@` to fetch | One byte each, 0 to 255. |
| a table that takes its index | `CREATE` ... `DOES>` | See `TABLE:` above. |
| changing an item | `n t i CELLS + !` | |
| `DATA` (the function) | - | See "No equivalent". |
| `Out of DATA` | - | See "No equivalent". |
| `BANK n RESTORE` | - | [Chapter 23](23-the-memory.md). |

## Side by side

**Three values.** The volume of a box.

```
10 READ w,h,d
20 PRINT w*h*d
30 DATA 2,3,4
```

```forth
CREATE BOX  2 , 3 , 4 ,
BOX @  BOX CELL+ @ *  BOX 2 CELLS + @ * .       \ => 24
```

The variables `w`, `h` and `d` were only stepping stones between the list
and the product, and are gone. `CELL+` adds the size of one cell to an
address.

**Reading in a loop.** The days of the first five months.

```
10 FOR n=1 TO 5
20   READ d: PRINT d;" ";
30 NEXT n
40 DATA 31,28,31,30,31
```

```forth
CREATE MONTHS  31 , 28 , 31 , 30 , 31 ,
: .MONTHS  ( -- )
    MONTHS 5 CELLS BOUNDS DO
        I @ .
    2 +LOOP ;
.MONTHS                         \ => 31 28 31 30 31
```

`BOUNDS` turns an address and a size in bytes into the limit and the start
of a `DO` loop. The loop then walks through memory two bytes at a time, and
`I` is the address of each element in turn.

**Finding the n-th value.** How many days in a given month?

```
10 INPUT m
20 RESTORE
30 FOR i=1 TO m: READ d: NEXT i
40 PRINT d
50 DATA 31,28,31,30,31,30,31,31,30,31,30,31
```

BASIC has to read and throw away everything that comes before. The table
goes straight there, and since no value is above 255 it is a table of
bytes:

```forth
CREATE MDAYS
    31 C, 28 C, 31 C, 30 C, 31 C, 30 C,
    31 C, 31 C, 30 C, 31 C, 30 C, 31 C,
: DAYS-IN  ( month -- days )  1- MDAYS + C@ ;
2 DAYS-IN .                     \ => 28
12 DAYS-IN .                    \ => 31
```

The `1-` is there because months are counted from 1 and bytes from 0.

**Strings.** Three colour names.

```
10 FOR i=1 TO 3
20   READ c$: PRINT c$;" ";
30 NEXT i
40 DATA "red","green","blue"
```

Each string gets a name of its own, and a table holds the three addresses:

```forth
CREATE C0  ," red"
CREATE C1  ," green"
CREATE C2  ," blue"
CREATE COLOURS  C0 , C1 , C2 ,
: COLOUR  ( i -- )  CELLS COLOURS + @  COUNT TYPE ;
1 COLOUR                        \ => green
: .COLOURS  ( -- )  3 0 DO  I COLOUR SPACE  LOOP ;
.COLOURS                        \ => red green blue
```

`C0 ,` stores in `COLOURS` the address that `C0` pushes. All the elements of
`COLOURS` are one cell wide, whatever the length of the names, and so they
can be indexed.

**Numbers and strings together.** A price list.

```
10 FOR i=1 TO 2
20   READ n$,p: PRINT n$;" ";p
30 NEXT i
40 DATA "tea",120,"cake",250
```

```forth
CREATE TEA   120 , ," tea"
CREATE CAKE  250 , ," cake"
: .ITEM  ( addr -- )
    DUP CELL+ COUNT TYPE SPACE
    @ . ;
TEA .ITEM                       \ => tea 120
CAKE .ITEM                      \ => cake 250
```

Each item is a record: one cell with the price, then the name. `.ITEM` knows
that shape, and that knowledge is all there is in place of BASIC's types:
the price is at the address itself, the name one cell further on. A list of
items would be a table of their addresses, like `COLOURS`.

**Data worked out when it is read.** An item of `DATA` may be any
expression, and BASIC works it out at the moment of `READ`, with the values
the variables have then.

```
10 LET x=5
20 READ a,b,c: PRINT a;" ";b;" ";c
30 LET x=10: RESTORE
40 READ a,b,c: PRINT a;" ";b;" ";c
50 DATA x,x*2,x*x
```

A table cannot do this: it holds numbers, not expressions. What can hold an
expression is text, and the natural place for text in Forth is a Screen of
the block file. Here each line of Screen 10 (the one left free for the
user: pick any Screen you do not use, since the example writes over it) is
one item, kept as Forth source:

```forth
NEEDS EVALUATE
NEEDS S"
10 CONSTANT DATA-SCR
: DATA-LINE  ( n -- a )  8 /MOD  DATA-SCR 2* +  BLOCK  SWAP 64 * + ;
: LINE!  ( a u n -- )  DATA-LINE  DUP 64 BLANK  SWAP CMOVE  UPDATE ;
VARIABLE DATA#
: RESTORE-LINE  ( n -- )  DATA# ! ;
: READ-LINE  ( -- ? )
    DATA# @ DATA-LINE  PAD 64 CMOVE  PAD 64 EVALUATE
    1 DATA# +! ;
VARIABLE X
S" X @" 0 LINE!
S" X @ 2 *" 1 LINE!
S" X @ DUP *" 2 LINE!
5 X !  0 RESTORE-LINE
READ-LINE . READ-LINE . READ-LINE .     \ => 5 10 25
10 X !  0 RESTORE-LINE
READ-LINE . READ-LINE . READ-LINE .     \ => 10 20 100
```

A Screen is 16 lines of 64 characters, kept in two 512-byte blocks:
`DATA-LINE` finds the block of line `n` and the place of the line in it.
`LINE!` writes a line and marks the block with `UPDATE`, so that vForth
saves it to the file; `FLUSH` saves it at once. On the machine the lines
are usually typed with `EDIT` (`10 LIST EDIT`,
[Chapter 19](19-nextzxos-and-alternatives.md)) rather than with
`LINE!`. `READ-LINE` copies
the line to `PAD` and hands it to `EVALUATE`, the interpreter itself, which
runs it with the value `X` has at that moment. `RESTORE-LINE` is
`RESTORE n`, with a line number in place of a BASIC line number.

A line may leave more than one value, like a `DATA` line with several
items, but they all arrive together, the last one on top. Any word can
appear in a line, not only arithmetic: what BASIC limits to an expression,
the interpreter takes as a whole program. And the data outlives the
program: it stays in the block file between sessions, and can be changed
with `EDIT` without compiling anything again. `10 LOAD` interprets the
whole Screen in one go, and leaves all its values at once.

The lines need not be typed on the machine at all. Two small utilities
copy a Screen to and from an ordinary text file, which can then be
written or kept on a PC. `10 SCREEN-FROM-FILE name` fills Screen 10
with the first 16 lines of the file, 64 characters each at most, and
`10 SCREEN-TO-FILE name` writes Screen 10 out, one line of text per
line of the Screen, without the trailing spaces, to a new file: if the
file is already there it stops with `NextZXOS Write error.` and leaves
it alone. Each is loaded with
`NEEDS` and its own name. The name is read from the line,
without quotes, as `OPEN<` does in
[Chapter 20](20-channels-streams-drivers-and-windows.md). Tutorial `063`
uses them, and keeps binary data in blocks too.

## No equivalent

- **One `DATA` list for the whole program.** Lines of `DATA` anywhere in a
  listing are joined into a single list. A table is all in one place, and
  two tables have nothing to do with each other.
- **`Out of DATA`.** Nothing stops a fetch beyond the end. Keep the count,
  as `#EVENS` does, and use it as the limit of the loop.
- **`DATA` as a function**, which tells whether the next item is a number,
  a string or missing. A table carries no types. If the kind of each item
  really varies, store a byte in front of it that says so.
- **Expressions worked out at `READ` time.** A `DATA` item may be any
  expression, and it is worked out when it is read, with the variables as
  they are then. A table only holds what was worked out when it was built.
  The nearest thing is data kept as text, one item per line of a Screen,
  and read with `EVALUATE`: see "Data worked out when it is read" in "Side
  by side". It goes further than `DATA`, since a line may hold any Forth.
- **`READ` into a list of variables.** Each fetch is written out, and its
  result stays on the stack unless you store it.
- **`BANK n RESTORE`**, data kept in a memory bank: see
  [Chapter 23](23-the-memory.md).

## Further reading

- Tutorial `069` -- data tables: a table that knows its length, `READ`
  and `RESTORE` with an "out of data" error, search by key, `ON` as a
  table of words.
- Tutorial `008` -- memory: `@`, `!`, `C@`, `C!`, `,`, `ALLOT`, `HERE`.
- Tutorial `010` -- `CREATE` and `DOES>`: words that define tables.
- Tutorial `023` -- records with named fields.
- Tutorial `007` -- `DO` loops and `BOUNDS`.
- Tutorial `009` -- counted strings, `COUNT` and `TYPE`.
- Tutorial `063` -- blocks as a store of data: `SCREEN-TO-FILE`,
  `SCREEN-FROM-FILE`, `LOAD2BLOCK`.
- `HELP CREATE`, `HELP ,`, `HELP C,`, `HELP ,"`, `HELP CELLS`,
  `HELP BOUNDS`, `HELP DOES>`, `HELP ALLOT`, `HELP HERE`, `HELP COUNT`.
- vForth manual, sections 2.12.6 "Memory" and 2.12.9 "Definition related".

<!-- nav -->
---

Previous: [Chapter 4 - Procedures and Subroutines](04-procedures-and-subroutines.md) |
[Contents](README.md) |
Next: [Chapter 6 - Expressions](06-expressions.md)
