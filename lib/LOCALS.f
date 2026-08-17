\
\ LOCALS.f
\
.( LOCALS )
\
\ Re-entrant VALUE-like local variables.
\
\ Used in the form
\
\       3 LOCALS-FOR SUM3   A B C
\       : SUM3   LOCALS   A B + C + ;
\
\ LOCALS-FOR runs in interpretation state, BEFORE the colon definition.
\ It takes the count of locals, the name of the definition that follows,
\ and then that many local names. It creates the locals as VALUE-like
\ words inside the DEFLOCALS vocabulary, invisible from outside.
\
\ LOCALS is IMMEDIATE and takes no arguments. Inside the definition it
\ makes the local names visible again and compiles the code that pops the
\ caller arguments into them. It must run before the body touches the
\ stack, so in practice it is the first word of the definition.
\
\ A local pushes its value; write it with TO :
\
\       12 TO A
\
\ DELIBERATE DEVIATION from the Forth-2012 locals wordset: a local is a
\ permanent cell, not a frame slot. Re-entrancy is obtained by SHALLOW
\ BINDING: on entry each cell's previous content is pushed on the return
\ stack, and every exit path restores it. Two live activations of the
\ same word therefore see their own values, and RECURSE works.
\
\ The restore happens without redefining EXIT, ; or : . LOCALS pushes on
\ the return stack, above the caller's address, the address of a chain of
\ (LOC-POP) cells: the EXIT that ends the definition -- any EXIT, including
\ an early one inside IF -- lands there instead of returning, the chain
\ restores the cells, and its own final EXIT returns to the caller.
\
\ Cost per activation: one return-stack cell for the chain address, plus
\ two per local (old value + its cell address), i.e. 4+4n bytes on top of
\ the caller's address. The return stack is 160 bytes shared with the TIB,
\ so recursion stays shallow -- measured on the emulator, a word with one
\ local survives 15 levels and dies at 20; with eight locals, about 3.
\ Overflowing it overwrites the input buffer, silently.
\
\ ABORT and THROW bypass the chain, so an aborted word leaves its locals
\ holding inner values. This is harmless: every entry rebinds all of them
\ from the stack before the body runs.
\
\ Every local name and cell is permanent: a scope costs n cells of
\ dictionary plus one heap header per name, none of it reclaimable.
\
\ All the local names must be on the SAME source line as LOCALS-FOR.
\
\ Design notes and the reasoning behind this shape: prompts/LOCALS-PLAN.md
\
MARKER NO-LOCALS

NEEDS TO
NEEDS ABORT"

  8 CONSTANT MAXLOCALS

\ The locals live in their own vocabulary so they are invisible outside
\ the definition that declared them. It is cleared by every
\ LOCALS-FOR, so only one scope is alive at a time.

VOCABULARY DEFLOCALS

DEFLOCALS
CONTEXT @   CONSTANT LOC-VOC        \ address of DEFLOCALS' LATEST cell
FORTH
LOC-VOC @   CONSTANT LOC-EMPTY      \ value of that cell when empty

VARIABLE #LOCALS        0 #LOCALS !     \ locals in the pending scope
VARIABLE SCOPE-LINK     0 SCOPE-LINK !  \ LATEST when the scope was opened
VARIABLE OLD-CURRENT    0 OLD-CURRENT !

CREATE LOCAL-PFAS   MAXLOCALS CELLS ALLOT

\ locals are recorded in declaration order; the binding code has to be
\ emitted in reverse, because the last one declared is on top at run time.

: LOC-PFA   ( i -- a )  CELLS LOCAL-PFAS + ;

\ ----------------------------------------------------------------------
\ Run-time support: shallow binding
\
\ (LOC-BIND) binds one local to an argument, remembering on the return
\ stack what was in the cell and which cell it was. Both words juggle
\ their own return address, which is on top when they start.
\
\ (LOC-POP) undoes one binding. It is never called from a definition:
\ it is reached through the (LOC-EXIT) chain below, when the EXIT of the
\ word being unwound jumps into it.

: (LOC-BIND)  ( x a -- )            \ R: -- old a
    R> SWAP DUP >R  DUP @ >R  ROT SWAP !  >R
;

: (LOC-POP)   ( -- )                \ R: old a --
    R> R> R> !  >R
;

\ MAXLOCALS pop cells followed by EXIT. A definition with n locals is made
\ to return into this chain n cells before its end, so exactly n bindings
\ are undone and the final EXIT returns to the caller.
\ Same idiom as the hand-built thread in inc/exec_.f  ( HERE ' EXIT , ).

: (LOC-CHAIN) ( xt n -- )   0 DO  DUP ,  LOOP  DROP ;

CREATE (LOC-EXIT)
    ' (LOC-POP) MAXLOCALS (LOC-CHAIN)
    ' EXIT ,

: LOC-ENTRY  ( n -- a )             \ where to enter the chain for n locals
    MAXLOCALS SWAP - CELLS  (LOC-EXIT) +
;

\ ----------------------------------------------------------------------
\ LOCALS-FOR  -- interpretation state, before the colon definition
\
\ CURRENT must be restored before returning: if it were left on
\ DEFLOCALS, the following  :  would create the definition itself inside
\ DEFLOCALS, and it would vanish at the next LOCALS-FOR.
\ CONTEXT is restored too, but only for tidiness -- the following  :
\ overwrites it anyway with  CURRENT @ CONTEXT !

: LOCALS-FOR ( n -- ccc ccc1 ... cccn )
    DUP 0=  OVER MAXLOCALS >  OR    ABORT" LOCALS: bad count"

    BL WORD DROP                    \ consume the definition name
    CURRENT @ @ SCOPE-LINK !        \ remember what LATEST was
    LOC-EMPTY LOC-VOC !             \ empty the locals vocabulary
    0 #LOCALS !

    CURRENT @ OLD-CURRENT !
    DEFLOCALS DEFINITIONS
    0 DO
        0 CONSTANT                  \ the local: a VALUE-like cell
        LATEST PFA  #LOCALS @ LOC-PFA !
        1 #LOCALS +!
    LOOP
    OLD-CURRENT @ CURRENT !
    CURRENT @ CONTEXT !
;

\ ----------------------------------------------------------------------
\ LOCALS  -- IMMEDIATE, inside the colon definition
\
\ The two guards catch the case that would otherwise be silent: a second
\ definition saying LOCALS without its own LOCALS-FOR would bind the SAME
\ cells and share storage with the first one.
\ The scope is consumed here, so it cannot be used twice.

: LOCALS ( -- )
    ?COMP
    #LOCALS @ 0=                    ABORT" LOCALS: no scope declared"
    LATEST PFA LFA @ SCOPE-LINK @ - ABORT" LOCALS: scope not adjacent"

    LOC-VOC CONTEXT !               \ local names visible in the body

    \ bind the arguments, last declared first: it is the one on top.

    #LOCALS @ 0 DO
        COMPILE LIT
        #LOCALS @ 1- I - LOC-PFA @ ,
        COMPILE (LOC-BIND)
    LOOP

    \ divert the return: this must be the LAST thing pushed at run time,
    \ so that it is what the EXIT of the definition finds on top.

    COMPILE LIT
    #LOCALS @ LOC-ENTRY ,
    COMPILE >R

    0 #LOCALS !                     \ consume the scope
;
IMMEDIATE
