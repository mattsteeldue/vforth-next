\
\ 005-defining-words.f
\ Building the dictionary: colon-definitions, constants, variables, values.
\
\ In Forth, extending the language and writing a program are the same act.
\ Every : ... ; adds a new word to the dictionary that is indistinguishable
\ from any built-in word.  This is the core loop of Forth development:
\ define a small word, test it interactively, compose larger words from it.
\
\ vForth-specific notes:
\   - VARIABLE initialises its cell to 0 and takes no initial value on the
\     stack (standard behaviour since v1.52).  Old code that passed a value
\     before VARIABLE will leave a spurious cell on the stack.
\   - VALUE and TO require NEEDS VALUE and NEEDS TO respectively.
\   - +! (add-to-memory) is a built-in useful shorthand for many patterns.
\
\ Reference: sec.2.12.9, 6.1 (CONSTANT, VARIABLE, VALUE)
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   005 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 005 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 005: defining words loaded. ) CR
.(     Type NEWTASK to unload.   ) CR

NEEDS VALUE                         \ for VALUE
NEEDS TO                            \ for TO


\ ===========================================================================
\ 1. Colon-definitions
\ ===========================================================================
\
\ : name  ( stack-comment )  ... body ... ;
\
\ The stack comment is a convention, not syntax  --  the system ignores it.
\ It documents what the word consumes and produces, and is essential for
\ readability.  Always write it.
\
\ : DOUBLE  ( n -- n*2 )  2* ;
\ : TRIPLE  ( n -- n*3 )  DUP 2* + ;
\
\   7 DOUBLE .          => 14
\   7 TRIPLE .          => 21
\
\ EXIT forces an early return from a colon-definition.  Use it sparingly;
\ a definition that exits from multiple points is hard to reason about.

: DOUBLE  ( n -- n*2 )  2* ;
: TRIPLE  ( n -- n*3 )  DUP 2* + ;


\ ===========================================================================
\ 2. CONSTANT
\ ===========================================================================
\
\ n CONSTANT name
\
\ When name is executed it pushes n.  The value is fixed at definition time
\ and cannot be changed afterward.  Use constants for named magic numbers.
\
\ 42        CONSTANT THE-ANSWER
\ $4000     CONSTANT SCREEN-BASE
\ 3         CONSTANT LIVES
\
\   THE-ANSWER .        => 42
\   SCREEN-BASE .       => 16384

42      CONSTANT THE-ANSWER
$4000   CONSTANT SCREEN-BASE
3       CONSTANT LIVES


\ ===========================================================================
\ 3. VARIABLE
\ ===========================================================================
\
\ VARIABLE name
\
\ Creates name with a zero-initialised 16-bit cell.
\ Executing name pushes the *address* of that cell (its PFA), not the value.
\ Use @ to read, ! to write, ? as shorthand for @ . , and +! to add in place.
\
\   VARIABLE SCORE
\   SCORE @  .          => 0          (initial value)
\   100 SCORE !
\   SCORE ?             => 100        (shorthand for SCORE @ .)
\   50  SCORE +!
\   SCORE ?             => 150        (+! adds to the stored value)
\
\ Warning: do *not* put a value on the stack before VARIABLE  --  it is not
\ consumed and will corrupt the stack.  Old vForth code may do this.

VARIABLE SCORE
VARIABLE LIVES-LEFT


\ ===========================================================================
\ 4. VALUE / TO
\ ===========================================================================
\
\ n VALUE name     --  creates name; executing it returns n directly (no @).
\ n TO name        --  stores n into name (no ! needed).
\
\ VALUE reads like a constant but can be updated with TO.
\ The syntax is cleaner than VARIABLE for single-cell state that is
\ frequently read and occasionally updated.
\
\   10 VALUE LEVEL
\   LEVEL .             => 10
\   20 TO LEVEL
\   LEVEL .             => 20
\
\ Inside a colon-definition TO compiles a store at compile time:
\   : NEXT-LEVEL  ( -- )  LEVEL 1+ TO LEVEL ;

10 VALUE LEVEL


\ ===========================================================================
\ 5. +!  --  add to memory
\ ===========================================================================
\
\ n +! a    --  equivalent to:  a @  n +  a !
\ A built-in shorthand; avoids the DUP/@ dance for incrementing a variable.
\
\   100 SCORE !
\   50  SCORE +!
\   SCORE ?             => 150


\ ===========================================================================
\ 6. Choosing between CONSTANT, VARIABLE, and VALUE
\ ===========================================================================
\
\ CONSTANT   --  fixed forever; use for named literals (screen addresses,
\             bit masks, hardware port numbers).
\ VARIABLE   --  mutable cell; address-oriented access via @/!; use when
\             you need to pass the address to other words (e.g. arrays,
\             FILL, CMOVE targets).
\ VALUE      --  mutable cell; value-oriented access via name/TO; use for
\             simple scalar state that is read often and written rarely.
\             Requires NEEDS VALUE / NEEDS TO.


\ ===========================================================================
\ 7. Demonstration
\ ===========================================================================

: INIT-GAME  ( -- )
    0     SCORE !
    LIVES LIVES-LEFT !
    1     TO LEVEL ;

: AWARD-POINTS  ( n -- )
    SCORE +! ;

: SHOW-STATUS  ( -- )
    ." Score=" SCORE ? ."  Lives=" LIVES-LEFT ? ."  Level=" LEVEL . CR ;

INIT-GAME
.( Try: 250 AWARD-POINTS  SHOW-STATUS ) CR
.( Try: 2 TO LEVEL  SHOW-STATUS       ) CR


\ ===========================================================================
\ 8. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ NEEDS TESTING
\ T{  7 DOUBLE       -> 14         }T
\ T{  7 TRIPLE       -> 21         }T
\ T{  THE-ANSWER     -> 42         }T
\ T{  0 SCORE !  SCORE @  -> 0     }T
\ T{  100 SCORE !  SCORE @ -> 100  }T
\ T{  50 SCORE +! SCORE @  -> 150  }T
\ T{  LEVEL             -> 10      }T
\ T{  20 TO LEVEL  LEVEL -> 20     }T
