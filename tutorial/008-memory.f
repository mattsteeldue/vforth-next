\
\ 008-memory.f
\ Direct memory access: fetching, storing, and allocating memory.
\
\ vForth runs on a Z80 processor with a 16-bit address space.  Memory is
\ byte-addressed; a cell (the natural integer unit) is 2 bytes stored in
\ little-endian order  --  low byte at the lower address, high byte at the
\ higher address.  This matches the Z80 register convention (L before H).
\
\ The words in this tutorial operate on three levels:
\   cell  (16-bit): @  !  2*  CELLS  CELL+  CELL-
\   byte  ( 8-bit): C@  C!  CHARS  CHAR+
\   dword (32-bit): 2@  2!
\
\ Dictionary allocation (HERE, ALLOT, , C,) is also covered here because
\ it follows the same address/store model.
\
\ Starting FORTH (Brodie): Ch.8  |  vForth screens 850-867
\ Reference: sec.2.12.6, 4.2, 4.3
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   008 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 008 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 008: memory loaded. ) CR
.(     Type NEWTASK to unload.   ) CR

NEEDS DUMP
NEEDS 2VARIABLE


\ ===========================================================================
\ 1. Cell access: @ and !
\ ===========================================================================
\
\ @  ( a -- n )    fetch 16-bit cell from address a
\ !  ( n a -- )    store 16-bit cell n at address a
\
\ The address must be even (word-aligned) for correct Z80 operation;
\ odd-address cell access will silently produce wrong results.
\
\   VARIABLE X
\   42 X !          (store 42 into X)
\   X @ .           => 42
\   X ?             => 42    (shorthand: ? is @ .)
\
\ Arithmetic on stored values:
\   1 X +!          (add 1 in place  --  X is now 43)
\   X ?             => 43
\
\ TOGGLE  ( a mask -- )   XOR mask into the byte at address a.
\   X $FF TOGGLE    (flip all bits of low byte of X)
\   X $FF TOGGLE    (flip back)

VARIABLE X


\ ===========================================================================
\ 2. Byte access: C@ and C!
\ ===========================================================================
\
\ C@  ( a -- c )   fetch single byte from address a  (zero-extended to 16 bits)
\ C!  ( c a -- )   store low byte of c at address a  (high byte ignored)
\
\ Use C@ / C! when working with byte arrays, character strings, or hardware
\ registers that are mapped to individual bytes.
\
\   VARIABLE BUF
\   $41 BUF C!      (store ASCII 'A' in low byte of BUF)
\   BUF C@ EMIT     => A
\   BUF 1+ C@ .     => 0   (high byte of BUF remains zero)
\
\ Note: VARIABLE allocates a full cell (2 bytes) initialised to zero.
\ Accessing BUF and BUF 1+ addresses the two individual bytes of that cell.

VARIABLE BUF


\ ===========================================================================
\ 3. Address arithmetic: CELLS, CHARS, CELL+, CELL-
\ ===========================================================================
\
\ On this system: 1 cell = 2 bytes, 1 char = 1 byte.
\
\ CELLS  ( n -- n*2 )   convert cell count to byte count
\ CHARS  ( n -- n )     convert char count to byte count (identity here)
\ CELL+  ( a -- a+2 )   advance address by one cell
\ CELL-  ( a -- a-2 )   retreat address by one cell
\ CHAR+  ( a -- a+1 )   advance address by one byte
\ 1+     ( a -- a+1 )   same as CHAR+ for byte arrays
\
\ These words make code portable to systems with different cell sizes:
\   3 CELLS ALLOT   -- allot space for 3 cells (6 bytes here)
\   addr CELL+      -- move to next cell (not next byte)
\
\ Example: index into a cell array
\   addr  n CELLS +    -- address of element n (zero-based) in a cell array
\   addr  n 1+ CHARS + -- address of byte n+1 in a byte array


