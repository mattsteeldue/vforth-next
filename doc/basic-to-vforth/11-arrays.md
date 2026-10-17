# Chapter 11 - Arrays

[From NextBASIC to vForth](README.md)

Manual: Chapter 11, pp. 67-70.

## In short

Forth has no `DIM` and no array type, and it does not need them: an array
is a block of memory with a name, and an element is an address you work
out. `CREATE` gives the name, `ALLOT` reserves the room, `@` and `!` read
and write. Three lines of Forth then make a word that builds arrays the
BASIC way, with the index in front of the name. What you lose is the
safety net: indices start from 0, nothing is checked, and nothing is set
to zero unless you ask.

## What changes

**An array is named memory.** `CREATE` reads a name from the text on its
right, as `VARIABLE` does in [Chapter 1](01-basic-programming-concepts.md),
and `ALLOT` reserves bytes after it. Ten numbers take ten cells:

```forth
CREATE SCORE  10 CELLS ALLOT
SCORE 10 CELLS ERASE
43 SCORE 3 CELLS + !
SCORE 3 CELLS + @ .             \ => 43
```

`SCORE` leaves the address of the first element, `3 CELLS +` moves on to
the fourth, and `!` and `@` do the rest. This is the `DIM b(10)` of BASIC
written out by hand; tutorial `008` has the details.

**Indices start from 0.** `SCORE 0 CELLS +` is the first element and
`SCORE 9 CELLS +` the last. There are two ways to keep BASIC's numbering:
subtract 1 when you work out the address, or reserve one element more and
leave element 0 unused. The second is simpler and costs one cell; this
chapter uses it for the months, in "Side by side".

**Nothing is set to zero.** `DIM` clears the array it makes. `ALLOT` only
reserves: the memory holds whatever was there before. `ERASE` writes
zeros over a number of bytes, `BLANK` writes spaces, which is the
starting value of a BASIC string array. Calling `ERASE` again is also how
you clear an array that is already in use, which BASIC does with a second
`DIM`.

**A defining word puts the index in front.** Working out `3 CELLS +` each
time is tedious. A defining word (tutorial `010`) does it once, inside
the array:

```forth
: ARRAY  ( n -- )
    CREATE  CELLS HERE OVER ERASE ALLOT
    DOES>  ( i pfa -- addr )  SWAP CELLS + ;
10 ARRAY M
43 3 M !
3 M @ .  4 M @ .                \ => 43 0
```

`10 ARRAY M` makes an array of ten cells, already cleared. When `M` runs
it takes the index from the stack and leaves the address of that element,
which serves both for reading, `3 M @`, and for writing, `43 3 M !`.

This is a good place to look again at the two directions of a Forth line.
`10 ARRAY M` takes its size from the left and its name from the right,
and reads best from the right: "M is an array of 10". `43 3 M !` is
BASIC's `LET m(3)=43` turned round: the value first, then the place, then
the order to store it.

**More dimensions are one multiplication more.** A matrix keeps its number
of columns in the first cell, and works out `row*columns+column`:

```forth
: MATRIX  ( rows cols -- )
    CREATE  2DUP , ,  * CELLS HERE OVER ERASE ALLOT
    DOES>  ( r c pfa -- addr )
        >R  SWAP R@ @ * +  CELLS R> + 2 CELLS + ;
3 6 MATRIX GRID
7 2 5 GRID !
2 5 GRID @ .                    \ => 7
```

The second cell keeps the number of rows, so that the matrix remembers
both its sizes, which BASIC's `DIM` function reports. `' GRID` finds the
word named on its right, `>BODY` the cells after it:

```forth
' GRID >BODY CELL+ @ .  ' GRID >BODY @ .        \ => 3 6
```
 A third dimension is the
same scheme with one more size stored and one more multiplication.

**A string array is a matrix of characters.** Every string has the same
fixed length, as in BASIC. The array keeps that length in its first cell,
fills itself with spaces, and gives each row back as an `a n` pair, the
form every string word of [Chapter 7](07-strings.md) takes:

```forth
: SARRAY  ( n len -- )
    CREATE  DUP , * HERE OVER BLANK ALLOT
    DOES>  ( i pfa -- a len )
        DUP @ >R  CELL+ SWAP R@ * +  R> ;
