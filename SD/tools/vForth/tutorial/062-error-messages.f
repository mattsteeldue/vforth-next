\
\ 062-error-messages.f
\ The numbered error messages: how ?ERROR, ERROR and MESSAGE work
\ together, where the text actually lives, and how to add your own.
\
\ Forth has two ways of saying "this cannot go on". One compiles the
\ text of the complaint into the definition that raises it (ABORT"); the
\ other compiles only a number, and looks the text up in the block file
\ when the error actually happens (?ERROR). vForth inherits the second
\ mechanism from fig-FORTH and uses it throughout its own library, for
\ reasons this tutorial makes concrete -- the decisive one being that an
\ error raised while compiling your source can tell you WHERE it
\ happened, which a compiled-in string cannot.
\
\ vForth-specific notes:
\   - The message number is not an index into a table with bounds: it is
\     arithmetic on the block file. Any number works, including numbers
\     far outside the reserved area and negative ones, and nothing warns
\     you when you land on the wrong screen. Section 9 shows exactly how
\     the number becomes a disk address.
\   - ABORT" in vForth is NOT built on THROW: it compiles TYPE + ABORT.
\     A CATCH therefore never sees it (section 7).
\   - Messages live in the block file, not in the binary. A standalone
\     executable built with the core alone has the mechanism but not the
\     text -- see tutorial 059.
\
\ Starting FORTH (Brodie): no Brodie counterpart (the numbered-message
\ mechanism is fig-FORTH heritage, outside Starting FORTH's scope).
\ Reference: sec.2 (core words: ?ERROR, ERROR, MESSAGE, WARNING),
\ sec.3 "Block / Screen system".
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   062 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 062 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 062: error messages loaded. ) CR
.(     Type NEWTASK to unload.              ) CR

NEEDS ABORT"
NEEDS WHERE

\ =========================================================================
\ 1. Two ways to raise an error
\ =========================================================================
\
\ The numbered form. The flag comes first, the message number second:
\
\   f n ?ERROR      ( f n -- )
\
\ If f is true, message n is displayed and control returns to the prompt.
\ If f is false, n is simply dropped and execution continues.

: SAFE-DIVIDE   ( n1 n2 -- n3 )
    DUP 0=  #13 ?ERROR          \ #13 = "Division by zero."
    /
;

\   10 2 SAFE-DIVIDE .      => 5
\   10 0 SAFE-DIVIDE .      => 0 ? Division by zero.

\ The string form. It is IMMEDIATE, so it works only inside a definition,
\ and it takes the flag alone -- the text is parsed at compile time:

: SAFE-DIVIDE-2 ( n1 n2 -- n3 )
    DUP 0=  ABORT" division by zero"
    /
;

\   10 0 SAFE-DIVIDE-2 .    => division by zero

\ Both stop the program and return to the prompt. What they cost, and
\ what they tell you, is very different -- sections 3 and 6.

.( Try: 10 2 SAFE-DIVIDE .   ) CR
.( Try: 10 0 SAFE-DIVIDE .   ) CR


\ =========================================================================
\ 2. The chain: ?ERROR -> ERROR -> MESSAGE
\ =========================================================================
\
\ Three core words, each doing one job:
\
\   ?ERROR  ( f n -- )    tests the flag; if true, calls ERROR
\   ERROR   ( n -- )      reports and abandons the current work
\   MESSAGE ( n -- )      prints the text of message n and nothing else
\
\ MESSAGE on its own is harmless: it prints and returns. Try it.

.( Try: #13 MESSAGE          ) CR   \ => Division by zero.
.( Try: #0  MESSAGE          ) CR   \ => is undefined.

\ ERROR is the interesting one. In order it:
\
\   1. prints the last word parsed  ( HERE COUNT TYPE ) followed by  ?
\      -- this is why an unknown word prints  FOO ? is undefined.
\      and message #0 reads as a sentence with no subject;
\   2. prints the message;
\   3. empties the data stack     ( S0 @ SP! );
\   4. if BLK is not zero -- i.e. the error happened while LOADing or
\      INCLUDEing -- pushes  >IN  and  BLK  back onto the now-empty
\      stack, for WHERE to consume (section 6);
\   5. calls QUIT.
\
\ Point 5 has a consequence worth knowing. QUIT resets STATE and the
\ return stack, but it is ABORT -- not ERROR -- that does
\ FORTH DEFINITIONS and DECIMAL. Code that temporarily switches
\ vocabulary or base must restore it by itself before raising an error;
\ nothing else will. (lib/LOCALS.f is written that way for exactly this
\ reason.)


\ =========================================================================
\ 3. Why the library prefers ?ERROR
\ =========================================================================
\
\ Cost. A numbered error compiles a literal plus a call: about five
\ bytes, no text. ABORT" compiles a branch, (H"), a heap pointer, TYPE
\ and ABORT -- about twelve bytes -- PLUS the string itself, which lives
\ forever in the MMU7 heap it shares with the dictionary name-space.
\
\ Diagnosis. ERROR prints the offending token and, inside a LOAD or an
\ INCLUDE, leaves the position for WHERE. ABORT" prints its string and
\ loses the position entirely.
\
\ Dependencies. ?ERROR is a core word. ABORT" needs inc/abort".f, which
\ needs S", which needs H" and the heap.
\
\ Centralisation. The texts sit in one place, are editable with EDIT,
\ can be listed with 9 LOAD, and are shared by every module.
\
\ The trade is real, though, and runs the other way for applications:
\ a numbered message needs a slot in a global, shared table, and a
\ program shipped on its own against a different block file will print
\ the wrong line. So:
\
\   - inc/ and lib/ -- the library that ships as the compendium of the
\     vForth core -- use ?ERROR;
\   - your own application sources may use ABORT" freely. It is
\     self-contained, and the cost is paid by the program that chose it.


\ =========================================================================
\ 4. Where the text lives
\ =========================================================================
\
\ The standard messages occupy Screens 4 to 8 (BLOCKs 8 to 17), sixteen
\ lines per Screen, one message per line, counted straight through:
\
\   Screen 2  -> messages -32 .. -17    negative area, see below
\   Screen 3  -> messages -16 ..  -1
\   Screen 4  -> messages  #0 ..  #15
\   Screen 5  -> messages #16 ..  #31
\   Screen 6  -> messages #32 ..  #47
\   Screen 7  -> messages #48 ..  #63
\   Screen 8  -> messages #64 ..  #79
\
\ so the mapping in both directions is simple arithmetic:
\
\   message# = ( screen# - 4 ) * 16 + line#
\   screen#  = 4 + message# / 16        line# = message# MOD 16
\
\ Note that #16, #32, #48 and #64 fall on the first line of a Screen,
\ which by convention carries a  ( Error messages ... )  header comment.
\ Those four numbers are spent, not free.
\
\ Screens 2 and 3 hold the NEGATIVE messages -32 to -1. They exist
\ because THROW falls back to ERROR when nothing caught it (section 7),
\ and the standard THROW codes are negative. The two Screens carry the
\ Forth-2012 table, in vForth wording:
\
\   #-1  Aborted.                     #-13 is undefined.
\   #-2  Aborted with message.        #-14 is a compile-only word.
\   #-3  Stack full.                  #-15 Invalid FORGET.
\   #-4  Stack is empty.              ...
\   #-5  Return stack full.           #-25 Return stack imbalance.
\   #-6  Return stack is empty.       #-28 User interrupt.
\   #-7  DO loops nested too deeply.  #-29 Compiler nesting.
\   #-8  Dictionary full.             #-30 Obsolescent feature.
\   #-9  Invalid memory address.      #-31 was not defined by CREATE.
\   #-10 Division by zero.
\
\ Six of them describe conditions vForth already names in the positive
\ table (#-3 = #7, #-4 = #1, #-8 = #2, #-10 = #13, #-13 = #0), and use
\ deliberately the SAME text, so the same condition reads the same way
\ whichever mechanism reported it.
\
\ Note that nothing in the vForth core raises a negative code by
\ itself -- not even ABORT" (section 7) -- so this area is there for
\ YOUR code to use when it adopts the standard codes. #-32 is the
\ lowest usable number: section 9 explains why, and why that is the
\ right place to stop.
\
\ The word below reproduces MESSAGE's own arithmetic -- offset by 32,
\ then divide -- rather than the shorter  4 + message#/16 . The two
\ agree for positive numbers, but only this one is also right for the
\ negative area, because vForth's /MOD truncates towards zero.

: MSG-AT        ( n -- scr line )       \ where message n is stored
    #32 +                   ( n+32 )
    #16 /MOD                ( line q )
    2 +                     ( line scr )
    SWAP                    ( scr line )
;

: .MSG-AT       ( n -- )
    MSG-AT  SWAP                        ( line scr )
    ." Screen# " .  ." line " .  CR
;

\   #13 .MSG-AT     => Screen# 4 line 13
\   #57 .MSG-AT     => Screen# 7 line 9
\   #-2 .MSG-AT     => Screen# 3 line 14

.( Try: #13 .MSG-AT          ) CR
.( Try: #57 .MSG-AT          ) CR

\ To read a message the way MESSAGE does, use EDIT on the screen, or
\ .LINE, which is what MESSAGE calls internally.


\ =========================================================================
\ 5. Listing the whole table
\ =========================================================================
\
\ There is an old utility for this, stored in the block file itself and
\ written so that it removes itself once it has finished:
\
\   9 LOAD
\
\ Screen 9 defines a MARKER, two words that page through the messages
\ sixteen at a time waiting for a key, and then executes the MARKER --
\ so nothing of it is left in the dictionary afterwards. It is a good
\ small example of the auto-forgetting utility idiom (see tutorial 028
\ for LOAD and the block editor).
\
\ A local equivalent, for a range you choose:

: MSG-LIST      ( n1 n2 -- )
    1+ SWAP ?DO
        CR  I 3 .R  ." : "  I MESSAGE
    LOOP
    CR
;

\   #48 #63 MSG-LIST        \ everything on Screen 7

.( Try: 9 LOAD               ) CR
.( Try: #48 #63 MSG-LIST     ) CR


\ =========================================================================
\ 6. Finding the offending line: WHERE
\ =========================================================================
\
\ This is the property that decides the whole question for library code.
\ When an error is raised while a file or a screen is being interpreted,
\ ERROR leaves  >IN BLK  on the stack. WHERE ( n1 n2 -- ) turns that pair
\ into a report:
\
\   INCLUDE myfile.f
\   FOO ? is undefined.
\   ok
\   WHERE
\   Screen# 1
\     3 : BAR  10 FOO + ;
\                    ^
\
\ Screen number, row, the row itself, and a caret under the column that
\ was being read. Type WHERE immediately after the error: any other
\ command that touches the stack destroys the pair.
\
\ ABORT" cannot offer this. Its string is printed by TYPE and then ABORT
\ resets everything, position included. For an error raised while
\ compiling somebody else's source, that is the difference between a
\ diagnosis and a complaint.


\ =========================================================================
\ 7. The other roads into ERROR
\ =========================================================================
\
\ THROW without a CATCH. inc/throw.f falls back to ERROR when HANDLER is
\ zero, so an uncaught  n THROW  prints message n exactly as  n ERROR
\ would. Numbers and messages are therefore shared between the two
\ mechanisms -- which is precisely why Screens 2 and 3 exist: the
\ standard THROW codes are negative, and each of them has a line
\ waiting for it there.
\
\   -13 THROW           => msg# -13      ( uncaught: Screen 3, line 3 )
\
\ Choose your own positive throw codes with the same care you would
\ choose message numbers: they are the same number space.
\
\ ABORT" inside a CATCH does NOT work. In vForth, ABORT" compiles
\ S" TYPE ABORT , not a THROW: ABORT resets both stacks and jumps to
\ QUIT, straight through the CATCH frame, which therefore never returns.
\ Use  n THROW  (or a plain flag) if the caller is meant to recover;
\ reserve ABORT" for conditions from which there is no recovery.
\ See tutorial 026 for CATCH and THROW proper.


\ =========================================================================
\ 8. Adding your own messages
\ =========================================================================
\
\ Two situations, two different answers.
\
\ (a) You are extending the vForth library itself (a new inc/ or lib/
\     module). Take free slots inside the standard area and document
\     them at the top of your module. Free at the time of writing:
\     #55, #61, #62 on Screen 7, and #65 to #78 on Screen 8 (#79 holds
\     a placeholder marking the end of the table) -- check with 9 LOAD
\     before choosing, the table is shared and grows.
\     lib/LOCALS.f is the model to copy: it reserves #57 to #60 and
\     says so in a comment block before its first definition.
\
\     To write the text, edit the screen the arithmetic of section 4
\     points at. Message #66 is Screen 8, line 2:
\
\         8 EDIT              \ then edit line 2, then FLUSH
\
\     Remember the line is 64 characters wide and is printed with
\     -TRAILING, so trailing spaces cost nothing.
\
\ (b) You are writing an application. You are free to use ABORT" and
\     stop here. But if you want numbered messages -- because they are
\     compact, or because your program raises the same complaint from
\     twenty places -- do NOT take slots in the standard area: pick a
\     screen of your own, far from it, and derive the numbers from it.
\
\     Reserving Screen 1504 gives messages #24000 to #24015:
\
\         ( 1504 - 4 ) * 16  =  24000
\
\     Then name them, so the source does not read as bare numbers:

#24000 CONSTANT E-NO-DEVICE     \ Screen 1504 line 0
#24001 CONSTANT E-BAD-HEADER    \ Screen 1504 line 1
#24002 CONSTANT E-DISK-FULL     \ Screen 1504 line 2

: CHECK-HEADER  ( n -- )
    $4B4E -  E-BAD-HEADER ?ERROR
;

\   $4B4E CHECK-HEADER      => nothing happens
\   $0000 CHECK-HEADER      => CHECK-HEADER ? <line 1 of Screen 1504>
\
\ Until you write the text, the message prints as an empty line: the
\ number is valid, the screen is simply blank. Nothing checks that a
\ message exists -- which is the subject of the next section.

.( Try: $4B4E CHECK-HEADER   ) CR


\ =========================================================================
\ 9. Very large -- and negative -- message numbers
\ =========================================================================
\
\ MESSAGE does no range checking whatsoever. It computes a position in
\ the block file and reads whatever is there. In full:
\
\   : MESSAGE   ( n -- )
\       WARNING @ IF   32 +  2  .LINE  SPACE
\                 ELSE ." msg#" .      THEN ;
\
\ that is: line n+32 of Screen 2. .LINE calls (LINE), which is
\
\   : (LINE)  ( line scr -- a len )
\       >R  C/L B/BUF */MOD  R> B/SCR * +  BLOCK +  C/L ;
\
\ With C/L = 64, B/BUF = 512 and B/SCR = 2 this gives, for message n:
\
\   byte offset   = ( n + 32 ) * 64
\   block         = ( n + 32 ) * 64 / 512  +  2 * 2
\   offset in it  = ( n + 32 ) * 64 MOD 512
\
\ which for n >= 0 simplifies to block = 8 + n/8, offset = (n MOD 8)*64.
\ Check it against the known case: message #0 lands on block 8 offset 0,
\ and BLOCK 8 is indeed the first half of Screen 4.

: MSG-BLOCK     ( n -- blk off )        \ the disk position of message n
    #32 +                   ( n+32 )
    8 /MOD                  ( r q )
    4 +                     ( r blk )
    SWAP  C/L *             ( blk off )
;

\   #0    MSG-BLOCK     => 8 0
\   #57   MSG-BLOCK     => 15 64
\   10000 MSG-BLOCK     => 1258 0
\
\ The crucial detail is that */MOD goes through a 32-bit intermediate
\ product ( >R M* R> M/MOD ), so ( n + 32 ) * 64 does not overflow and
\ arbitrarily large message numbers address the block file correctly.
\
\   10000 MESSAGE
\
\ is a perfectly legal request for line 0 of BLOCK 1258 -- that is,
\ Screen 629, first line. On the block file shipped with vForth that
\ screen holds a game source, so the "error message" you get is
\
\   ( Chomp.f )
\
\ which is the point: nothing validates the number, and a wrong one
\ prints whatever text happens to live at that address.
\
\ Downwards the same arithmetic runs into the negative area of
\ section 4, which is deliberate: #-32 is Screen 2 line 0, #-1 is
\ Screen 3 line 15.
\
\ #-32 is also a hard floor, and a well-placed one. The line number
\ MESSAGE computes is n+32, so #-32 is line 0 -- the last value that
\ is still non-negative. And that is exactly where the Forth-2012
\ table stops being about the language core: #-1 to #-32 cover stacks,
\ dictionary, compilation and parsing, while #-33 and below are the
\ block, file and floating-point exceptions -- conditions vForth
\ already reports with its own positive messages #41 to #47
\ (NextZXOS Open / Close / Read / Write error). The arithmetic and the
\ standard happen to agree on where to draw the line.
\
\ Below it the line number goes negative,
\ and */MOD truncates towards zero, so (LINE) gets a NEGATIVE remainder
\ and adds it to the buffer address: it reads 64 bytes BELOW the block
\ buffer, i.e. whatever else happens to be in the buffer ring.
\
\   #-33 MESSAGE        => the tail of some other buffer, e.g.  k full.
\
\ Only multiples of 8 below the floor land cleanly, because their
\ remainder is 0 -- #-40 really does read BLOCK 3, line 0. Everything
\ else is an out-of-buffer read: harmless (it only prints), but
\ meaningless and not reproducible between sessions.
\
\ Practical consequences:
\
\   - a message number is a disk address in disguise: treat a typo in
\     one as you would treat a typo in a BLOCK number;
\   - the block file must be big enough. The standard !Blocks-64.bin is
\     16 MB = 32768 blocks, so message numbers up to about #262000 are
\     addressable;
\   - a module that reserves high numbers is not protected from
\     collision by anything except your own bookkeeping.

.( Try: 10000 MSG-BLOCK . .  ) CR
.( Try: 10000 MESSAGE        ) CR


\ =========================================================================
\ 10. WARNING: the three regimes
\ =========================================================================
\
\ The variable WARNING selects how much of the mechanism is used:
\
\    1   normal. MESSAGE prints line n from the blocks.
\    0   no block file, or no interest in it: MESSAGE prints  msg#n
\        and the number. Nothing is read from disk.
\   -1   silent. ERROR does not print at all: it goes straight to
\        (ABORT). Used when a system must fail without producing output.
\
\ WARNING is set to 1 at start-up. A module that raises a numbered error
\ therefore degrades gracefully rather than crashing when the blocks are
\ unavailable -- but it degrades to a number, which is the strongest
\ argument on ABORT"'s side.

: QUIET-MESSAGE ( n -- )        \ show the same message in both regimes
    WARNING @  >R                       ( n )
    DUP  1 WARNING !  MESSAGE  CR
         0 WARNING !  MESSAGE  CR
    R> WARNING !
;

\   #13 QUIET-MESSAGE
\       => Division by zero.
\       => msg#13

.( Try: #13 QUIET-MESSAGE    ) CR


\ =========================================================================
\ 11. Simple tests (requires NEEDS TESTING)
\ =========================================================================
\
\ The error paths themselves cannot be tested with T{ ... }T -- they end
\ in QUIT rather than returning a value -- but the arithmetic can.
\
\ NEEDS TESTING
\ T{  #0    MSG-AT     ->  4 0      }T
\ T{  #13   MSG-AT     ->  4 13     }T
\ T{  #57   MSG-AT     ->  7 9      }T     \ LOCALS: bad count
\ T{  #79   MSG-AT     ->  8 15     }T     \ last standard message
\ T{  #-1   MSG-AT     ->  3 15     }T     \ negative area
\ T{  #-32  MSG-AT     ->  2 0      }T
\ T{  24000 MSG-AT     ->  1504 0   }T     \ section 8 example
\ T{  #0    MSG-BLOCK  ->  8 0      }T
\ T{  #57   MSG-BLOCK  ->  15 64    }T
\ T{  #-1   MSG-BLOCK  ->  7 448    }T
\ T{  10000 MSG-BLOCK  ->  1258 0   }T
\ T{  10 2 SAFE-DIVIDE ->  5        }T
\
\ Verified by hand, since each returns to the prompt:
\   10 0 SAFE-DIVIDE        -> 0 ? Division by zero.
\   10 0 SAFE-DIVIDE-2      -> division by zero
\   $0000 CHECK-HEADER      -> CHECK-HEADER ? (blank, Screen 1504 empty)
