\
\ 010-create-does.f
\ Defining words: CREATE, DOES>, and the family pattern.
\
\ CREATE...DOES> is the most powerful construct in Forth.  It lets you
\ define new *kinds* of words -- words that, when executed, create other
\ words with customised compile-time and run-time behaviour.
\
\ The mental model: think of a defining word as a mold.
\   - The part before DOES>  runs at *definition time* (when the mold is used).
\   - The part after  DOES>  runs at *execution time* (when the product runs).
\   At execution time, DOES> leaves the PFA of the product word on the stack,
\   giving the run-time code access to the data stored at definition time.
\
\ This is how CONSTANT, VARIABLE, VALUE, and every array type are built.
\ Once you understand CREATE...DOES> you can build any data structure.
\
\ vForth note: DOES> follows the latest Forth standard (v1.8+).
\ <BUILDS is kept for compatibility only -- prefer CREATE.
\
\ Reference: sec.2.12.9, 6.1
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   010 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 010 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 010: CREATE...DOES> loaded. ) CR
.(     Type NEWTASK to unload.       ) CR


\ ===========================================================================
\ 1. CREATE alone -- the simplest case
\ ===========================================================================
\
\ CREATE name  ( -- )   compile-time: create a dictionary entry for name.
\                        run-time: push name's PFA (parameter field address).
\
\ Without DOES>, the run-time behaviour is just "push my PFA" -- identical
\ to VARIABLE, but with no allotted storage unless you follow with ALLOT.
\
\   CREATE POINT  2 CELLS ALLOT   ( two cells: x and y )
\   10 POINT !                    ( store x )
\   20 POINT CELL+ !              ( store y )
\   POINT @  .                    => 10
\   POINT CELL+ @ .               => 20

CREATE POINT  2 CELLS ALLOT
10 POINT !
20 POINT CELL+ !


\ ===========================================================================
\ 2. CONSTANT redefined -- the canonical DOES> example
\ ===========================================================================
\
\ The standard definition of CONSTANT illustrates the pattern perfectly:
\
\   : MY-CONSTANT  ( n -- )   CREATE ,  DOES> @ ;
\
\ Compile time (when  76 MY-CONSTANT TROMBONES  is executed):
\   CREATE   -- creates dictionary entry TROMBONES
\   ,        -- stores 76 into TROMBONES' PFA
\
\ Run time (when  TROMBONES  is executed):
\   DOES>    -- leaves TROMBONES' PFA on stack
\   @        -- fetches the stored value  => 76
\
\ The real CONSTANT is a CODE word for speed, but MY-CONSTANT is equivalent.

: MY-CONSTANT  ( n -- )   CREATE ,  DOES> @ ;

76     MY-CONSTANT TROMBONES
$4000  MY-CONSTANT SCREEN-ADDR

.( Try: TROMBONES .     ) CR     \ => 76
.( Try: SCREEN-ADDR U.  ) CR     \ => 16384


\ ===========================================================================
\ 3. Typed cell arrays
\ ===========================================================================
\
\ A defining word that creates named cell arrays with a built-in indexer.
\ The DOES> part receives ( index pfa ): index from the caller, pfa from
\ DOES> itself.  SWAP puts pfa below index, then CELLS + computes the addr.
\
\   : CELL-ARRAY  ( n -- )
\       CREATE  CELLS ALLOT
\       DOES>   ( index pfa -- addr )  SWAP CELLS + ;
\
\ Usage -- note that the index precedes the array name:
\   5 CELL-ARRAY SCORES      ( array of 5 cells )
\   42  0 SCORES  !          ( store 42 at index 0 )
\   99  3 SCORES  !          ( store 99 at index 3 )
\   0 SCORES  @ .            => 42
\   3 SCORES  @ .            => 99

: CELL-ARRAY  ( n -- )
    CREATE  CELLS ALLOT
    DOES>   ( index pfa -- addr )  SWAP CELLS + ;

5 CELL-ARRAY SCORES
42  0 SCORES  !
99  3 SCORES  !

.( Try: 0 SCORES @ .   ) CR     \ => 42
.( Try: 3 SCORES @ .   ) CR     \ => 99