3 10 SARRAY A$
```

Assigning to a row is the Procrustean assignment of the manual: the text
is cut if it is too long and padded with spaces if it is too short. One
definition does both, and never writes past the end of the row:

```forth
NEEDS S"
: S!  ( a u dest len -- )  2DUP BLANK  ROT MIN CMOVE ;
S" 1234567890" 1 A$ S!
1 A$ TYPE                       \ => 1234567890
S" much too long a text" 0 A$ S!
0 A$ TYPE  1 A$ TYPE            \ => much too l1234567890
```

A single character, or a slice of a row, is the slicing of Chapter 7
applied to the row. `1 A$ DROP 6 + C@` is the seventh character, BASIC's
`a$(2,7)` (both numbers one less, since rows and characters count from
0):

```forth
1 A$ DROP 6 + C@ EMIT           \ => 7
```

**Nothing is checked.** BASIC stops with `3 Subscript wrong`. In Forth
`99 M @` reads whatever memory holds 99 cells further on, and `99 M !`
overwrites it, without a word of warning: often a part of the dictionary,
so the damage shows up later and somewhere else. Keep indices in range,
or put the check inside the array. The array then keeps its size in the
first cell and compares the index with it:

```forth
NEEDS ABORT"
: SAFE-ARRAY  ( n -- )
    CREATE  DUP , CELLS HERE OVER ERASE ALLOT
    DOES>  ( i pfa -- addr )
        2DUP @ U< 0= ABORT" Subscript wrong"
        SWAP CELLS + CELL+ ;
5 SAFE-ARRAY BOX
4 BOX @ .                       \ => 0
5 BOX @ .                       \ => Subscript wrong
```

`U<` compares without sign, so a negative index is caught as well. The
check costs time at every access; that is why Forth does not do it for
you.

**Byte arrays.** BASIC's numeric arrays hold numbers of five bytes. In
Forth an element is as large as you decide: a cell (two bytes, `@` and
`!`), or a single byte for values up to 255 (`C@` and `C!`), at half the
memory:

```forth
: BYTES  ( n -- )  CREATE HERE OVER ERASE ALLOT  DOES> + ;
8 BYTES FLAGS
200 3 FLAGS C!
3 FLAGS C@ .                    \ => 200
```

**There are no predefined arrays.** NextBASIC's integer arrays `%a()` to
`%z()` exist from the start, 64 elements each, and longer ones are made by
borrowing the arrays that follow. In Forth every array is declared, with
the size and the kind of element it needs, and only the memory free in
the dictionary limits it.

**A name is one word.** BASIC lets an array and a number share a name,
since the brackets tell them apart. In Forth a name is one word, whatever
it stands for, and the latest definition hides the earlier ones. Defining
an array again does not clear the old one: it makes a new one, and the
old one stays where it was, still taking room. To change the size,
`FORGET` the array and define it again.

## Correspondence table

| NextBASIC | vForth | Note |
|---|---|---|
| `DIM b(10)` | `CREATE B 10 CELLS ALLOT` | Not cleared: add `B 10 CELLS ERASE`. |
| `b(i)` | `B i CELLS + @` | Index from 0. |
| `LET b(i)=x` | `x B i CELLS + !` | |
| `DIM m(10)`, `m(i)` | `10 ARRAY M`, `i M @` | `ARRAY` defined above. Cleared. |
| `DIM c(3,6)`, `c(r,c)` | `3 6 MATRIX C`, `r c C @` | `MATRIX` defined above. |
| `DIM a$(3,10)` | `3 10 SARRAY A$` | `SARRAY` defined above. Filled with spaces. |
| `a$(i)` | `i A$` | Leaves `a len`. |
| `LET a$(i)="..."` | `S" ..." i A$ S!` | `S!` defined above: cut or padded. |
| `a$(i,k)` | `i A$ DROP k + C@` | `k` from 0. |
| `a$(i)(m TO n)` | `i A$ m n SLICE` | `SLICE` from Chapter 7. |
| `DIM a$(10)` | `CREATE A$ 10 ALLOT` | A string variable: Chapter 7. |
| a second `DIM b(10)` | `B 10 CELLS ERASE` | Clears it again. |
| `DIM (c(),1)`, `DIM (c(),2)` | `' C >BODY CELL+ @`, `' C >BODY @` | Rows and columns, stored by `MATRIX`. |
| `DIM (c())` | -- | Fixed by the defining word: `MATRIX` makes two. |
| `%a(i)` (64, predefined) | -- | Every array is declared. |
| `%a[i]`, `%c[x][y]` | -- | Any size fits, within free memory. |
| `3 Subscript wrong` | -- | Nothing is checked: see `SAFE-ARRAY`. |
| (not in BASIC) | `8 BYTES F`, `i F C@` | Elements of one byte. |

## Side by side

**Ten marks and their average.** In BASIC the numbers go from `DATA` into
the array. In Forth the array *is* the data, written with `,` as in
[Chapter 5](05-read-data-restore.md):

```
10 DIM m(10)
20 FOR n=1 TO 10: READ m(n): NEXT n
30 LET t=0
40 FOR n=1 TO 10: LET t=t+m(n): NEXT n
50 PRINT t/10
60 DATA 7,4,9,6,8,5,10,6,7,8
```

```forth
CREATE MARKS  7 , 4 , 9 , 6 , 8 , 5 , 10 , 6 , 7 , 8 ,
: MARK  ( i -- n )  CELLS MARKS + @ ;
: AVERAGE  ( -- n )  0  10 0 DO  I MARK +  LOOP  10 / ;
AVERAGE .                       \ => 7
```

No loop is needed to fill the array: the ten numbers are stored by `,`
as the line is read.

**A times table in a matrix.** Three rows and six columns, each element
the product of its row and its column.

```
10 DIM t(3,6)
20 FOR r=1 TO 3: FOR c=1 TO 6
30   LET t(r,c)=r*c
40 NEXT c: NEXT r
50 FOR r=1 TO 3
60   FOR c=1 TO 6: PRINT t(r,c);" ";: NEXT c
70   PRINT
80 NEXT r
```

```forth
NEEDS J
3 6 MATRIX PRODUCTS
: FILL-PRODUCTS  ( -- )
    3 0 DO  6 0 DO  J 1+ I 1+ *  J I PRODUCTS !  LOOP  LOOP ;
