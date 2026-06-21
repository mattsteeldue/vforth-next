\
\ 028-blocks.f
\ BLOCK: native Forth mass storage -- buffers, screens, LIST, LOAD.
\
\ Long before files, Forth stored both source code and data in fixed-size
\ records called BLOCKs, kept in one big file (or on raw disk).  vForth
\ keeps the tradition: the file !Blocks-64.bin on the SD card is a flat
\ array of records that BLOCK reads into RAM buffers on demand and FLUSH
\ writes back.  This is the substrate the whole Screen# 800-905 corpus
\ (the Starting FORTH transcription) and the AFX sound library run on.
\
\ vForth specifics you must keep straight:
\   * A BLOCK is 512 bytes (not the classic 1024).
\   * A SCREEN is 1 KB = two consecutive blocks: Screen n = BLOCK 2n, 2n+1.
\   * BLOCK ( n -- a ) works in 512-byte block units.
\   * LIST / INDEX / (LINE) / .LINE work in SCREEN units (16 lines of 64).
\ Mixing the two numbering systems is the classic beginner mistake.
\
\ Starting FORTH (Brodie): Ch.3, Ch.10  |  vForth screens 882-895
\ Reference: sec.3 "Block / Screen system"
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   028 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 028 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 028: BLOCK storage loaded. ) CR
.(     Type NEWTASK to unload.          ) CR

\ ===========================================================================
\ 1. Why blocks exist
\ ===========================================================================
\
\ A BLOCK is a 512-byte record stored persistently in !Blocks-64.bin.
\ When you ask for block n, vForth finds (or makes) a 512-byte RAM buffer,
\ reads the record into it, and hands you the buffer address.  You read and
\ write that RAM; nothing touches the SD card until you FLUSH.
\
\ This decouples slow storage from fast RAM: many BLOCK calls, one FLUSH.
\ It is the original Forth idea of virtual memory -- a uniform window onto
\ mass storage that you address by number, not by filename.

\ ===========================================================================
\ 2. Block vs Screen -- the two numbering systems
\ ===========================================================================
\
\   Screen# N   =   BLOCK 2*N   and   BLOCK 2*N+1
\
\ A Screen is the 1 KB unit a programmer edits and LOADs (16 lines x 64).
\ A Block is the 512-byte unit vForth allocates internally.
\
\   Screen 440  ->  blocks 880 and 881
\   block  881  ->  the second half of screen 440
\
\ Words that take a SCREEN number:  LIST  INDEX  (LINE)  .LINE  LOAD
\ Words that take a BLOCK number:   BLOCK  BUFFER
\
\ Helper to convert, for clarity:

