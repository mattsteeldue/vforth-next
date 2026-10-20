\
\ 074-coming-from-basic.f
\ For readers who know NextBASIC: the ten things that change when you
\ move to vForth, each with a short example side by side with the BASIC
\ it replaces, and the tutorial to read next.  It is the short version
\ of the migration guide, doc/basic-to-vforth/ in the vForth repository
\ (also on the project wiki), which is not on the SD card: that guide
\ follows the NextBASIC manual chapter by chapter, this tutorial only
\ gives the shape of the change.
\
\ vForth-specific notes:
\   - Every example below is a definition, so that it can be tried with
\     its name; nothing else needs loading.
\   - Where BASIC writes a keyword and vForth a word with the same name
\     but another meaning (EXIT, REPEAT, LIST, CODE, ...), the note says
\     so: these false friends are where BASIC habits hurt most.
\
\ Coming from BASIC: Ch.1-25, App.A-D  |  doc/basic-to-vforth/
\ no Brodie counterpart (a bridge for NextBASIC programmers)
\ Reference: sec.2
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   074 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 074 TUTORIAL
\
\ Run it with:  DEMO
\

MARKER NEWTASK

CR
.( --- Tutorial 074: coming from BASIC loaded. ) CR
.(     Type NEWTASK to unload.                 ) CR

\ =========================================================================
\ 1. No line numbers: the program is a set of words
\ =========================================================================
\
\   10 PRINT "Hello"            : HELLO  ." Hello" CR ;
\   RUN                         HELLO
\
\ A colon definition gives a name to a piece of program, and the name is
\ how it is run.  There is no RUN, no GO TO, no GO SUB: a word calls
\ another by naming it, and returns at its ; as a subroutine returns at
\ RETURN.  A program is the last word defined, built on the others.

: HELLO  ( -- )  ." Hello" CR ;
: TWICE-HELLO  ( -- )  HELLO HELLO ;

\   TWICE-HELLO                 => Hello Hello  (on two lines)
\
\ NEW is FORGET name (or a MARKER, like NEWTASK here); LIST is SEE name
\ (NEEDS SEE); SAVE is a source file, compiled again with INCLUDE.
\ Next: tutorial 005.

\ =========================================================================
\ 2. Postfix: the numbers come first
\ =========================================================================
\
\   PRINT 3+4*2                 3 4 2 * + .
\
\ Numbers go on a stack; each word takes its arguments from the top and
\ leaves its result there.  There are no brackets and no priorities:
\ the order of the words is the order of the work.

: AREA  ( w h -- a )  * ;

\   6 7 AREA .                  => 42
\
\ Next: tutorials 001 and 002.

\ =========================================================================
\ 3. Fewer variables: the stack holds the intermediate values
\ =========================================================================
\
\   10 LET w=6: LET h=7         6 7 AREA .
\   20 PRINT w*h
\
\ Values that BASIC keeps in variables for a moment are just passed on
\ the stack.  When a variable is needed, it is a word that leaves an
\ ADDRESS: @ fetches from it, ! stores into it.

VARIABLE SCORE

: ADD-POINTS  ( n -- )  SCORE +! ;

\   10 ADD-POINTS  5 ADD-POINTS  SCORE @ .     => 15
\
\ LET s=s+n is n S +! -- and S alone is an address, not a value.  The
\ commonest mistake is SCORE . which prints the address.  Next: 008.

\ =========================================================================
\ 4. Integers of 16 bits
\ =========================================================================
\
\   PRINT 7/2                   7 2 / .         => 3
\   PRINT 40000                 40000 U.        => 40000
\
\ A number on the stack is a 16-bit integer, -32768 to 32767, or 0 to
\ 65535 read as unsigned (U.).  Division truncates.  Fractions are
\ scaled integers (hundredths, Q8.8: tutorial 064); larger numbers are
\ doubles (tutorial 015); the floating point of BASIC is a library
\ (tutorial 024).  Nothing warns of an overflow: 200 200 * . prints a
\ negative number.

: AVERAGE  ( a b -- n )  + 2/ ;

\   7 8 AVERAGE .               => 7

\ =========================================================================
\ 5. True is -1, and IF comes after its condition
\ =========================================================================
\
\   IF n<0 THEN PRINT "neg"     n 0< IF ." neg" THEN
\
\ The condition is computed first and IF takes it.  THEN does not start
\ the action: it marks the end of it.  A comparison leaves -1 for true,
\ 0 for false; any non-zero number counts as true.

: .SIGN  ( n -- )
    DUP 0< IF  DROP ." negative "  ELSE
    0= IF  ." zero "  ELSE  ." positive "  THEN  THEN ;

