\
\ LOCALS.f
\
.( LOCALS )
\
\ Re-entrant VALUE-like local variables.
\
\ Used in the form
\
\       : SUM3   { X Y Z }   X Y + Z + ;
\
\ { is IMMEDIATE and must be the first word of the definition: it declares
\ the local names, in the order in which the caller pushed them, and
\ compiles the code that pops the arguments into them. The names live as
\ VALUE-like words inside the DEFLOCALS vocabulary, invisible from
\ outside the definition that declared them.
\
\ An optional  --  marks off a second group of names: OUTPUT locals.
\ They are not bound from the stack -- created at 0 on every entry -- and
\ the body does not push them either: every exit path (the final ; and
\ any early EXIT) pushes their current value automatically, in the order
\ declared, before restoring the caller's own locals underneath them.
\
\       : SUM-TO  { N -- ACC }
\           N 0> IF  N 0 DO  ACC I 1+ + TO ACC  LOOP  THEN ;
\
\ The older two-part form is still supported, and is what { is built on:
\
\       3 LOCALS-FOR SUM3   X Y Z
\       : SUM3   LOCALS   X Y + Z + ;
\
\ LOCALS-FOR runs in interpretation state, BEFORE the colon definition,
\ and takes the count of locals, the name of the definition that follows,
\ and then that many names. LOCALS, IMMEDIATE, then makes them visible
\ inside the body and binds them. Everything { does in one place. Prefer
\ { ... } : it cannot get the count wrong, and nothing has to stay
\ adjacent to anything else.
\
\ X local pushes its value; write it with TO :
\
\       12 TO X
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
\ TRAMPOLINE. { (like LOCALS) does not compile the body into the
\ definition the user opened. It ends that definition after two cells --
\ a slot and EXIT -- which leaves it smudged, exactly as plain : left it,
\ and then builds by hand a second, nameless colon-header (just the
\ 3-byte "call Enter_Ptr" prologue that : itself would write) and patches
\ its address into the slot. So
\
\       : FOO   { X }  ... ;
\
\ compiles two threads sharing one dictionary entry: FOO's own, which is
\ just  ( call body ) EXIT , and the nameless body right after it that
\ binds the locals and runs the code. Between the two, HERE is outside
\ any pending definition, which is the one state in which words can be
\ CREATEd -- this is what lets { ... } declare the locals in place, where
\ LOCALS-FOR had to do it before the colon. The nameless body gets no
\ dictionary header at all -- unlike :NONAME (inc/_noname.f), the first
\ design tried here, dropped because it hooks a phantom entry into the
\ CURRENT vocabulary chain for every definition. LATEST is therefore
\ still FOO throughout the body, so RECURSE compiles a call back to FOO,
\ not directly into the body: correct, but the trampoline's entry cost is
\ paid again on every recursion level, not only once. The user's closing
\ ; still belongs to FOO: it compiles the body's final EXIT and SMUDGEs
\ FOO, revealing it in the dictionary.
\
\ Cost per activation: one return-stack cell for the chain address, plus
\ two per local (old value + its cell address), i.e. 4+4n bytes on top of
\ the caller's address, plus one more cell for the trampoline's own return
\ address, paid on every recursion level (RECURSE re-enters through FOO,
\ see above). The return stack is 160 bytes shared with the TIB, so
\ recursion stays shallow -- measured on the emulator, a word with one
\ local survives 15 levels and dies at 20; with eight locals, about 3.
\ Overflowing it overwrites the input buffer, silently.
\
\ ABORT and THROW bypass the chain, so an aborted word leaves its locals
\ holding inner values. This is harmless: every entry rebinds all of them
\ from the stack before the body runs.
\
\ Every local name and cell is permanent: a scope costs n cells of
\ dictionary plus one heap header per name, none of it reclaimable. The
\ restore chain adds n+1 more dictionary cells per scope (12.4/12.7 in
\ the plan doc), since it is no longer a single table shared by every
\ scope. An output local's chain step, (LOC-EPOP), costs three more
\ primitives at exit than a plain (LOC-POP).
\
\ All the local names must be on the SAME source line as the { that opens
\ them (or as LOCALS-FOR, in the older form).
\
\ Design notes and the reasoning behind this shape: prompts/LOCALS-PLAN.md
\
\ Errors are reported with ?ERROR, using four messages reserved in the
\ standard error blocks (Screen #7, lines 9-12) -- see  9 LOAD  for the
\ full list:
\
\       #57  LOCALS: bad count.
\       #58  LOCALS: no scope declared.
\       #59  LOCALS: scope not adjacent.
\       #60  LOCALS: misplaced { or }.  Also raised for a duplicate --.
\

FORTH DEFINITIONS   \ Force this library as part of Forth definitions

MARKER NO-LOCALS

NEEDS TO

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
VARIABLE #IN-LOCALS     0 #IN-LOCALS !  \ how many of #LOCALS come off the
                                         \ stack; the rest are outputs, after --
VARIABLE SCOPE-LINK     0 SCOPE-LINK !  \ LATEST when the scope was opened
VARIABLE OLD-CURRENT    0 OLD-CURRENT !
VARIABLE LOC-SLOT       0 LOC-SLOT !     \ cell to patch with the body's xt
VARIABLE LOC-CHAIN-START  0 LOC-CHAIN-START !  \ this scope's own restore chain

CREATE LOCAL-PFAS   MAXLOCALS CELLS ALLOT

\ locals are recorded in declaration order; the binding code has to be
\ emitted in reverse, because the last one declared is on top at run time.

: LOC-PFA   ( i -- a )  CELLS LOCAL-PFAS + ;

\ Maps a loop count (0..#LOCALS-1, ascending -- what a plain DO gives)
\ to the declared position it must bind at run time (#LOCALS-1..0,
\ descending): binding has to run in the exact reverse of the chain's
\ declared-position order (12.3), regardless of which positions are
\ inputs and which are outputs.

: LOC-POS   ( i -- position )   #LOCALS @ 1- SWAP - ;

\ ----------------------------------------------------------------------
\ Run-time support: shallow binding
\
\ (LOC-BIND) binds one local to an argument, remembering on the return
\ stack what was in the cell and which cell it was. (LOC-BIND0) does the
\ same for an output local (declared after -- in the { } form): it is
\ not on the caller's stack at all, so it is bound to a literal 0
\ instead. Both words juggle their own return address, which is on top
\ when they start.
\
\ (LOC-POP) undoes one binding, discarding the old contents. (LOC-EPOP)
\ undoes one binding too, but first pushes what the cell held -- the
\ value an output local delivers to the caller. Neither is ever called
\ from a definition directly: each scope builds its own chain of them
\ (see (LOC-CLOSE)), reached when the EXIT of the word being unwound
\ jumps into it.

: (LOC-BIND)  ( x a -- )            \ R: -- old a
    R> SWAP DUP >R  DUP @ >R  ROT SWAP !  >R
;

: (LOC-BIND0)  ( a -- )             \ R: -- old a
    R> SWAP DUP >R  DUP @ >R  0 SWAP !  >R
;

: (LOC-POP)   ( -- )                \ R: old a --
    R> R> R> !  >R
;

: (LOC-EPOP)  ( -- x )              \ R: old a --
    R> R> R>  DUP @  ROT ROT !  SWAP >R
;

\ Each scope builds its OWN restore chain, instead of sharing one fixed
\ table: a single shared table cannot represent an arbitrary mix of POP
\ and EPOP steps at different positions for different scopes.
\ (LOC-STEP) decides which one a given declared position needs.

: (LOC-STEP)  ( i -- xt )
    #IN-LOCALS @ <  IF  ['] (LOC-POP)  ELSE  ['] (LOC-EPOP)  THEN
;

\ ----------------------------------------------------------------------
\ Compile-time support: the trampoline
\
\ (LOC-OPEN) ends the definition being compiled after a slot and an EXIT.
\ It does NOT reveal it: it stays smudged, the way plain : left it, until
\ the user's own closing ; does that later. HERE is now outside any
\ pending definition, so CREATE works again -- see the header note.
\
\ (LOC-CLOSE) builds the nameless body's header by hand (just the 3-byte
\ "call Enter_Ptr" prologue -- see the header note on why not :NONAME)
\ and patches its address into the slot left by (LOC-OPEN). !CSP re-arms
\ the ?CSP check so that the user's own ; -- which closes the BODY's
\ thread, not the outer word's -- passes, compiles the body's final EXIT,
\ and SMUDGEs the outer word into visibility.

: (LOC-OPEN)  ( -- )
    HERE LOC-SLOT !
    COMPILE NOOP                    \ placeholder: harmless if never patched
    COMPILE EXIT
    ;

\ (LOC-CLOSE) first lays down this scope's own restore chain -- one step
\ per local, in declaration order, POP or EPOP as (LOC-STEP) decides,
\ followed by EXIT -- then makes the local names visible and compiles,
\ at the head of the body, the code that binds them: last declared
\ first, that is the one on top at run time. The chain address goes
\ last, so that it is what the EXIT of the body finds on top of the
\ return stack.

: (LOC-CLOSE) ( -- )
    HERE  LOC-CHAIN-START !          \ this scope's restore chain starts here
    #LOCALS @ 0 DO  I (LOC-STEP) ,  LOOP  \ #LOCALS is always >=1 here
    ['] EXIT ,

    HERE                            \ xt (the nameless body's CFA)

    $CD C,                          \ compile CALL op-code
    [ ' ' >BODY CELL- @ ]
    LITERAL ,                       \ Enter_Ptr address to jump to

    LOC-SLOT @ !                    \ the outer word calls the body
    !CSP

    LOC-VOC CONTEXT !               \ local names visible in the body

    \ bind every local, one DO across both kinds: last declared first,
    \ the one on top at run time for the stack-supplied ones. This keeps
    \ the chronological bind order the exact reverse of the chain's
    \ declared-position order (12.3) regardless of the -- split, which is
    \ what makes chain step j restore/push the local at position j.

    #LOCALS @ 0 DO
        I LOC-POS                       ( position )
        COMPILE LIT  DUP LOC-PFA @ ,
        DUP #IN-LOCALS @ <  IF  COMPILE (LOC-BIND)  ELSE  COMPILE (LOC-BIND0)  THEN
        DROP
    LOOP

    COMPILE LIT
    LOC-CHAIN-START @ ,
    COMPILE >R

    0 #LOCALS !                     \ consume the scope
;

\ ----------------------------------------------------------------------
\ Declaring one local -- used by both forms
\
\ CURRENT must be restored before returning: if it were left on
\ DEFLOCALS, the following  :  would create the definition itself inside
\ DEFLOCALS, and it would vanish at the next scope. CONTEXT is restored
\ with it -- for LOCALS-FOR that is mere tidiness, since the following  :
\ overwrites it anyway with  CURRENT @ CONTEXT !  , but { runs after that
\ point and an error in mid-declaration must not leave the locals in the
\ search order. Nothing else will do it for us: ?ERROR ends in QUIT, which
\ resets STATE and the return stack but not CONTEXT/CURRENT -- it is ABORT,
\ not ERROR, that does FORTH DEFINITIONS.

: (LOC-MAKE)  ( -- ccc )            \ create one local, parsing its name
    CURRENT @ OLD-CURRENT !
    DEFLOCALS DEFINITIONS
    0 CONSTANT                      \ the local: a VALUE-like cell
    LATEST PFA  #LOCALS @ LOC-PFA !
    OLD-CURRENT @ CURRENT !
    CURRENT @ CONTEXT !
    1 #LOCALS +!
;

\ ----------------------------------------------------------------------
\ LOCALS-FOR  -- interpretation state, before the colon definition

: LOCALS-FOR ( n -- ccc ccc1 ... cccn )
    DUP 0=  OVER MAXLOCALS >  OR    #57 ?ERROR  \ bad count

    BL WORD DROP                    \ consume the definition name
    CURRENT @ @ SCOPE-LINK !        \ remember what LATEST was
    LOC-EMPTY LOC-VOC !             \ empty the locals vocabulary
    0 #LOCALS !
    0 DO  (LOC-MAKE)  LOOP
    #LOCALS @ #IN-LOCALS !          \ all of them come off the stack
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
    #LOCALS @ 0=                    #58 ?ERROR  \ no scope declared
    LATEST PFA LFA @ SCOPE-LINK @ - #59 ?ERROR  \ scope not adjacent

    (LOC-OPEN)                      \ close the outer word on a slot
    (LOC-CLOSE)                     \ trampoline: build body, bind, divert EXIT
;
IMMEDIATE

\ ----------------------------------------------------------------------
\ {  ccc1 ... cccn [ -- ccccn+1 ... ] }   -- IMMEDIATE, first in the body
\
\       : SUM3    { X Y Z }        X Y + Z + ;
\       : SUM-TO  { N -- ACC }     N 0> IF  N 0 DO  ACC I 1+ + TO ACC  LOOP  THEN ;
\
\ Declaration and use in one place: no count to keep in step, no separate
\ LOCALS-FOR to keep adjacent to the definition. It is the trampoline that
\ makes this possible -- (LOC-OPEN) closes the outer word, and only then
\ is HERE free for the CREATE that each local needs.
\
\ Each name is parsed twice: >IN is rewound after the test against } (and
\ against --) so that CONSTANT parses the very same name. All the names,
\ the optional -- , and the } , must be on the SAME source line as the { .
\
\ On a malformed declaration the outer word survives as a do-nothing
\ NOOP EXIT, but stays smudged (KNOWN ISSUE: since (LOC-OPEN) does not
\ reveal it and QUIT never reaches the closing ; that would, the stub is
\ left in the dictionary but unreachable by name -- see prompts/LOCALS-PLAN.md 14.5).

: }  ( -- )
    #60 ERROR                       \ misplaced: } without {
;

: ?}  ( a -- a flag )               \ true if the counted string at a is "}"
    DUP C@ 1 =
    OVER 1+ C@ [CHAR] } = AND
;

: ?--  ( a -- a flag )              \ true if the counted string at a is "--"
    DUP C@ 2 =
    OVER 1+ C@ [CHAR] - = AND
    OVER 2 + C@ [CHAR] - = AND
;

: {  ( -- )
    ?COMP
    (LOC-OPEN)                      \ HERE is free from here on
    LOC-EMPTY LOC-VOC !             \ empty the locals vocabulary
    0 #LOCALS !
    -1 #IN-LOCALS !                 \ sentinel: -- not seen yet
    BEGIN
        >IN @  BL WORD              ( in a )
        DUP C@ 0=  OVER 1+ C@ 0= OR #60 ?ERROR  \ misplaced: missing }
        ?} 0=                       ( in a flag )   \ true while not }
    WHILE
        ?--                         ( in a flag )
        IF
            #IN-LOCALS @ 0< 0=      #60 ?ERROR  \ misplaced: duplicate --
            #LOCALS @ #IN-LOCALS !
            2DROP
        ELSE
            DROP  >IN !              \ rewind: CONSTANT re-parses the name
            #LOCALS @ MAXLOCALS =   #57 ?ERROR  \ bad count -- before the write
            (LOC-MAKE)
        THEN
    REPEAT
    2DROP                           ( in a )
    #LOCALS @ 0=                    #57 ?ERROR  \ bad count
    #IN-LOCALS @ 0<  IF  #LOCALS @ #IN-LOCALS !  THEN

    (LOC-CLOSE)                     \ trampoline: build body, bind, divert EXIT
;
IMMEDIATE

FORTH DEFINITIONS
