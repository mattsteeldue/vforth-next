\
\ 069-data-tables.f
\ Tables of data: what replaces BASIC's DATA, READ, RESTORE and part of
\ DIM.  A table is memory with a name, filled when it is compiled; this
\ tutorial builds one that knows its own length and checks its index,
\ gives it a READ pointer with an "out of data" error, then shows the
\ three ways programs use tables: direct index, search by key, and a
\ table of words to EXECUTE in place of ON ... GO SUB.
\
\ vForth-specific notes:
\   - CREATE , C, ," HERE ALLOT EXECUTE and ?ERROR are all in the core:
\     this tutorial needs nothing else.
\   - ," stores a counted string with a trailing zero byte (the length,
\     the text, then $00, for NextZXOS).  COUNT ignores the zero.
\   - Tutorial 010 covers the CREATE ... DOES> mechanism behind TABLE
\     below; tutorial 008 covers @ ! C@ C! and HERE.
\
\ Coming from BASIC: Ch.5, 11  |  doc/basic-to-vforth/
\ Starting FORTH (Brodie): Ch.8  |  vForth screens 850-867
\ Reference: sec.2.12.6, 2.12.9
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   069 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 069 TUTORIAL
\
\ Run it with:  2028 DEMO   (any year)
\

MARKER NEWTASK

CR
.( --- Tutorial 069: data tables loaded. ) CR
.(     Type NEWTASK to unload.          ) CR

\ =========================================================================
\ 1. A table is a name and some commas
\ =========================================================================
\
\ CREATE gives a name to the next free address, and , stores a cell
\ there and moves on.  The name then pushes the address of the first
\ value; element i is i cells further on.

CREATE PRIMES  2 , 3 , 5 , 7 , 11 , 13 ,

: PRIME  ( i -- n )  CELLS PRIMES + @ ;

\   0 PRIME .  4 PRIME .        => 2 11
\
\ Unlike a DATA line, the table is filled once, when the line is
\ compiled: any expression before a comma is worked out there and only
\ its result is kept.  And unlike DATA, a table can be written to: 17 3
\ CELLS PRIMES + ! changes the fourth prime.
\
\ CAVEAT: the last number needs its comma too.  CREATE T 1 , 2 , 3
\ leaves the 3 on the stack and the table one element short, without a
\ word of complaint.

\ =========================================================================
\ 2. A table that knows its length
\ =========================================================================
\
\ PRIMES does not know where it ends: 6 PRIME fetches whatever follows
\ the table in memory, and BASIC's "Out of DATA" has no counterpart.
\ The cure is to keep the count in the table itself, in its first cell.
\ HERE, the next free address, gives it right after the last comma:
\
\   TABLE NAME  v0 , v1 , ... vn ,  END-TABLE
\
\ TABLE leaves the address of the count cell on the stack for END-TABLE,
\ which works out how many cells were stored after it.

: TABLE  ( "name" -- addr )
    CREATE  HERE  0 , ;

: END-TABLE  ( addr -- )
    HERE OVER - 2/ 1-   ( addr n )
    SWAP ! ;

: #ITEMS  ( t -- n )  @ ;

\ ITEM checks the index before using it.  U< treats a negative index as
\ a huge unsigned number, so one comparison rejects both -1 and n.
\ Message 10 is "Wrong array index."

: ITEM  ( i t -- n )
    2DUP #ITEMS U< 0= 10 ?ERROR
    CELL+ SWAP CELLS + @ ;

TABLE SQUARES  0 , 1 , 4 , 9 , 16 , 25 , 36 , END-TABLE

\   SQUARES #ITEMS .            => 7
\   3 SQUARES ITEM .            => 9
\   7 SQUARES ITEM .            => ITEM? Wrong array index.
\
\ CAVEAT: END-TABLE must come right after the last comma.  Anything
\ compiled in between -- another definition, a string -- is counted as
\ part of the table.

\ =========================================================================
\ 3. READ and RESTORE, for any table
\ =========================================================================
\
\ BASIC keeps one DATA pointer for the whole program.  Here the pointer
\ is two variables, which table and which item, and RESTORE takes the
\ table as its argument, so a program may read several tables in turn.
\ Reading past the end is caught by ITEM.

VARIABLE DATA-TABLE
VARIABLE DATA#

: RESTORE  ( t -- )  DATA-TABLE !  0 DATA# ! ;

: READ  ( -- n )
    DATA# @ DATA-TABLE @ ITEM
    1 DATA# +! ;

\   SQUARES RESTORE  READ . READ . READ .       => 0 1 4
\   SQUARES RESTORE  READ .                     => 0
\
\ RESTORE n of BASIC, which moves to the DATA of a given line, is a store
\ of the index you want: 5 DATA# ! makes the next READ give 25.  Most of
\ the time no pointer is needed at all: a DO loop already counts.

: .TABLE  ( t -- )
    DUP #ITEMS 0 ?DO  I OVER ITEM .  LOOP  DROP ;

\   SQUARES .TABLE              => 0 1 4 9 16 25 36

\ =========================================================================
\ 4. Bytes and strings
\ =========================================================================
\
\ Values from 0 to 255 fit in a byte: C, stores one, C@ fetches it, and
\ the index needs no CELLS.  The days of the months:

CREATE MDAYS
    31 C, 28 C, 31 C, 30 C, 31 C, 30 C,
    31 C, 31 C, 30 C, 31 C, 30 C, 31 C,

