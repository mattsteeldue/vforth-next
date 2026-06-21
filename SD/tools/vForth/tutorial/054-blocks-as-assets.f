\
\ 054-blocks-as-assets.f
\ BLOCK as a binary-asset store: LOAD2BLOCK and the AFX sound library.
\
\ Tutorials 028 (BLOCK mechanism) and 029 (EDIT) treated blocks as source
\ text.  This tutorial shows the author's original use of the BLOCK
\ facility: a block is just a 512-byte record, so it can hold a small
\ BINARY asset instead of code.  Pack one asset per block, label it with
\ its source filename, and you have a fast, self-describing, single-file
\ asset library on the SD card -- no per-asset file open/close at run time.
\
\ The driving case is sound.  The .afx format (Shiru's "AY Sound FX Editor")
\ stores one channel sound effect, frame by frame, in a few dozen bytes.
\ The author collected hundreds of ZX/MSX game effects and wrote LOAD2BLOCK
\ to drop each .afx file into a single block; the AFXframe player
\ (tutorial 050) then reads them straight from blocks -- keeping several in
\ BUFFERs at once and playing them unison across the AY voices.
\
\ no Brodie counterpart (vForth extension)
\ Reference: sec.3 "BLOCK / Screen related" (LOAD2BLOCK); see also tut 028, 050
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   054 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 054 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 054: blocks as assets loaded. ) CR
.(     Type NEWTASK to unload.              ) CR

NEEDS LOAD2BLOCK
NEEDS PAD"
NEEDS .PAD
NEEDS DUMP

\ ===========================================================================
\ 1. The idea: a block is a 512-byte record
\ ===========================================================================
\
\ Nothing forces a block to contain text.  Those 512 bytes can hold any
\ binary blob that fits.  The trick that makes a binary block USABLE is to
\ keep it self-describing: reserve line 0 (the first 64 bytes) for a human
\ label -- the original filename -- and store the payload after it.  Then a
\ plain  n LIST  still shows you what each block holds.

\ ===========================================================================
\ 2. LOAD2BLOCK -- file in, block out
\ ===========================================================================
\
\   LOAD2BLOCK ( n -- )    n = BLOCK number (NOT a screen number!)
\
\ It takes the filename from PAD and:
\   * copies that filename onto line 0 as a Forth comment   ( filename )
\   * loads up to 448 bytes of the file from line 1 onward  (512 - 64)
\   * marks the block dirty with UPDATE  (it does NOT FLUSH)
\
\ PAD is volatile -- set it with PAD" immediately before the call.
\
\ WARNING -- block vs screen numbers (tut 028): LOAD2BLOCK addresses a
\ 512-byte BLOCK directly.  Block 4402 is the first half of Screen 2201,
\ NOT Screen 4402.  Pick block numbers, not screen numbers.
\
\ The payload limit is 448 bytes: small assets only (most .afx fit easily).
\ The geometry:
\   line 0 ........ C/L (64) bytes ... the ( filename ) label
\   data start .... at  BLOCK + C/L
\   data max ...... B/BUF - C/L  =  448 bytes

512 64 - CONSTANT MAX-PAYLOAD     \ = 448

\ ===========================================================================
\ 3. Building a library: the loader loop
\ ===========================================================================
\
\ A library is just a list of  PAD" file  block#  LOAD2BLOCK  lines.
\ This is exactly how the AFX banks are built (see tutorial/afx/*.f).
\ Example, one effect per block starting at block 4402:
\
\   PAD" tutorial/afx/test/test1.afx"  20 LOAD2BLOCK  .PAD CR
\   PAD" tutorial/afx/test/test2.afx"  21 LOAD2BLOCK  .PAD CR
\   ...
\
\ .PAD just echoes the loaded filename so you can watch progress.
\ After loading the whole bank, FLUSH once to persist the lot.

\ ===========================================================================
\ 4. Reading an asset back
\ ===========================================================================
\
\ The label and the payload live at fixed offsets inside the block buffer:

: ASSET-LABEL  ( block# -- a n )    \ the ( filename ) line
    BLOCK  C/L -TRAILING ;          \ address + trimmed length of line 0

: ASSET-DATA   ( block# -- a )      \ start of the binary payload
    BLOCK  C/L + ;                  \ skip the 64-byte label line

: .ASSET-LABEL  ( block# -- )
    ASSET-LABEL TYPE ;

\ ===========================================================================
\ 5. Self-contained demo
\ ===========================================================================
\
\ test1.afx (51 bytes) ships in the repo, so this works from a clean
\ session with the SD/working tree mounted.  It loads the effect into the
\ free scratch block 20 (first half of Screen 10) and inspects it.
\
\ Note: STORE-DEMO marks block 20 dirty but does NOT FLUSH, so nothing is
\ written to the SD card unless you FLUSH yourself.  Run it from the prompt.

20 CONSTANT DEMO-BLK

: STORE-DEMO  ( -- )
    PAD" tutorial/afx/test/test1.afx"
    DEMO-BLK LOAD2BLOCK
    ." Stored: " .PAD CR ;

: SHOW-DEMO   ( -- )
    CR ." Block " DEMO-BLK . ." label:  "
    DEMO-BLK .ASSET-LABEL CR
    ." First 48 payload bytes:" CR
    DEMO-BLK ASSET-DATA 48 DUMP ;

: ASSET-DEMO  ( -- )
    STORE-DEMO SHOW-DEMO ;

\ ===========================================================================
\ 6. Why blocks instead of separate files
\ ===========================================================================
\
\ * Speed: a block read is one buffered access.  Playing from blocks avoids
\   opening and closing a file per sound effect in a tight game loop.
\ * Packing: hundreds of tiny files (each a fraction of a block on disk)
\   collapse into one image with no per-file slack.
\ * Random access by number: "play effect 17" = a block number, no path.
\ * Self-documenting: line 0 carries the source filename, visible with LIST.
\ * One image to ship: the asset bank travels inside !Blocks-64.bin.
\
\ The AFXframe player exploits all of this: it holds several effects in
\ BUFFERs simultaneously and mixes them across the AY's voices (tut 050).

\ ===========================================================================
\ 7. Related original block facilities
\ ===========================================================================
\
\ The same "block as data" idea appears elsewhere in vForth:
\
\   SCREEN-FROM-FILE ( n -- )   load a whole 1 KB file into screen n
\   SCREEN-TO-FILE   ( n -- )   dump screen n back out to a file
\       -- move entire screens between the block store and the filesystem.
\
\   1K>BLOCK  ( a n -- )        copy 512 bytes of RAM into block n (UPDATE)
\   8K>BLOCKS ( a n -- )        snapshot a whole 8K MMU page to 16 blocks
\       -- blocks as a RAM/bank snapshot device.
\
\   GREP  ( -- )   ( NEEDS GREP )   search text across the first 2000 screens
\       -- treat the block store as a searchable corpus.

\ ===========================================================================
\ 8. Tests (geometry only; payload is file-dependent)
\ ===========================================================================
\
\ NEEDS TESTING
\ T{  MAX-PAYLOAD          ->  448   }T
\ T{  C/L                  ->  64    }T
\ T{  DEMO-BLK 2 /         ->  10    }T   \ block 20 is the start of screen 10
\ The actual stored bytes depend on test1.afx; verify by eye with ASSET-DEMO.
