\
\ CHOMP-MAZE-TESTS.f
\
\ Unit tests for the maze infrastructure of demo/chomp-chomp.f: the
\ Stage 4 mazes on Screen (MAZE-SCR0, maze-line, MAZE-CHECK) and the
\ Stage 5 maze page (LOAD-MAZES, maze-slot, set-maze-run, section 8).
\
\ Load the game FIRST, then this file:
\     INCLUDE demo/chomp-chomp.f
\     INCLUDE test/CHOMP-MAZE-TESTS.f
\     DISK-MAZE-TESTS                  \ at the ok prompt -- see below
\
\ Requires !Blocks-64.bin with the disk mazes written to Screen 740..745
\ (maze #1 a copy of the compiled maze, #2 and #3 new layouts -- see
\ util/chomp-maze.py and prompts/CHOMP-CHOMP-STATUS.md).
\
\ Running these changes level and rewrites maze-run; the suite restores
\ level 0 and calls set-maze-run at the end, the same way
\ CHOMP-AI-TESTS.f restores state via init-all.
\
\ ---------------------------------------------------------------------
\ WHY THE DISK MAZES ARE CHECKED FROM THE PROMPT AND NOT FROM HERE
\ (history: the cause was fixed in core build 2026-09-25)
\
\ F_INCLUDE reads each source line into the BLOCK 1 buffer and sets BLK
\ to 1, so the line being interpreted lives in the block buffer pool.
\ Up to build 2026-09-24 that pool was six buffers handed out
\ round-robin (FIRST/PREV/USE), and reading a seventh distinct block
\ recycled the buffer holding the current source line: WORD re-read
\ BLOCK 1 from disk, got the block file's metadata instead of the line,
\ and a random word came out "is undefined" -- a different one each run.
\
\ MAZE-CHECK reads three blocks per disk maze, so checking all three
\ disk mazes from here touched nine distinct blocks.  Verified
\ 2026-08-24 with a probe file of four MAZE-CHECK calls: it died on the
\ sixth block read, exactly when the round-robin came back to BLOCK 1.
\ Hence this file spends its block budget on ONE disk maze (#1), and
\ mazes #2 and #3 are covered by DISK-MAZE-TESTS, run from the ok prompt.
\
\ Since build 2026-09-25 the pool has seven buffers and BUFFER never
\ evicts BLOCK 1 (regression test: test/BLOCK1-PIN-TESTS.f), so the
\ split is no longer required; it is kept as it stands.
\ ---------------------------------------------------------------------
\

.( CHOMP-MAZE-TESTS )

NEEDS TESTING

\ lib/testing.f ends in HEX; the game is compiled decimal.
DECIMAL


\ =========================================================================
\ 1. BLOCK arithmetic -- the kind of off-by-one this project has already
\    hit elsewhere with block offsets, so it is checked by hand here too.
\    Screen 740 -> blocks 1480/1481; Screen 741 -> blocks 1482/1483.
\    No disk access: this is pure arithmetic.
\ =========================================================================

T{ 1 maze-blk0 -> 1480 }T
T{ 2 maze-blk0 -> 1484 }T
T{ 3 maze-blk0 -> 1488 }T


\ =========================================================================
\ 2. the pipeline preserves the game exactly: loading disk maze #1 from
\    Screen 740/741 must reproduce maze-run byte-for-byte identical to
\    the compiled maze-base path.  This is the acceptance test for the
\    whole slice ("does the pipeline preserve the game"), and it is what
\    brings maze #1's three blocks into the buffer pool -- every later
\    test that touches disk re-uses them rather than reading new ones.
\ =========================================================================

create maze-run-save  24 21 * allot

: save-maze-run ( -- )
    maze-run maze-run-save 24 21 * cmove ;

variable maze-diff

: maze-run-same? ( -- f )
    0 maze-diff !
    24 21 * 0 do
        i maze-run + c@
        i maze-run-save + c@
        <> if 1 maze-diff ! then
    loop
    maze-diff @ 0= ;

T{ 0 level ! set-maze-run  save-maze-run
   1 level ! set-maze-run  maze-run-same? -> -1 }T


\ =========================================================================
\ 3. MAZE-CHECK: both loader paths (compiled maze-base, disk Screen
\    740/741) must come back clean -- they exercise different branches
\    of maze-check-load, so both need checking, not just one.
\ =========================================================================

T{ 0 MAZE-CHECK  check-errors @ -> 0 }T
T{ 1 MAZE-CHECK  check-errors @ -> 0 }T


\ =========================================================================
\ 4. the dot count is what primes total, so it has to be right, and it
\    has to come from the maze actually loaded.  find-pills is the
\    game's own counter; MAZE-CHECK's is an independent walk over its
\    own buffer, so the two agreeing is meaningful.
\ =========================================================================

: dots-of ( n -- n1 n2 )    \ MAZE-CHECK's count, then find-pills'
    dup MAZE-CHECK dot-count-check @
    swap level ! set-maze-run find-pills maze-dots @ ;

T{ 0 dots-of -> 161 161 }T
T{ 1 dots-of -> 161 161 }T

\ level indexes the mazes cyclically: level n-mazes is maze 0 again, so
\ this reads no disk block at all
T{ n-mazes level ! set-maze-run find-pills maze-dots @ -> 161 }T


\ =========================================================================
\ 5. every maze must leave the hard-coded sprite spawn cells alone --
\    the check itself has to trip when one of them is wrong, or it is
\    just decoration.  Corrupt maze-check-buf after loading maze 0 (the
\    compiled one, so no disk access) and re-run check-spawn alone.
\ =========================================================================

T{ 0 check-errors !
   0 maze-check-load
   [char] A 13 12 check^ c!     \ a wall on Pac-Man's start cell
   check-spawn
   check-errors @ -> 1 }T

T{ 0 check-errors !
   0 maze-check-load
   bl 10 11 check^ c!            \ Ted's door blanked out
   check-spawn
   check-errors @ -> 1 }T


\ =========================================================================
\ 6. MAZE-CHECK actually catches structural problems.  Again no disk
\    write and no disk read: corrupt maze-check-buf directly after a
\    clean load of maze 0 (maze-check-load is public exactly so this is
\    possible), then re-run a check in isolation.
\ =========================================================================

\ isolate an existing pellet: (5,10) is a '.' in the middle of the long
\ open corridor "M...................J" (row index 5); its down
\ neighbour (row 6, col 10) is already a wall letter, but the up
\ neighbour (row 4, col 10) is open corridor too, so wall off all three
\ of up/left/right to seal it into a 1-cell island nothing can reach.
\ Collateral damage elsewhere is fine -- the assertion only checks that
\ SOMETHING trips, not an exact count.
T{ 0 check-errors !
   0 maze-check-load
   [char] A 4 10 check^ c!
   [char] A 5  9 check^ c!
   [char] A 5 11 check^ c!
   check-connectivity
   check-errors @ 0> -> -1 }T

\ a reachable cell on the outer edge: connectivity alone would not
\ catch this (an edge cell is not a "feature"), which is exactly why
\ check-perimeter exists.  Poke the byte-1 reachability marker directly
\ instead of engineering a real leak path -- this tests check-perimeter
\ in isolation, independent of flood-fill's own correctness (already
\ covered by the previous test).
T{ 0 check-errors !
   0 maze-check-load
   1 0 12 check^ c!
   check-perimeter
   check-errors @ -> 1 }T