\ ===========================================================================
\ 4. Typed byte arrays
\ ===========================================================================
\
\ Same pattern for byte arrays.  DOES> receives ( index pfa ); + computes
\ the byte address directly (no scaling needed for single bytes).
\
\   : BYTE-ARRAY  ( n -- )
\       CREATE  ALLOT
\       DOES>   ( index pfa -- addr )  SWAP + ;
\
\ Usage:
\   8 BYTE-ARRAY FLAGS
\   $41  0 FLAGS  C!    ( store 'A' at index 0 )
\   $42  1 FLAGS  C!    ( store 'B' at index 1 )
\   0 FLAGS  C@ EMIT    => A
\   1 FLAGS  C@ EMIT    => B

: BYTE-ARRAY  ( n -- )
    CREATE  ALLOT
    DOES>   ( index pfa -- addr )  SWAP + ;

8 BYTE-ARRAY FLAGS
$41  0 FLAGS  C!
$42  1 FLAGS  C!

.( Try: 0 FLAGS C@ EMIT  ) CR   \ => A
.( Try: 1 FLAGS C@ EMIT  ) CR   \ => B


\ ===========================================================================
\ 5. Counted string arrays -- a richer example
\ ===========================================================================
\
\ A defining word that stores the size at compile time and returns
\ both address and length at run time -- the CHARACTERS pattern from
\ Starting Forth, adapted to vForth:
\
\   : STRBUF  ( maxlen -- )
\       CREATE  DUP ,  ALLOT
\       DOES>   ( pfa -- addr maxlen )  DUP CELL+ SWAP @ ;
\
\ Compile time: stores maxlen as a cell, then allots maxlen bytes.
\ Run time: pfa points to the stored maxlen cell; CELL+ skips it to
\ reach the text area; SWAP @ retrieves maxlen.

: STRBUF  ( maxlen -- )
    CREATE  DUP ,  ALLOT
    DOES>   ( pfa -- addr maxlen )  DUP CELL+ SWAP @ ;

20 STRBUF USERNAME    ( 20-byte string buffer )

\ Store a name using a counted string literal built with ," :
CREATE .NAME  ," vForth"
.NAME 1+  USERNAME DROP  .NAME C@  CMOVE   \ copy text bytes only

.( Try: USERNAME TYPE CR  ) CR   \ => vForth (first 6 chars)


\ ===========================================================================
\ 6. 2D byte array
\ ===========================================================================
\
\ Storing #cols at compile time, computing row*cols+col at run time.
\ DOES> receives ( row col pfa ):
\   DUP @   -- fetch #cols from pfa
\   ROT *   -- row * #cols
\   + +     -- add col, add pfa base
\   CELL+   -- skip the stored #cols cell to reach the data area
\
\   : 2D-ARRAY  ( #rows #cols -- )
\       CREATE  DUP ,  * ALLOT
\       DOES>   ( row col pfa -- addr )
\           DUP @ ROT * + + CELL+ ;
\
\ Usage -- row and col precede the array name:
\   4 4 2D-ARRAY BOARD     ( 4x4 byte grid )
\   42  2 1 BOARD  C!      ( store 42 at row 2, col 1 )
\   2 1 BOARD  C@ .        => 42

: 2D-ARRAY  ( #rows #cols -- )
    CREATE  DUP ,  * ALLOT
    DOES>   ( row col pfa -- addr )
        DUP @ ROT * + + CELL+ ;

4 4 2D-ARRAY BOARD
42  2 1 BOARD  C!

.( Try: 2 1 BOARD C@ .  ) CR    \ => 42


\ ===========================================================================
\ 7. Summary: the CREATE...DOES> template
\ ===========================================================================
\
\ : MY-DEFINING-WORD  ( compile-time-args -- )
\     CREATE
\         ( compile-time actions: , C, ALLOT etc. )
\     DOES>
\         ( run-time: DOES> pushes pfa as deepest item; caller args above ) ;
\
\ Rules:
\ 1. Code before DOES> runs when the defining word is called.
\ 2. Code after  DOES> runs when a product word is executed.
\ 3. DOES> always pushes the product word's PFA as the deepest new item.
\ 4. Caller arguments sit above pfa on the stack at DOES> entry.
\ 5. Never nest CREATE...DOES> -- one level at a time.


\ ===========================================================================
\ 8. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ NEEDS TESTING
\ T{  TROMBONES        -> 76     }T
\ T{  SCREEN-ADDR      -> $4000  }T
\ T{  42 0 SCORES !  0 SCORES @  -> 42  }T
\ T{  99 3 SCORES !  3 SCORES @  -> 99  }T
\ T{  0 FLAGS C@       -> $41    }T
\ T{  2 1 BOARD C@     -> 42     }T