\ A list of strings is a table of addresses, because strings of
\ different lengths cannot be found by multiplying an index.  Each name
\ is a counted string with a name of its own; the table holds the
\ twelve addresses, one cell each.

CREATE M1 ," January"     CREATE M2 ," February"   CREATE M3 ," March"
CREATE M4 ," April"       CREATE M5 ," May"        CREATE M6 ," June"
CREATE M7 ," July"        CREATE M8 ," August"     CREATE M9 ," September"
CREATE M10 ," October"    CREATE M11 ," November"  CREATE M12 ," December"

CREATE MNAMES
    M1 , M2 , M3 , M4 , M5 , M6 , M7 , M8 , M9 , M10 , M11 , M12 ,

: LEAP?  ( year -- f )
    DUP 4 MOD 0=  OVER 100 MOD 0= 0= AND
    SWAP 400 MOD 0=  OR ;

: DAYS-IN  ( month year -- days )     \ month 1..12
    OVER 1- MDAYS + C@      ( month year days )
    ROT 2 = ROT LEAP? AND   ( days f )
    1 AND + ;               \ February of a leap year: one more

: .MONTH  ( month -- )
    1- CELLS MNAMES + @ COUNT TYPE ;

\   2 2027 DAYS-IN .  2 2028 DAYS-IN .  2 2100 DAYS-IN .   => 28 29 28
\   9 .MONTH                    => September

\ =========================================================================
\ 5. Search by key
\ =========================================================================
\
\ When the keys are not 0, 1, 2 ... but scattered numbers, the table
\ holds pairs, key and value, and the program looks for the key.  Here
\ the codes KEY returns for the special keys of the Spectrum, each with
\ the address of its name.  The table ends with a key of 0, a sentinel,
\ so the search needs no count.

CREATE K-LEFT  ," LEFT"     CREATE K-RIGHT ," RIGHT"
CREATE K-DOWN  ," DOWN"     CREATE K-UP    ," UP"
CREATE K-DEL   ," DELETE"   CREATE K-ENTER ," ENTER"
CREATE K-EDIT  ," EDIT"

CREATE KEYNAMES
     8 , K-LEFT ,    9 , K-RIGHT ,  10 , K-DOWN ,  11 , K-UP ,
    12 , K-DEL ,    13 , K-ENTER ,   7 , K-EDIT ,
     0 ,

: LOOKUP  ( key t -- value tf | ff )
    BEGIN
        DUP @           ( key t k )
    WHILE
        2DUP @ = IF  NIP CELL+ @ -1 EXIT  THEN
        2 CELLS +
    REPEAT
    2DROP 0 ;

: .KEY  ( c -- )
    DUP KEYNAMES LOOKUP IF  NIP COUNT TYPE  ELSE  EMIT  THEN ;

\   13 .KEY   65 .KEY           => ENTERA
\
\ EXIT leaves the definition from inside the loop, as soon as the key
\ is found.  It is safe here because BEGIN ... REPEAT keeps nothing on
\ the return stack (inside DO ... LOOP it would need UNLOOP first).

\ =========================================================================
\ 6. A table of words: ON ... GO SUB
\ =========================================================================
\
\ A table can hold execution tokens as well as numbers.  ' (tick) gives
\ the token of the next word, EXECUTE runs it.  That is BASIC's
\ ON n GO SUB, or GO SUB 1000+100*n, without line numbers.

: GO-NORTH  ." You go north. " ;
: GO-EAST   ." You go east. " ;
: GO-SOUTH  ." You go south. " ;
: GO-WEST   ." You go west. " ;

CREATE MOVES  ' GO-NORTH , ' GO-EAST , ' GO-SOUTH , ' GO-WEST ,

: MOVE-TO  ( n -- )            \ n = 0..3
    3 AND  CELLS MOVES + @ EXECUTE ;

\   0 MOVE-TO  2 MOVE-TO        => You go north. You go south.
\
\ 3 AND keeps the index inside the table whatever n is: with four
\ entries it is the cheapest bound check there is.  ' is right here
\ because the table is built at the prompt level; inside a definition
\ the token is taken with ['] (tutorial 020).

\ =========================================================================
\ 7. Demo: a year in a table
\ =========================================================================

: .YEAR  ( year -- )
    CR  DUP . ." has "
    0  13 1 DO  I 2 PICK DAYS-IN +  LOOP  . ." days" CR
    13 1 DO
        I .MONTH  [CHAR] : EMIT SPACE  I OVER DAYS-IN .  CR
    LOOP  DROP ;

: DEMO  ( year -- )  .YEAR ;

\   2028 DEMO    prints "2028 has 366 days", then each month with its
\                days, "February: 29" among them

\ =========================================================================
\ 8. Simple tests (requires NEEDS TESTING)
\ =========================================================================
\
\ NEEDS TESTING  DECIMAL          \ lib/testing.f leaves BASE in HEX
\ T{  4 PRIME  ->  11  }T
\ T{  SQUARES #ITEMS  ->  7  }T
\ T{  6 SQUARES ITEM  ->  36  }T
\ T{  SQUARES RESTORE READ READ READ  ->  0 1 4  }T
\ T{  2 2028 DAYS-IN  2 2100 DAYS-IN  2 2000 DAYS-IN  ->  29 28 29  }T
\ T{  12 KEYNAMES LOOKUP NIP  ->  -1  }T
\ T{  65 KEYNAMES LOOKUP  ->  0  }T