\ =========================================================================
\ 7. The disk mazes.  Compiled here, run at the ok prompt -- see the
\    note at the top of this file for why it cannot be run from inside
\    an INCLUDE.  T{ -> }T are ordinary colon words in lib/testing.f, so
\    they compile into a definition and work the same way here.
\ =========================================================================

: DISK-MAZE-TESTS ( -- )
    T{ 1 MAZE-CHECK  check-errors @ -> 0 }T
    T{ 2 MAZE-CHECK  check-errors @ -> 0 }T
    T{ 3 MAZE-CHECK  check-errors @ -> 0 }T

    T{ 1 dots-of -> 161 161 }T
    T{ 2 dots-of -> 162 162 }T
    T{ 3 dots-of -> 179 179 }T

    \ the new mazes must really be different layouts, or the level
    \ counter is walking through copies of one and none of the above
    \ proves much
    T{ 2 level ! set-maze-run find-pills maze-dots @ 161 <> -> -1 }T
    T{ 3 level ! set-maze-run find-pills maze-dots @ 161 <> -> -1 }T

    0 level ! set-maze-run find-pills
    cr ." DISK-MAZE-TESTS done - level 0 / maze-run restored" cr ;


\ =========================================================================
\ 8. Stage 5: the maze page.  The INCLUDE of the game has already given
\    LOAD-MAZES; every slot must equal its source row by row (slot 0 the
\    compiled maze-base, slot k the disk maze k), and set-maze-run must
\    never read a block -- that is what lets the ZAP standalone run
\    without !Blocks-64.bin.  Disk mazes are read from here too: since
\    build 2026-09-25 an INCLUDE may read any number of blocks.
\ =========================================================================

T{ mazes-ready @ -> n-mazes }T

\ the maze area lies below HP (so ZAP saves it with the heap) and
\ inside one 8K page, below its watermark (one FAR maps any slot)
T{ hp@  MAZE-HA MAZE-SLOTS 9 lshift +  u< -> 0 }T
T{ MAZE-HA $1FFF and MAZE-SLOTS 9 lshift + page-watermark > -> 0 }T

create slot-row  24 allot

\ set maze-diff if the 24 bytes at a1 and a2 differ
: row-diff ( a1 a2 -- )
    24 0 do
        over i + c@  over i + c@  <> if 1 maze-diff ! then
    loop 2drop ;

\ slot k equals its source.  maze-line (a BLOCK) comes before
\ maze-slot, as in LOAD-MAZES: the other order would compare against
\ whatever page the block read left in MMU7.
: slot-same? ( k -- f )
    0 maze-diff !
    maze-h 0 do
        dup if
            dup i maze-line slot-row raw-row!
        else
            maze-base i 24 * + slot-row 24 cmove
        then
        dup maze-slot i 24 * + slot-row row-diff
    loop drop
    maze-diff @ 0= ;

T{ 0 slot-same? -> -1 }T
T{ 1 slot-same? -> -1 }T
T{ 2 slot-same? -> -1 }T
T{ 3 slot-same? -> -1 }T

\ PREV moves on every BLOCK: read BLOCK 1 (the line being interpreted,
\ always in memory), then play every level -- PREV must not move
: no-block-read? ( -- f )
    1 block drop  prev @
    n-mazes 0 do i level ! set-maze-run loop
    prev @ = ;

T{ no-block-read? -> -1 }T

\ without the page (mazes-ready 0) every level plays maze-base
: fallback-same? ( -- f )
    mazes-ready @  0 mazes-ready !
    0 level ! set-maze-run save-maze-run
    2 level ! set-maze-run maze-run-same?
    swap mazes-ready ! ;

T{ fallback-same? -> -1 }T


\ =========================================================================
\ Back to the state the game expects: level 0, maze-run rebuilt from the
\ compiled maze, pill cache and dot count in step with it.
\ =========================================================================

0 level !
set-maze-run
find-pills

CR .( CHOMP-MAZE-TESTS done - now give DISK-MAZE-TESTS at the ok prompt ) CR

