\
\ 042-file-io.f
\ File I/O via NextZXOS: LOAD-BYTES, SAVE-BYTES, PAD" and SAVE.
\
\ vForth uses NextZXOS (the ZX Next operating system) for file access.
\ Low-level access uses the dot-command F_OPEN, F_READ, F_WRITE,
\ F_CLOSE from the NextZXOS API.  Higher-level wrappers LOAD-BYTES
\ and SAVE-BYTES make it easy to load or save a block of memory to
\ a named file on the SD card.  File names follow DOS 8.3 convention
\ on a FAT filesystem.  Paths use forward slashes.
\
\ Reference: sec.9
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   042 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 042 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 042: File I/O loaded. ) CR
.(     Type NEWTASK to unload.     ) CR

NEEDS LOAD-BYTES
NEEDS SAVE-BYTES

\ ===========================================================================
\ 1. PAD" -- set PAD to a filename string
\ ===========================================================================
\
\ LOAD-BYTES and SAVE-BYTES take the filename from PAD.
\ PAD" copies a string literal into PAD followed by a NUL byte.
\
\   PAD" filename.ext"
\
\ PAD is a scratch buffer always located 68 bytes above HERE.
\ PAD content is volatile: any HERE-altering operation (,  C,  ALLOT)
\ can overwrite it.  Set up PAD immediately before calling LOAD-BYTES
\ or SAVE-BYTES.
\
\ The space between PAD" and the opening quote is mandatory.

\ ===========================================================================
\ 2. LOAD-BYTES -- load bytes from a file
\ ===========================================================================
\
\   LOAD-BYTES ( a n -- )
\
\   a : destination address in memory (should be < $E000)
\   n : maximum number of bytes to read
\
\ LOAD-BYTES opens the file named in PAD, reads up to n bytes into
\ memory starting at address a, then closes the file.
\ Any NextZXOS error triggers ERROR with a code:
\   41  ($29) : file open error   (e.g. file not found)
\   46  ($2E) : file read error
\   42  ($2A) : file close error
\
\ Example: load 4096 bytes at $8000 from "data.bin":
\   PAD" data.bin"
\   HEX $8000 $1000 LOAD-BYTES
\
\ Example: load a file to PAD (careful -- PAD is small):
\   PAD" config.txt"
\   PAD 68 LOAD-BYTES

\ ===========================================================================
\ 3. SAVE-BYTES -- save bytes to a file
\ ===========================================================================
\
\   SAVE-BYTES ( a n -- )
\
\   a : source address in memory
\   n : number of bytes to write
\
\ SAVE-BYTES creates a new file named in PAD and writes n bytes from
\ address a.  The file must NOT already exist (open flags %0110 =
\ create new).  Any NextZXOS error triggers ERROR:
\   41  : file open error   (file already exists, or disk full)
\   47  : file write error
\   42  : file close error
\
\ Example: save the first 256 bytes of screen memory to "snap.bin":
\   PAD" snap.bin"
\   HEX $4000 $100 SAVE-BYTES

\ ===========================================================================
\ 4. SAVE -- flush modified Forth screens to disk
\ ===========================================================================
\
\ NEEDS SAVE (loads inc/save.f)
\
\   SAVE ( -- )   UPDATE FLUSH
\
\ This is the standard Forth UPDATE+FLUSH idiom: mark the current
\ buffer as modified, then write all modified screens back to disk.
\ Used to persist changes to Forth source screens (block files).

\ ===========================================================================
\ 5. Demo: save and reload a buffer
\ ===========================================================================

DECIMAL

CREATE DATA-BUF  256 ALLOT

: FILL-BUF  ( -- )
    256 0 DO  I DATA-BUF I + C!  LOOP
;

: SAVE-BUF  ( -- )
    ." Saving 256 bytes to test-out.bin..." CR
    PAD" test-out.bin"
    DATA-BUF 256 SAVE-BYTES
    ." Done." CR
;

: LOAD-BUF  ( -- )
    ." Loading 256 bytes from test-out.bin..." CR
    PAD" test-out.bin"
    DATA-BUF 256 LOAD-BYTES
    ." Done." CR
;

: VERIFY-BUF  ( -- )
    ." Verifying..." CR
    256 0 DO
        DATA-BUF I + C@ I =
        0= IF
            ." Mismatch at " I . CR
        THEN
    LOOP
    ." Verify complete." CR
;

: FILE-ROUNDTRIP  ( -- )
    FILL-BUF
    SAVE-BUF
    DATA-BUF 256 0 FILL   \ zero the buffer
    LOAD-BUF
    VERIFY-BUF
;

\ ===========================================================================
\ 6. Filename conventions
\ ===========================================================================
\
\ SD card uses FAT filesystem with 8.3 filenames.
\ Paths use forward slashes.  Root is the SD card root.
\
\ Examples:
\   PAD" test.bin"             \ current directory
\   PAD" C:/games/mygame.nex"  \ absolute path
\   PAD" /nextzxos/autoexec.bas"
\
\ NextZXOS supports long filenames on FAT32 volumes, but 8.3 is
\ safer and faster.

\ ===========================================================================
\ 7. Error handling
\ ===========================================================================
\
\ ?ERROR ( f n -- )  if f is non-zero, throw error n
\
\ NextZXOS error codes (decimal):
\   41  open error     (file not found, permission denied)
\   42  close error
\   44  directory error
\   45  seek error
\   46  read error
\   47  write error
\   48  rename error
\
\ LOAD-BYTES and SAVE-BYTES call ?ERROR automatically.

\ ===========================================================================
\ 8. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ File tests require an SD card and cannot run without hardware.
\ The DATA-BUF fill logic can be verified:
\
\ NEEDS TESTING
\ T{  FILL-BUF  DATA-BUF 0 + C@  ->  0   }T
\ T{             DATA-BUF 1 + C@  ->  1   }T
\ T{             DATA-BUF 255 + C@  ->  255  }T
