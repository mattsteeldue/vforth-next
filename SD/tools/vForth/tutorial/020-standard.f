\
\ 020-standard.f
\ Compilation internals: STATE, [ ], IMMEDIATE, COMPILE,, POSTPONE.
\ (Standard Forth approach)
\
\ Forth blurs the boundary between interpretation and compilation.
\ Understanding STATE, immediate words, and POSTPONE lets you write
\ words that behave differently depending on whether they run at
\ compile time or interpret time.
\
\ This tutorial emphasizes POSTPONE, the high-level Forth standard that
\ abstracts away the distinction between compiling regular vs immediate words.
\ For the low-level vForth minimalist approach, see tutorial/019-compilation.f.
\
\ Core words (no NEEDS):
\   STATE    -- user variable: 0=interpreting, nonzero=compiling
\   [        -- switch to interpret state (immediate)
\   ]        -- switch to compile state
\   IMMEDIATE -- mark the last-defined word as immediate
\   COMPILE,  -- compile the CFA at TOS into the current definition
\   COMPILE   -- compile a literal CFA into the definition (old-style)
\   [COMPILE] -- force-compile an immediate word (old-style)
\
\ POSTPONE requires NEEDS (in inc/postpone.f).
\ ['] requires NEEDS (in inc/['].f).
\
\ Reference: sec.2.12.4
\
\ Load from a clean session (to see both approaches):
\   NEEDS TUTORIAL
\   019 TUTORIAL      \ vForth minimalist version (low-level)
\   020 TUTORIAL      \ Standard Forth version (POSTPONE-based, this file)
\
\ To unload and reload interactively:
\   NEWTASK 020 TUTORIAL
\

MARKER NEWTASK

CR
." --- Tutorial 020-standard: compilation (standard Forth style). " CR
.(     Type NEWTASK to unload.   ) CR

NEEDS POSTPONE
NEEDS [']


\ ===========================================================================
\ 1. STATE -- what mode are we in?
\ ===========================================================================
\
\ STATE ( -- a )  returns the address of the state flag.
\   STATE @   => 0       (interpreting)
\   STATE @   => nonzero (compiling, inside : ... ; )
\
\ The interpreter reads STATE to decide whether to execute or compile
\ each word it encounters.

: .STATE  ( -- )
    STATE @ IF  ." compiling"  ELSE  ." interpreting"  THEN  CR ;

.( Try: .STATE   ) CR               \ => interpreting
.( Try: : FOO  .STATE ;  FOO  ) CR  \ => interpreting (runs at runtime)


\ ===========================================================================
\ 2. [ and ]  --  escape hatch from compilation
\ ===========================================================================
\
\ Inside a colon definition, [ ... ] switches temporarily to interpret
\ mode.  The words between [ and ] are executed immediately at compile
\ time, not compiled.
\
\ Common use: compute a constant at compile time:
\
\   : DAYS-IN-YEAR   [ 7 52 * ] LITERAL ;
\                      ^^^^^^^
\                    executed at compile time; result compiled as literal
\
\   : LIMIT   [ BL 1+ ] LITERAL ;   \ BL+1 = 33 = !

: COMPILE-TIME-DEMO  ( -- n )
    [ 2 3 + ] LITERAL ;     \ 5 is compiled as a literal

.( Try: COMPILE-TIME-DEMO .  ) CR   \ => 5


\ ===========================================================================
\ 3. IMMEDIATE -- words that run at compile time
\ ===========================================================================
\
\ A word marked IMMEDIATE is always executed, even inside : ... ; .
\ Control-flow words (IF ELSE THEN DO LOOP) and [ are all immediate.
\
\ Pattern for a dual-mode word:
\
\   : MY-WORD  ( ... -- ... )
\       STATE @ IF
\           \ compile-time behaviour
\       ELSE
\           \ interpret-time behaviour
\       THEN  ;
\   IMMEDIATE

: ?COMPILING  ( -- )
    STATE @ IF
        ." (inside a definition)"
    ELSE
        ." (at the prompt)"
    THEN  CR ;
IMMEDIATE

.( Try: ?COMPILING                ) CR  \ runs at prompt => at the prompt
.( Try: : TEST-IMMED  ?COMPILING ; ) CR \ runs at compile time


\ ===========================================================================
\ 4. COMPILE,  --  compiling from the stack vs from source
\ ===========================================================================
\
\ COMPILE, ( xt -- )  compiles an xt (taken from the stack) into the current
\ definition. It is the stack-based counterpart to POSTPONE.
\
\ POSTPONE name   -- takes the word name from source, compiles its semantics
\ COMPILE, (xt)   -- takes an xt from the stack, compiles it
\
\ Example: two ways to compile DUP into the current definition:
\
\ Version 1: POSTPONE directly (source-based):
\   : COMPILE-DUP-V1  ( -- )   POSTPONE DUP ;  IMMEDIATE
\
\ Version 2: via stack (using ['] and COMPILE,):
\   : COMPILE-DUP-V2  ( -- )   ['] DUP  COMPILE, ;  IMMEDIATE
\
\ Both are equivalent. Use POSTPONE when you know the word at compile-time.
\ Use COMPILE, when the xt comes from the stack (e.g., computed or passed as parameter).

: COMPILE-DUP-V1  ( -- )   POSTPONE DUP ;  IMMEDIATE

: COMPILE-DUP-V2  ( -- )   ['] DUP  COMPILE, ;  IMMEDIATE

: TRIPLE-V1  ( n -- n n n )   COMPILE-DUP-V1  COMPILE-DUP-V1 ;
: TRIPLE-V2  ( n -- n n n )   COMPILE-DUP-V2  COMPILE-DUP-V2 ;

.( Try: 5 TRIPLE-V1 .S 2DROP . ) CR   \ => 5 5 5
.( Try: 5 TRIPLE-V2 .S 2DROP . ) CR   \ => 5 5 5


\ ===========================================================================
\ 5. POSTPONE  --  the modern way to compile any word
\ ===========================================================================
\
\ POSTPONE name  compiles the compilation-semantics of name, whether or
\ not name is immediate. It works uniformly for any word, eliminating the
\ need to distinguish between immediate and non-immediate words.
\
\ POSTPONE replaces both COMPILE and [COMPILE].
\
\ Example 1: define a synonym for THEN using POSTPONE:
\
\ Pattern: when you use POSTPONE on an immediate word, the word that
\ contains POSTPONE should also be IMMEDIATE. Both execute at compile-time.
\
\   : END-IF  POSTPONE THEN ;  IMMEDIATE
\
\ Now END-IF is an alias for THEN, usable in colon definitions:

: END-IF  POSTPONE THEN ;  IMMEDIATE

: TEST-END-IF  ( -- )
    1 IF  ." yes"  END-IF  CR ;

.( Try: TEST-END-IF  ) CR   \ => yes


\ ===========================================================================
\ 6. Summary: compile-time vs runtime dispatch
\ ===========================================================================
\
\ Technique         When to use
\ -----------------------------------------------
\ [ ... ]           Compute constants at compile time
\ IMMEDIATE         Word runs at compile time (and at prompt)
\ STATE @           Query mode to write dual-behaviour words
\ COMPILE,          Low-level: append xt to current definition
\ POSTPONE          High-level: compile semantics of any word


\ ===========================================================================
\ 7. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ NEEDS TESTING
\ T{  COMPILE-TIME-DEMO  -> 5    }T
\ T{  5 TRIPLE           -> 5 5 5 }T