\ ===========================================================================
\ 4. Double-cell access: 2@ and 2!
\ ===========================================================================
\
\ 2@  ( a -- d )    fetch 32-bit double from address a (d: lo-cell hi-cell)
\ 2!  ( d a -- )    store 32-bit double at address a
\
\ Layout in memory (little-endian Z80 convention for a cell, but
\ opposite order for most and least significant cell):
\   addr+0  MSCell low byte
\   addr+1  MSCell high byte
\   addr+2  LSCell low byte
\   addr+3  LSCell high byte
\
\ 2VARIABLE name    creates a double-precision variable (4 bytes, zero-init).
\
\   2VARIABLE COUNTER
\   120,000.  COUNTER 2!    \ store double 120000 (note: double literal!)
\   COUNTER 2@ D.             => 120000
\   COUNTER 4 DUMP            => nnnn  01 00 C0 D4 ...
\   COUNTER 2@ HEX .S         => D4C0 1
\   DECIMAL 

2VARIABLE COUNTER


\ ===========================================================================
\ 5. HERE and ALLOT
\ ===========================================================================
\
\ HERE  ( -- a )    address of the next free dictionary byte
\ ALLOT ( n -- )    advance HERE by n bytes (reserve space, no initialisation)
\
\ ALLOT does NOT initialise the reserved memory  --  use ERASE or FILL after.
\
\   HERE U.         => (some address)
\   4 ALLOT         (reserve 4 bytes)
\   HERE U.         => (previous + 4)
\
\ Typical pattern: named byte array via CREATE + ALLOT
\
\   CREATE MYBUF  16 ALLOT   ( 16-byte buffer )
\   MYBUF 16 ERASE           ( zero-fill it )
\
\ CREATE leaves the PFA (address of the first allotted byte) when executed.

CREATE MYBUF  16 ALLOT
MYBUF 16 ERASE


\ ===========================================================================
\ 6. Comma operators: , and C,
\ ===========================================================================
\
\ ,  ( n -- )    store n as a 16-bit cell at HERE, advance HERE by 2
\ C, ( c -- )    store c as a byte at HERE, advance HERE by 1
\
\ Used inside CREATE definitions to embed compile-time data:
\
\   CREATE PRIMES  2 , 3 , 5 , 7 , 11 ,   ( cell array of 5 primes )
\   PRIMES 2 CELLS + @ .                   => 5   (third prime, index 2)
\
\   CREATE VOWELS  $41 C, $45 C, $49 C, $4F C, $55 C,  ( A E I O U )
\   VOWELS 2 CHARS + C@ EMIT               => I

CREATE PRIMES  2 , 3 , 5 , 7 , 11 ,
CREATE VOWELS  $41 C, $45 C, $49 C, $4F C, $55 C,


\ ===========================================================================
\ 7. DUMP  (memory inspection)
\ ===========================================================================
\
\ DUMP  ( a n -- )   display n bytes from address a as hex + ASCII.
\ Built-in; useful for inspecting data structures during development.
\
\   PRIMES 10 DUMP     ( show the 5 primes as raw bytes )
\   VOWELS 5 DUMP      ( show A E I O U )


\ ===========================================================================
\ 8. Demonstration words
\ ===========================================================================

: CELL-ARRAY@  ( base-addr index -- n )
    \ Fetch cell at index from a cell array (zero-based).
    CELLS + @ ;

: CELL-ARRAY!  ( n base-addr index -- )
    \ Store cell at index in a cell array (zero-based).
    CELLS + ! ;

: BYTE-ARRAY@  ( base-addr index -- c )
    \ Fetch byte at index from a byte array (zero-based).
    + C@ ;

: BYTE-ARRAY!  ( c base-addr index -- )
    \ Store byte at index in a byte array (zero-based).
    + C! ;
CR
.( Try: PRIMES 0 CELL-ARRAY@ .   ) CR   \ => 2
.( Try: PRIMES 4 CELL-ARRAY@ .   ) CR   \ => 11
.( Try: VOWELS 0 BYTE-ARRAY@ EMIT ) CR  \ => A
.( Try: PRIMES 10 DUMP            ) CR


\ ===========================================================================
\ 9. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ NEEDS TESTING
\ T{  42 X !  X @       -> 42          }T
\ T{  1  X +! X @       -> 43          }T
\ T{  $41 BUF C!  BUF C@ -> $41       }T
\ T{  PRIMES 0 CELL-ARRAY@ -> 2        }T
\ T{  PRIMES 2 CELL-ARRAY@ -> 5        }T
\ T{  PRIMES 4 CELL-ARRAY@ -> 11       }T
\ T{  VOWELS 2 BYTE-ARRAY@ -> $49      }T
