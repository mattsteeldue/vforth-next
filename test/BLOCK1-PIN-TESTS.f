\
\ BLOCK1-PIN-TESTS.f
\
\ Regression test for the "block-buffer starvation" bug: F_INCLUDE keeps
\ the source line being interpreted in the BLOCK 1 buffer, so an INCLUDEd
\ file that read more distinct blocks than the pool holds used to recycle
\ its own line -- WORD re-read BLOCK 1 from disk (metadata) and a random
\ word came out "undefined".  Since build 2026-09-25 BUFFER never evicts
\ BLOCK 1 (planners/PLAN-MITIGATION-BLOCK-1-BUG.md).
\
\ Every test below reads 20 distinct blocks (Screens 50..59, read only,
\ never UPDATEd) while this very file is being interpreted, then keeps
\ going on the same line.  Before the fix the INCLUDE never reached the
\ last line.
\
\     INCLUDE test/BLOCK1-PIN-TESTS.f
\

.( BLOCK1-PIN-TESTS ) CR

NEEDS TESTING

DECIMAL

: READ-20-BLOCKS ( -- )  20 0 DO  100 I + BLOCK DROP  LOOP ;

\ 1. the rest of the current line survives the reads
T{ READ-20-BLOCKS  1 2 + -> 3 }T

\ 2. ... and so do the following lines
T{ READ-20-BLOCKS READ-20-BLOCKS  #BUFF -> #BUFF }T

\ 3. BLOCK 1 still holds this very line: F_INCLUDE stores it from
\    offset 1, so the "{" of "T{" is at offset 2
T{ READ-20-BLOCKS  1 BLOCK 2 + C@ -> CHAR { }T

\ 4. FLUSH inside an INCLUDE no longer wipes the source line
T{ READ-20-BLOCKS FLUSH  4 5 + -> 9 }T

\ 5. a BUFFER-heavy loop: every one of the other buffers is recycled
: CYCLE-BUFFERS ( -- )  #BUFF 3 * 0 DO  200 I + BUFFER DROP  LOOP ;
T{ CYCLE-BUFFERS  6 7 * -> 42 }T

.( BLOCK1-PIN-TESTS done ) CR