: .PRODUCTS  ( -- )
    3 0 DO  6 0 DO  J I PRODUCTS @ 3 .R  LOOP  CR  LOOP ;
FILL-PRODUCTS .PRODUCTS
```

```text
  1  2  3  4  5  6
  2  4  6  8 10 12
  3  6  9 12 15 18
```

Inside two nested `DO` loops `I` is the index of the inner one and `J`
(`NEEDS J`) of the outer one, the `c` and the `r` of the BASIC listing.
They run from 0, so the products use `J 1+` and `I 1+`.

**The months of the year.** The manual's exercises: an array of twelve
names, then a line built from one of them. Thirteen rows are reserved, so
that row 1 is January as in BASIC; row 0 stays blank.

```
10 DIM m$(12,9)
20 FOR n=1 TO 12: READ m$(n): NEXT n
30 PRINT "Spring: ";m$(3);m$(4);m$(5)
40 PRINT "the month of ";m$(5);"ing"
50 DATA "January","February","March","April"
60 DATA "May","June","July","August","September"
70 DATA "October","November","December"
```

```forth
13 9 SARRAY MONTH$
: M!  ( a u i -- )  MONTH$ S! ;
S" January" 1 M!   S" February" 2 M!   S" March" 3 M!
S" April" 4 M!     S" May" 5 M!        S" June" 6 M!
S" July" 7 M!      S" August" 8 M!     S" September" 9 M!
S" October" 10 M!  S" November" 11 M!  S" December" 12 M!
: SPRING  ( -- )  6 3 DO  I MONTH$ TYPE  LOOP ;
." Spring: " SPRING             \ => Spring: March    April    May
." the month of " 5 MONTH$ -TRAILING TYPE ." ing"
```

```text
the month of Maying
```

`SPRING` prints each row whole, nine characters with the spaces that pad
it, just as BASIC prints `m$(3)`. Those spaces are what the manual's
second exercise asks about, and in Forth the answer is one word:
`-TRAILING` drops them from the end of the `a n` pair before `TYPE`
prints it.

## No equivalent

- **Automatic clearing.** `DIM` clears; `ALLOT` does not. Put `ERASE` or
  `BLANK` in the defining word, as `ARRAY` and `SARRAY` do here.
- **Bounds checking.** No `Subscript wrong`: either keep indices in range
  or build the check into the array.
- **Predefined integer arrays** `%a()` to `%z()`, and the trick of the
  longer ones with `[]`. Every array is declared.
- **`DIM` as a function.** An array knows its sizes only if its defining
  word stores them; `MATRIX` stores both, `ARRAY` none. Or keep the size
  in a `CONSTANT` and use it both in the definition and in the loops.
- **Arrays and simple variables with the same name.** One name, one word.
- **Local arrays** (`LOCAL z()` in a procedure): see
  [Chapter 4](04-procedures-and-subroutines.md).

## Further reading

- Tutorial `008` -- `CREATE`, `ALLOT`, `CELLS`, `@`, `!`, `C@`, `C!`.
- Tutorial `009` -- `CMOVE`, `ERASE`, `BLANK`, `-TRAILING`.
- Tutorial `010` -- `CREATE ... DOES>`, with cell, byte, string and
  two-dimensional arrays.
- Tutorial `023` -- `+FIELD`, for records whose fields differ.
- `HELP CREATE`, `HELP ALLOT`, `HELP CELLS`, `HELP ERASE`, `HELP BLANK`,
  `HELP DOES>`, `HELP -TRAILING`.
- Chapter 7 -- strings as `a n` pairs, `SLICE`.

<!-- nav -->
---

Previous: [Chapter 10 - Random Numbers](10-random-numbers.md) |
[Contents](README.md) |
Next: [Chapter 12 - Conditions](12-conditions.md)
