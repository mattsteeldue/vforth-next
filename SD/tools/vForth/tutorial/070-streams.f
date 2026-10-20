\
\ 070-streams.f
\ Streams and channels: where the output of EMIT, TYPE and . goes, and
\ how to send it somewhere else.  vForth prints through the ROM, exactly
\ like PRINT, so it inherits BASIC's sixteen streams: SELECT chooses one,
\ VIDEO brings the output back to the screen, and any stream BASIC has
\ opened -- the printer, a file -- can receive the output of any word.
\ Tutorial 003 left device switching for later: this is later.
\
\ vForth-specific notes:
\   - SELECT, VIDEO and DEVICE are core words: no NEEDS for them.
\   - Only output is redirected.  Input always comes from the keyboard
\     (KEY, ACCEPT); files are read through a handle with the F_ words,
\     tutorial 042, not through a stream.
\   - vForth has no OPEN #: a stream other than 2 and 3 must have been
\     opened in BASIC before vForth was started (section 4).
\
\ Coming from BASIC: Ch.20  |  doc/basic-to-vforth/
\ no Brodie counterpart (vForth / ZX Spectrum extension)
\ Reference: sec.2.12.4
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   070 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 070 TUTORIAL
\
\ Run it with:  DEMO
\

MARKER NEWTASK

CR
.( --- Tutorial 070: streams loaded. ) CR
.(     Type NEWTASK to unload.      ) CR

NEEDS [']

\ =========================================================================
\ 1. Streams and channels
\ =========================================================================
\
\ The Spectrum ROM prints one character at a time with RST $10, and
\ RST $10 sends it to the CURRENT stream.  A stream is a number from 0
\ to 15; each open stream is attached to a channel, the device that
\ actually receives the bytes:
\
\   stream   channel   device
\   ------   -------   ------
\     0, 1     "k"     the keyboard and BASIC's lower screen
\     2        "s"     the main screen
\     3        "p"     the printer
\     4-15      --     closed, until BASIC's OPEN # attaches one
\
\ PRINT #n chooses the stream for one statement.  vForth's EMIT ends in
\ the same RST $10, so every word that prints -- EMIT, TYPE, ., .", CR
\ and everything built on them -- goes to the current stream as well.
\ The difference is that the choice is not made per statement: it is a
\ state, which stays until it is changed.
\
\   n SELECT   ( n -- )   makes stream n the current one (the ROM's
\                         CHAN-OPEN, at $1601)
\   VIDEO      ( -- )     back to the screen: 2 SELECT, and 2 stored in
\                         DEVICE
\   DEVICE     ( -- a )   a variable that remembers the "normal" stream

\ =========================================================================
\ 2. Write once, print anywhere
\ =========================================================================
\
\ A word that prints does not need to know where.  Write it for the
\ screen and choose the destination from outside:

: SQUARES  ( -- )
    ." Squares:"
    6 1 DO  SPACE I I * .  LOOP  CR ;

\   SQUARES                     => Squares: 1  4  9  16  25
\   3 SELECT SQUARES VIDEO      the same line, on the printer
\
\ That is BASIC's LPRINT, for any word at all, including the ones that
\ came with the system: 3 SELECT WORDS VIDEO prints the dictionary.
\
\ The pattern -- select, run, back to the screen -- is worth a word of
\ its own.  It takes the execution token of the word to run:

: >STREAM  ( xt n -- )
    SELECT  EXECUTE  VIDEO ;

\   ' SQUARES 3 >STREAM         SQUARES on the printer
\   ' SQUARES 2 >STREAM         SQUARES on the screen

\ =========================================================================
\ 3. Two traps: the "ok" and the errors
\ =========================================================================
\
\ The prompt puts the screen back each time it waits for a new line,
\ but it prints its "ok" BEFORE that.  Typed at the prompt,
\
\   3 SELECT SQUARES
\
\ sends "Squares: ..." AND the "ok" that follows to the printer.  Close
\ the line with VIDEO, or put the whole job in a word that ends with
\ it, as >STREAM does.
\
\ An error is worse.  ERROR prints its message on the current stream,
\ then goes back to the prompt without passing through VIDEO: the
\ message ends up on the printer, or in the file, and the screen shows
\ nothing at all.  Only the next prompt brings the screen back.  When
\ output "disappears", the first thing to try is VIDEO.
\
\ CAVEAT: SELECT on a stream that is not open is BASIC's error
\ "O Invalid stream", raised by the ROM: it drops you back to BASIC,
\ not to the vForth prompt.  RUN resumes vForth.  Streams 0 to 3 are
\ always open; for 4 to 15, see the next section.

\ =========================================================================
\ 4. Streams opened by BASIC: output into a file
\ =========================================================================
\
\ vForth has no OPEN #, but the streams are BASIC's, and BASIC can open
\ one before vForth starts.  To send the list of words into a file:
\
\   in BASIC, before RUN starts vForth (or after BYE):
\       OPEN #13,"o>words.txt"
\   in vForth:
\       13 SELECT WORDS VIDEO
\   back in BASIC (BYE):
\       CLOSE #13
\
\ The two BASIC lines are already in the loader Forth18.bas, as two
\ comments, ready to be edited.  Everything that prints can be captured
\ this way: a listing (n LIST), a directory (DIR), the output of a test
\ suite.  Close the stream before reading the file, or its last bytes
\ may still sit in a buffer.
\
\ For a file that the program itself opens, reads and writes, use a
\ handle instead (F_OPEN, F_WRITE, F_CLOSE: tutorial 042): a handle
\ needs no BASIC, and a program can keep several open at once.

\ =========================================================================
\ 5. Demo: a report, twice
\ =========================================================================
\
\ REPORT prints a small table.  DEMO prints it on the screen, then
\ through >STREAM on the same screen, to show that the word does not
\ change: change the 2 in DEMO into 3 and it goes to the printer.

: .ROW  ( n -- )
    DUP 4 .R  DUP DUP * 6 .R  DUP DUP * * 8 .R  CR ;

: REPORT  ( -- )
    CR ."    n   n*n   n*n*n" CR
    6 1 DO  I .ROW  LOOP ;

: DEMO  ( -- )
    REPORT
    ['] REPORT 2 >STREAM ;

\ =========================================================================
\ 6. Simple tests (requires NEEDS TESTING)
\ =========================================================================
\
\ Where the output goes cannot be tested from inside vForth; what can be
\ checked is that the streams leave the state as they found it.
\
\ NEEDS TESTING  DECIMAL          \ lib/testing.f leaves BASE in HEX
\ T{  ' NOOP 2 >STREAM  DEVICE @  ->  2  }T
\ T{  ' SQUARES 2 >STREAM  ->  }T