\   -5 .SIGN  0 .SIGN  9 .SIGN  => negative zero positive
\
\ IF works only inside a definition.  And IF uses up its flag: the DUP
\ keeps n for the second test, the DROP throws it away when it is not
\ needed -- forget it, and the number stays on the stack.  Next: 006.

\ =========================================================================
\ 6. Loops: DO ... LOOP and BEGIN ... UNTIL
\ =========================================================================
\
\   FOR i=1 TO 5                6 1 DO
\     PRINT i*i;" ";              I I * .
\   NEXT i                      LOOP
\
\ The limit comes first and is not reached: 6 1 DO runs I from 1 to 5.
\ REPEAT ... REPEAT UNTIL c is BEGIN ... c UNTIL; a WHILE c in the
\ middle is BEGIN ... c WHILE ... REPEAT.  False friends: REPEAT closes
\ a loop instead of opening one, and EXIT leaves the whole word, not the
\ loop (LEAVE does that).

: SQUARES  ( -- )  6 1 DO  I I * .  LOOP ;

\   SQUARES                     => 1 4 9 16 25
\
\ Next: 007.

\ =========================================================================
\ 7. Strings are an address and a length
\ =========================================================================
\
\   LET a$="Next": PRINT a$     an address and a length, given to TYPE
\
\ A string is not a value but two numbers: where its characters start,
\ and how many there are.  TYPE prints such a pair.  Slicing is
\ arithmetic on the pair, and nothing is copied.

CREATE NAME$  ," Spectrum Next"

: .LAST4  ( -- )                \ RIGHT$ (a$,4)
    NAME$ COUNT  4 - +  4 TYPE ;

\   NAME$ COUNT TYPE            => Spectrum Next
\   .LAST4                      => Next
\
\ Next: 009, and 021 for VAL (EVALUATE).

\ =========================================================================
\ 8. DATA and DIM are memory with a name
\ =========================================================================
\
\   DATA 31,28,31               CREATE MDAYS 31 C, 28 C, 31 C,
\   DIM s(10)                   CREATE S 10 CELLS ALLOT
\
\ A table is filled when it is compiled, and indexed directly: no READ
\ pointer to move, no RESTORE.  An array is the same memory, reserved
\ with ALLOT and filled later.  Indexes count from 0.

CREATE MDAYS  31 C, 28 C, 31 C,

: DAYS  ( month -- n )  1- MDAYS + C@ ;

\   2 DAYS .                    => 28
\
\ Next: 069 (tables) and 010 (arrays with CREATE ... DOES>).

\ =========================================================================
\ 9. The machine is a word away
\ =========================================================================
\
\   PEEK 23672  POKE a,v        23672 C@   v a C!
\   OUT 254,2                   2 254 P!
\   REG 7,3                     3 7 REG!
\   USR 32768                   a CODE word, or n a CALL#
\
\ PEEK and POKE are C@ and C! (and @ ! for two bytes), the ports and
\ the Next registers have their words in the core, and machine code is
\ written straight into the dictionary with CODE.  The top 8K of memory,
\ $E000-$FFFF, is vForth's heap window: leave it alone.  Next: 040, 041
\ and 027.

\ =========================================================================
\ 10. Errors, and the way back
\ =========================================================================
\
\ An error in vForth prints the word that caused it and a message, and
\ goes back to the prompt: the definitions already compiled stay.  But
\ vForth prints through the BASIC ROM, and an error raised BY THE ROM --
\ a wrong colour after a control code, for instance -- drops to BASIC
\ with its usual report.  Nothing is lost: RUN starts vForth again.
\
\   BYE                         back to BASIC; RUN comes back
\   n LOAD                      runs Screen n of the block file
\   INCLUDE file  NEEDS word    compile a source file / a library word
\
\ Next: 062 (error messages) and 026 (CATCH and THROW).

\ =========================================================================
\ 11. Demo
\ =========================================================================

: DEMO  ( -- )
    CR TWICE-HELLO
    ." 6*7 = " 6 7 AREA . CR
    0 SCORE !  10 ADD-POINTS 5 ADD-POINTS  ." Score: " SCORE @ . CR
    -5 .SIGN 0 .SIGN 9 .SIGN CR
    ." Squares: " SQUARES CR
    .LAST4 ."  has " 2 DAYS . ." days in February" CR ;

\ =========================================================================
\ 12. Simple tests (requires NEEDS TESTING)
\ =========================================================================
\
\ NEEDS TESTING  DECIMAL          \ lib/testing.f leaves BASE in HEX
\ T{  6 7 AREA  ->  42  }T
\ T{  7 8 AVERAGE  ->  7  }T
\ T{  0 SCORE !  10 ADD-POINTS 5 ADD-POINTS  SCORE @  ->  15  }T
\ T{  2 DAYS  3 DAYS  ->  28 31  }T
\ T{  NAME$ C@  ->  13  }T
