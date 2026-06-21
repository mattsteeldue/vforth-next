\
\ 019-compilation.f
\ Compilation internals: STATE, [ ], IMMEDIATE, [COMPILE], ,
\
\ Forth blurs the boundary between interpretation and compilation.
\ Understanding STATE, immediate words, and [COMPILE] lets you write
\ words that behave differently depending on whether they run at
\ compile time or interpret time.
\
\ vForth philosophy: trim the fat. Memory is precious. POSTPONE is a
\ convenience that insulates the programmer from understanding their own
\ system. In vForth we learn the machine instead: STATE tells us the mode,
\ [COMPILE] forces compilation of immediates, and , (comma) is the
\ fundamental commaer that appends a cell to the dictionary.
\
\ Core words (no NEEDS):
\   STATE      -- user variable: 0=interpreting, nonzero=compiling
\   [          -- switch to interpret state (immediate)
\   ]          -- switch to compile state
\   IMMEDIATE  -- mark the last-defined word as immediate
\   ,          -- compile a cell into the current definition
\   [COMPILE]  -- force-compile an immediate word (old-style)
\
\ Alternative: tutorial/020-standard.f shows the standard Forth approach
\ using POSTPONE and COMPILE, for those who prefer higher-level abstractions.
\
\ Starting FORTH (Brodie): Ch.11  |  vForth screens 898-905
\ Reference: sec.2.12.4
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   019 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 019 TUTORIAL
\

MARKER NEWTASK

CR
." --- Tutorial 019: compilation (vForth minimalist). " CR
.(     Type NEWTASK to unload.   ) CR


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
CR
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

.( Try: ?COMPILING                 ) CR \ runs at prompt => at the prompt
.( Try: : TEST-IMMED  ?COMPILING ; ) CR \ runs at compile time


\ ===========================================================================
\ 4. COMPILE -- compile a word into the current definition
\ ===========================================================================
\
\ COMPILE word  compiles the word name into the current definition.
\ At compile-time, COMPILE looks up the word, gets its xt, and appends it
\ to the dictionary. Under the hood, it uses , (comma).
\
\ Pattern: definitions that compile other words are almost always marked
\ IMMEDIATE, so they execute at compile-time rather than being compiled
\ themselves.
\
\ Example: a word that compiles DUP into the current definition:
\
\   : COMPILE-DUP  ( -- )   COMPILE DUP ;  IMMEDIATE
\
\ Then:   : TRIPLE  ( n -- n n n )  COMPILE-DUP  COMPILE-DUP ;
\ is equivalent to:   : TRIPLE  DUP DUP ;

: COMPILE-DUP  ( -- )   COMPILE DUP ;  IMMEDIATE

: TRIPLE  ( n -- n n n )   COMPILE-DUP  COMPILE-DUP ;

.( Try: 5 TRIPLE .S 2DROP .  ) CR   \ => 5 5 5


\ ===========================================================================
\ 5. [COMPILE]  --  forcing compilation of immediate words
\ ===========================================================================
\
\ [COMPILE] name  forces the compilation of an immediate word into the
\ current definition. Normally an immediate word executes; [COMPILE]
\ overrides that and compiles its xt into the dictionary instead.
\
\ Use case: inside an IMMEDIATE word, when you want to compile another
\ IMMEDIATE word (like LITERAL) rather than execute it.
\
\ Example: [UDG] is an IMMEDIATE word that reads a character at
\ compile-time, converts it to a UDG (User-Defined Graphics) code,
\ and compiles the result as a literal into the definition.
\
\ Helper: convert character to UDG code
: UDG+ ( c -- c' )
    UPPER 79 + ;    \ convert letter A-Z to UDG code 165-190
\
\ Compile a UDG character: read char at compile-time,
\ convert to UDG code, compile as literal.
: [UDG]  ( -- )
    CHAR UDG+ [COMPILE] LITERAL ;
    IMMEDIATE
\
\ Usage at compile-time:
\   : SHOW-A  [UDG] A  EMITC ;
\
\ This reads 'A', converts it to UDG code (~165), and compiles 165 as
\ a literal. When SHOW-A runs, it pushes 165 and emits it as a UDG char.
\
\ The key: [COMPILE] LITERAL forces LITERAL to compile (not execute),
\ because LITERAL is itself immediate and would normally run.


\ ===========================================================================
\ 6. Summary: the vForth philosophy
\ ===========================================================================
\
\ In vForth, we learn the machine, not hide from it.
\
\ Technique         Meaning
\ -----------------------------------------------
\ [ ... ]           Execute at compile time; don't compile
\ IMMEDIATE         Word always executes (compile-time or prompt)
\ STATE @           Check current mode: 0=interpret, nonzero=compile
\ ,                 Append a cell to the dictionary (the fundamental op)
\ [COMPILE]         Force-compile an immediate word (compile its xt)
\
\ Higher-level tools like POSTPONE (in 019-standard.f) automate much of
\ this, but understanding the low-level primitives makes you a better
\ Forth programmer. You control the machine; the machine does not
\ control you.

\ ===========================================================================
\ 7. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ NEEDS TESTING
\ T{  COMPILE-TIME-DEMO  -> 5    }T
\ T{  5 TRIPLE           -> 5 5 5 }T
