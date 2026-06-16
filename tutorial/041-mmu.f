\
\ 041-mmu.f
\ MMU and memory banking: mapping 8K pages into the Z80 address space.
\
\ The ZX Next has 2 MB of RAM organized as 256 banks of 8K (pages
\ numbered 0-255).  The Z80 sees a 64K address space divided into
\ eight 8K slots (MMU0-MMU7, addresses $0000-$FFFF).  vForth uses
\ slot 7 ($E000-$FFFF) for its dictionary (in heap).  MMU7! maps a
\ different 8K page into that window temporarily; it is restored 
\ automatically at Forth prompt, but at run-time is your responsibility.
\
\ Reference: sec.5.3
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   041 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 041 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 041: MMU and memory banking loaded. ) CR
.(     Type NEWTASK to unload.                       ) CR

NEEDS MMU7!
NEEDS MMU7@
NEEDS MMU0!
NEEDS MMU1!
NEEDS REG!
NEEDS REG@
NEEDS ms


\ ===========================================================================
\ 1. The Z80 address space and MMU slots
\ ===========================================================================
\
\ Z80 address space: 64 KB ($0000-$FFFF)
\ Divided into 8 slots of 8K each:
\
\   Slot  Address range   NextReg   vForth use
\   ----  -------------   -------   ----------
\   0     $0000-$1FFF     $50       ROM 0 (ZX ROM)
\   1     $2000-$3FFF     $51       ROM 1
\   2     $4000-$5FFF     $52       ULA screen and attributes
\   3     $6000-$7FFF     $53       ULA screen continued
\   4     $8000-$9FFF     $54       vForth low dictionary
\   5     $A000-$BFFF     $55       vForth continued
\   6     $C000-$DFFF     $56       vForth continued
\   7     $E000-$FFFF     $57       vForth heap (current page)
\
\ Each slot can hold any of the 256 available 8K pages.
\ Page 0 = first 8K of physical RAM, page 255 = last 8K.

\ ===========================================================================
\ 2. MMU7! and MMU7@ -- map slot 7
\ ===========================================================================
\
\   MMU7! ( n -- )   map 8K page n into slot 7 ($E000-$FFFF)
\   MMU7@ ( -- n )   read which page is currently in slot 7
\
\ MMU7! uses the NEXTREG Z80-N instruction to write Next register $57.
\ MMU7@ reads register $57 (= decimal 87).
\
\ WARNING: Slot 7 holds the vForth dictionary.  Mapping a different
\ page there makes dictionary data inaccessible until the
\ the original page is restored.  Always save and restore:
\
\   MMU7@ >R          \ save current page
\   other-page MMU7!  \ map new page
\   ... read/write ...
\   R> MMU7!          \ restore dictionary page

\ ===========================================================================
\ 3. MMU0! and MMU1! -- map slot 0 and slot 1
\ ===========================================================================
\
\   MMU0! ( n -- )   map 8K page n into slot 0 ($0000-$1FFF)
\   MMU1! ( n -- )   map 8K page n into slot 1 ($2000-$3FFF)
\
\ These words use NEXTREG $50/$51.  Slot 0 normally holds the ZX ROM.
\ Remapping slot 0 to RAM allows writing via ROM addresses.

\ ===========================================================================
\ 4. The Layer 2 frame buffer pages
\ ===========================================================================
\
\ Layer 2 uses six consecutive 8K pages starting from L2-RAM-PAGE.
\ L2-RAM-PAGE is computed at load time as:  $12 REG@ * 2
\
\ Typical layout (Next v1.3+ hardware):
\   Reg $12 = $08  =>  L2-RAM-PAGE = $10 (page 16)
\   Layer 2 occupies pages 16, 17, 18, 19, 20, 21 (6 * 8K = 48K)
\
\ To access Layer 2 frame buffer directly:
\   Row r is stored at page  L2-RAM-PAGE + r/32
\   within that page at offset  (r mod 32) * 256 + col

$12 REG@ 2 * CONSTANT L2-FIRST-PAGE

: L2-ROW-PAGE  ( row -- page )
    32 /           \ 0-5
    L2-FIRST-PAGE +
;

: L2-OFFSET  ( row col -- offset )
    SWAP 32 MOD    \ col: row mod 32
    256 * SWAP +   \ offset = (row mod 32)*256 + col
;

\ ===========================================================================
\ 5. Safe page swap pattern
\ ===========================================================================
\
\ Template for temporarily mapping a different page into slot 7:
\
\   : WITH-PAGE  ( page quot -- )
\       >R
\       MMU7@ >R          \ save current dictionary page
\       MMU7!             \ map requested page
\       R@ EXECUTE        \ run the quotation
\       R> MMU7!          \ restore dictionary page
\       RDROP
\   ;
\
\ Since vForth does not have quotations (anonymous xt), the pattern
\ is used directly in definitions:
\
\   : ACCESS-PAGE  ( page -- )
\       MMU7@ >R          \       R: dict-page
\       MMU7!             \ map given page
\       ... code using $E000-$FFFF ...
\       R> MMU7!          \ restore
\   ;

: ACCESS-PAGE  ( page -- )
    MMU7@ >R
    MMU7!
    \ Page is now visible at $E000-$FFFF
    \ (insert your read/write code here)
    R> MMU7!
;

\ ===========================================================================
\ 6. Demo: peek at Layer 2 page contents
\ ===========================================================================

: PEEK-L2-ROW  ( row -- )
    \ Read first 8 bytes of the given row from Layer 2
    DUP L2-ROW-PAGE                  \ ( row page )
    MMU7@ >R MMU7!                   \ ( row )  R: dict-page
    0 L2-OFFSET                      \ ( offset )  column 0
    $E000 +                          \ ( addr )
    8 0 DO
        DUP I + C@ .
    LOOP
    DROP
    R> MMU7!                         \ restore dictionary page
;

\ ===========================================================================
\ 7. Demo: show current MMU7 page
\ ===========================================================================

: SHOW-MMU7  ( -- )
    ." Slot 7 is mapped to page: " MMU7@ . CR
    ." Layer 2 first page: " L2-FIRST-PAGE . CR
;

\ ===========================================================================
\ 8. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ NEEDS TESTING
\ T{  L2-FIRST-PAGE 0>  ->  -1  }T   \ Layer 2 page must be > 0
\ T{  0 0 L2-OFFSET  ->  0   }T      \ top-left row 0, col 0
\ T{  0 1 L2-OFFSET  ->  1   }T      \ top-left row 0, col 1
\ T{  1 0 L2-OFFSET  ->  256 }T      \ row 1, col 0