: SCR>BLK  ( screen# -- block# )  B/SCR * ;   \ first block of a screen

\ ===========================================================================
\ 3. BLOCK and BUFFER -- getting a buffer address
\ ===========================================================================
\
\   BLOCK  ( n -- a )   read block n from disk into a buffer, return its addr
\   BUFFER ( n -- a )   assign a buffer for block n WITHOUT reading it
\
\ Use BLOCK when you want the existing contents; use BUFFER when you are
\ about to overwrite the whole block (it skips the read).  Both return the
\ address of a B/BUF-byte (512) RAM buffer.
\
\ Example -- show the raw bytes of block 1 (system metadata):
\   1 BLOCK 64 -TRAILING TYPE

: .BLK-HEAD  ( block# -- )   \ print first 64 bytes of a block
    BLOCK 64 -TRAILING TYPE ;

\ ===========================================================================
\ 4. UPDATE, FLUSH, EMPTY-BUFFERS -- the mark-and-write model
\ ===========================================================================
\
\   UPDATE        ( -- )   mark the most recently referenced buffer as dirty
\   FLUSH         ( -- )   write all dirty buffers back to disk
\   EMPTY-BUFFERS ( -- )   discard all buffers WITHOUT writing (abandon edits)
\
\ The cycle is always: BLOCK (get buffer) -> change bytes -> UPDATE (mark)
\ -> ... -> FLUSH (persist).  Forget UPDATE and your change is silently lost
\ on the next buffer reuse.  Forget FLUSH and it never reaches the SD card.
\
\ NEEDS SAVE  gives the standard shorthand:  SAVE  =  UPDATE FLUSH
\
\ WARNING: FLUSH writes to !Blocks-64.bin permanently.  The write demo in
\ section 9 targets Screen 10 (blocks 20-21), documented as free scratch
\ space -- do not point it at a screen holding code you care about.

\ ===========================================================================
\ 5. Geometry constants
\ ===========================================================================
\
\   B/BUF  = 512   bytes per block (buffer)
\   B/SCR  = 2     blocks per screen
\   C/L    = 64    characters per line
\   L/SCR  = 16    lines per screen
\
\ Sanity check (run interactively):
\   B/BUF .   => 512
\   C/L L/SCR * .   => 1024   ( = bytes per screen = B/BUF B/SCR * )

: .GEOMETRY  ( -- )
    CR ." B/BUF=" B/BUF .  ." B/SCR=" B/SCR .
       ." C/L="   C/L .    ." L/SCR=" L/SCR .  CR ;

\ ===========================================================================
\ 6. Reading lines: (LINE), .LINE, LIST, INDEX
\ ===========================================================================
\
\   (LINE) ( line# screen# -- a C/L )  copy a line into a buffer, return addr
\   .LINE  ( line# screen# -- )        print one line (TYPE with -TRAILING)
\   LIST   ( screen# -- )              print all 16 lines, set SCR
\   INDEX  ( s1 s2 -- )                print line 0 of screens s1..s2
\
\ (LINE) is the building block: it resolves a (line, screen) pair to a RAM
\ address, transparently crossing the block boundary inside the screen.
\ LIST is what you type to read a screen of source; INDEX gives a table of
\ contents by showing each screen's first (comment) line.
\
\ Try interactively (read-only, safe):
\   882 LIST            \ list screen 882 (the SCREENS/BLOCKS lister)
\   800 810 INDEX       \ table of contents for screens 800..810
\   0 882 .LINE         \ just the title line of screen 882

: .TITLE  ( screen# -- )   0 SWAP .LINE ;   \ print a screen's line 0

\ ===========================================================================
\ 7. LOAD and --> : a block as source code
\ ===========================================================================
\
\   LOAD ( screen# -- )   interpret screen n as Forth source
\   -->  ( -- )           stop loading this screen, continue with the next
\
\ LOAD feeds a screen's text to the interpreter exactly as if you had typed
\ it.  -->  (typed at the end of a screen) chains to screen n+1, so a long
\ program can span many screens.  This is how vForth loads the libraries
\ that NEEDS does not cover, and how the boot AUTOEXEC runs `11 LOAD`.
\
\ Note: classic Forth THRU (load a range) is NOT a vForth word.  To load a
\ range, chain screens with --> or loop:  D2 D1 DO I LOAD LOOP .
\
\ (No live demo here: LOADing a screen executes whatever it contains.)

\ ===========================================================================
\ 8. Reserved blocks and switching the block file
\ ===========================================================================
\
\   BLOCK 1        : system metadata + copyright.  Never edited by EDIT; the
\                    core reuses it as the temporary line buffer for
\                    F_INCLUDE, so INCLUDE/NEEDS depend on it.
\   Screens 4-7    : standard error message text (blocks 8-15), read by
\                    ?ERROR -> ERROR -> MESSAGE.
\   Screen 10      : free for end-user scratch (blocks 20-21).
\   Screen 11      : AUTOEXEC -- runs INCLUDE lib/autoexec.f at boot.
\
\   USE ( -- )  <name>   switch the active block file at run time:
\     USE /tools/vforth/myblocks.bin
\
\ USE lets you keep separate block files for separate projects.

\ ===========================================================================
\ 9. Demo: a non-destructive read, and a guarded write
\ ===========================================================================

\ --- read demo: dump a screen's title and first data line, no writes ---
: PEEK-SCREEN  ( screen# -- )
    CR ." Screen "  DUP .  ." :" CR
    DUP .TITLE  CR              \ line 0 (comment/title)
    1 SWAP .LINE  CR ;          \ line 1 (first body line)

\ --- write demo: store a short note into Screen 10, line 0, then persist ---
\ Run SAVE-NOTE only when you accept that block 20 on SD will change.
\ NOTE$ is a counted string: ," lays down length byte + text + NUL,
\ and COUNT ( a -- a+1 n ) splits it into address and length.
NEEDS SAVE

CREATE NOTE$  ," ( tutorial 028 wrote here )"

: SAVE-NOTE  ( -- )
    10 SCR>BLK           ( block# )      \ first block of screen 10 = 20
    BUFFER               ( a )           \ fresh buffer, no read
    DUP B/BUF BLANK      ( a )           \ wipe 512 bytes to spaces
    NOTE$ COUNT          ( a c-addr u )  \ source text and its length
    >R SWAP R>           ( c-addr a u )  \ reorder for CMOVE ( src dst u )
    CMOVE                ( )             \ copy the text onto line 0
    UPDATE FLUSH                         \ persist to !Blocks-64.bin
    ." Wrote note to screen 10. Verify with: 10 LIST" CR ;

\ ===========================================================================
\ 10. Pitfalls (vForth, silent failures)
\ ===========================================================================
\
\ * Structure across a block boundary: a single definition (e.g. a long
\   colon word or ENUMERATED) must fit inside ONE 512-byte block.  If it
\   straddles the join between the two blocks of a screen, LOAD breaks.
\   Split the definition so it ends before the boundary.
\
\ * NUL byte (0x00) in a screen: LOAD stops interpreting at the NUL with no
\   error message.  If a screen "loads halfway", hunt for a 0x00 with EDIT.
\
\ * Block vs screen numbers: LIST 440 reads screen 440 = blocks 880-881.
\   BLOCK 440 reads the 512-byte block 440 = the first half of screen 220.
\   They are different records -- keep the unit straight.

\ ===========================================================================
\ 11. Simple tests (requires NEEDS TESTING; geometry only -- no disk writes)
\ ===========================================================================
\
\ NEEDS TESTING
\ T{  B/BUF           ->  512   }T
\ T{  B/SCR           ->  2     }T
\ T{  C/L L/SCR *     ->  1024  }T
\ T{  10 SCR>BLK      ->  20    }T
\ T{  441 B/SCR /     ->  220   }T   \ block 441 lives in screen 220
