\
\ 043-filesystem.f
\ Filesystem navigation: CD, PWD, and directory listings.
\
\ vForth can navigate the SD card filesystem using CD (change
\ directory) and PWD (print working directory).  Both words use the
\ NextZXOS IDE_PATH service.  The DIR library word provides a
\ directory listing.  Understanding the filesystem layout is
\ important when using NEEDS, INCLUDE, LOAD-BYTES, and BMP-LOAD,
\ all of which resolve filenames relative to the current directory.
\
\ Reference: sec.3.3
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   043 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 043 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 043: Filesystem navigation loaded. ) CR
.(     Type NEWTASK to unload.               ) CR

NEEDS CD
NEEDS PWD
NEEDS DIR

\ ===========================================================================
\ 1. PWD -- print working directory
\ ===========================================================================
\
\   PWD ( -- )   print current directory path
\
\ PWD calls IDE_PATH with a single "." to query the current path.
\ The result is printed as a string to the current output device.
\
\ Example:
\   PWD    \ might print   C:/NextZXOS/vForth

\ ===========================================================================
\ 2. CD -- change directory
\ ===========================================================================
\
\   CD  path    (word reads path from the input stream)
\
\ CD reads a filename from the input stream (terminated by whitespace)
\ and changes the current directory to that path.  Uses IDE_PATH
\ service 0 (change directory).
\
\ Warning: changing directory with CD affects where NEEDS and INCLUDE
\ look for files.  vForth NEEDS searches inc/ and lib/ relative to
\ the directory where it was started.  After a CD, you must either
\ CD back or use absolute paths.
\
\ Examples:
\   CD C:/NextZXOS/vForth    \ absolute path
\   CD tutorial              \ relative path
\   CD ..                    \ parent directory
\   CD /                     \ root directory
\
\ Note: there must be a space between CD and the path.

\ ===========================================================================
\ 3. DIR -- list directory contents
\ ===========================================================================
\
\ NEEDS DIR (loads lib/DIR.f).  DIR prints a formatted listing of
\ files and subdirectories in the current directory.
\
\ Usage:
\   NEEDS DIR
\   DIR
\
\ When a directory holds many entries, the listing scrolls and the
\ first lines roll off the top of the screen.  Between entries DIR
\ polls ?ESCAPE (one of the first NEEDS in lib/DIR.f): while EDIT
\ (SHIFT+1) is held, ?ESCAPE stays true and DIR spins in place, so
\ scrolling is suspended and the first entries stay in view; release
\ the key and the listing continues.

\ ===========================================================================
\ 4. Filesystem layout on a typical ZX Next SD card
\ ===========================================================================
\
\ Root directory (C:/)
\   /nextzxos/           NextZXOS system files
\     autoexec.bas       startup script
\     spectrum.rom       ROM image
\   /vForth/             vForth installation
\     vForth.bas         launcher
\     vForth             main binary
\     inc/               include files for NEEDS
\     lib/               library files for NEEDS
\     tutorial/          tutorial source files
\   /demos/              demo programs
\   /games/              games
\
\ vForth starts in /vForth (or wherever vForth.bas sets the path).
\ NEEDS searches inc/ and lib/ relative to the vForth start directory.

\ ===========================================================================
\ 5. INCLUDE -- load a source file
\ ===========================================================================
\
\   INCLUDE path/file.f
\
\ INCLUDE is a core word that opens the named file and interprets it
\ as Forth source.  The path is relative to the current directory.
\
\ Examples:
\   INCLUDE tutorial/042-file-io.f
\   INCLUDE lib/GRAPHICS.f

\ ===========================================================================
\ 6. Demo: show current location and navigate
\ ===========================================================================

: WHERE-AM-I  ( -- )
    ." Current directory: " PWD CR
;

\ ===========================================================================
\ 7. Demo: safe CD with restore
\ ===========================================================================
\
\ To temporarily navigate to a directory and return:
\
\   PWD      \ print and note current path
\   CD demos
\   \  ... do stuff in demos/ ...
\   CD C:/NextZXOS/vForth     \ or wherever you started

\ ===========================================================================
\ 8. File naming rules
\ ===========================================================================
\
\ FAT filesystem rules for the ZX Next SD card:
\   - Case-insensitive (both upper and lower case work)
\   - 8.3 format recommended (8-char name, 3-char extension)
\   - Forward slashes for path separators
\   - Drive letter prefix optional: C: is the SD card
\   - No spaces in names unless quoted (vForth does not handle quotes
\     in INCLUDE or PAD" -- keep names space-free)
\
\ NEEDS searches:
\   1. inc/NAME.f    (with capital NAME)
\   2. lib/NAME.f    (with capital NAME)
\ So NEEDS GRAPHICS finds lib/GRAPHICS.f automatically.

\ ===========================================================================
\ 9. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ CD and PWD have side effects (filesystem state changes) and require
\ an SD card.  They cannot be tested automatically here.
\
\ NEEDS TESTING
\ T{  0  ->  0  }T   \ placeholder: no automatic filesystem tests
