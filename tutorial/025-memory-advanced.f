\
\ 025-memory-advanced.f
\ Advanced memory: heap, HALLOT, ALIGNED, UNUSED, ROOM, PAD.
\
\ vForth has two distinct memory pools:
\
\   Dictionary (code/data space)
\     Grows upward from ORIGIN.  Managed by HERE and ALLOT.
\     Words: HERE DP @ ALLOT C, , FILL ERASE
\
\   Heap (name space at $E000-$FFFF in MMU7)
\     Stores word names (NFAs), links, and cross-references.
\     Managed by HP@; HALLOT allocates from it (NEEDS HALLOT).
\     Separate from the dictionary; survives FORGET.
\
\ PAD is a transient scratch buffer above HERE (in the dictionary).
\ UNUSED reports how much space remains between HERE and PAD.
\ ROOM prints the same figure with a label.
\ ALIGNED rounds an address up to the next cell boundary.
\
\ Words requiring NEEDS:
\   HALLOT   -- heap allot
\   ALIGNED  -- round address to even boundary
\   UNUSED   -- free dictionary bytes
\   ROOM     -- print free dictionary bytes
\
\ Reference: sec.2.12.7, 4.5, 6.3
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   025 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 025 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 025: advanced memory loaded. ) CR
.(     Type NEWTASK to unload.   ) CR

NEEDS HALLOT
NEEDS ALIGNED
NEEDS UNUSED
NEEDS ROOM


\ ===========================================================================
\ 1. Dictionary memory: HERE, DP, ALLOT
\ ===========================================================================
\
\ HERE ( -- a )   current dictionary pointer (next free byte)
\ DP   ( -- a )   address of the dictionary pointer variable
\ ALLOT ( n -- )  advance HERE by n bytes (allocate without initialising)
\
\ A typical allocation pattern:
\   HERE  10 ALLOT  ( start-addr -- )  \ reserve 10 bytes, keep address
\
\ Variables and CREATE use ALLOT internally.  Manual ALLOT is used for
\ byte arrays and custom structures.

.( HERE = ) HERE U. CR

CREATE SCRATCH  20 ALLOT    \ 20-byte scratch area

.( SCRATCH at ) SCRATCH U. CR


\ ===========================================================================
\ 2. PAD -- transient scratch buffer
\ ===========================================================================
\
\ PAD ( -- a )   address of the transient scratch area.
\ PAD lives above HERE; it is destroyed if the dictionary grows past it.
\ Use PAD for temporary strings and number formatting, NOT for permanent
\ storage.  Pictured output (<# ... #>) also uses this area.
\
\   PAD  20 BLANK                  \ clear 20 bytes of PAD
\   S" hello" PAD SWAP CMOVE       \ copy string to PAD
\   PAD  5 TYPE CR                 \ print it

PAD C/L BLANK  \ blank 64 character at PAD
S" vForth"     \ allocate a string in Heap
PAD SWAP CMOVE \ move it to PAD
.( PAD contains: ) PAD 6 TYPE CR


\ ===========================================================================
\ 3. UNUSED -- free dictionary space
\ ===========================================================================
\
\ UNUSED ( -- n )   bytes available between HERE and PAD.
\ This is the space remaining for new definitions and data.
\
\   UNUSED .    => (some large number, typically 10000+)

.( UNUSED = ) UNUSED . ." bytes" CR


\ ===========================================================================
\ 4. ROOM -- print free space
\ ===========================================================================
\
\ ROOM ( -- )   print the free dictionary space with a label.
\ Equivalent to  UNUSED U. ." bytes free." CR
\
\   ROOM    => NNNN bytes free.

ROOM


\ ===========================================================================
\ 5. ALIGNED -- round address to cell boundary
\ ===========================================================================
\
\ ALIGNED ( a1 -- a2 )   round a1 up to the nearest even (cell) boundary.
\ vForth cells are 16 bits (2 bytes).  An odd address is invalid for
\ cell (@, !) and double (2@, 2!) operations.
\
\   0 ALIGNED  .    => 0   (already even)
\   1 ALIGNED  .    => 2   (rounded up)
\   4 ALIGNED  .    => 4
\   5 ALIGNED  .    => 6

.( 0 ALIGNED = ) 0 ALIGNED . CR    \ => 0
.( 1 ALIGNED = ) 1 ALIGNED . CR    \ => 2
.( 5 ALIGNED = ) 5 ALIGNED . CR    \ => 6

\ Useful when building structures with mixed byte/cell fields:
\   0
\       1 +FIELD  flag      \ byte field at offset 0
\       HERE 1+ ALIGNED     \ pad to even address before next cell field


\ ===========================================================================
\ 6. HALLOT -- heap allocation
\ ===========================================================================
\
\ HALLOT ( n -- )   allocate n bytes in the heap (name space, $E000-$FFFF).
\ HP@ ( -- a )      address of the heap pointer variable.
\
\ The heap is the high-memory page (MMU7) that holds dictionary names.
\ Normally managed automatically by : and CREATE.  Direct use is for
\ headerless definitions or experimental work.
\
\ Heap space is independent of dictionary space.  UNUSED measures only
\ the dictionary side; HP@ shows how much heap is used.
\
\   HP@ @ U.    => (current top-of-heap address, near $E000)

.( HP = ) HP@ U. CR


\ ===========================================================================
\ 7. Memory layout summary
\ ===========================================================================
\
\   ORIGIN (code start)
\   ...dictionary grows upward...
\   HERE
\   PAD (transient scratch)
\   ...UNUSED bytes...
\   S0 (data stack base)
\
\   $E000 (MMU7 page start)
\   ...heap grows upward from here...
\   HP (heap pointer)
\   ...remaining heap...
\   $FFFF


\ ===========================================================================
\ 8. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ NEEDS TESTING
\ T{  0 ALIGNED  -> 0   }T
\ T{  1 ALIGNED  -> 2   }T
\ T{  2 ALIGNED  -> 2   }T
\ T{  3 ALIGNED  -> 4   }T
\ T{  UNUSED  0 > -> -1  }T   \ some space is always free
