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
\ outside the definition that declared them. A second, same-named word
\ per local lives in DEFBINDS -- see BINDER WORDS below -- and is never
\ looked up by name; it only exists to be compiled and to make SEE
\ readable.
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
\ BRANCH SCAVALCO. { (like LOCALS) does not close the definition the user
\ opened -- FOO's own : stays open throughout. It compiles an
\ unconditional BRANCH with an offset left unresolved (the same forward
\ reference IF/THEN use), then lets the local names get CREATEd right
\ after it, splicing real dictionary headers into the middle of FOO's own
\ thread -- exactly what CREATE-inside-a-colon-definition normally
\ corrupts (see the design doc). The BRANCH exists to jump over that
\ splice, and over this scope's own restore chain compiled next to it, so
\ that calling FOO lands directly on the binding prologue instead of
\ falling into either. So
\
\       : FOO   { X }  ... ;
\
\ is ONE dictionary entry, ONE thread: BRANCH, offset, X's own CONSTANT
\ header, the restore chain, then -- where the BRANCH lands -- the
\ prologue that binds X, then the user's own code, then EXIT. LATEST is
\ FOO throughout, so RECURSE compiles a call straight back into FOO: it
\ re-enters through the same BRANCH (one jump, no extra return-stack
\ push) and rebinds a fresh set of arguments. The user's closing ; still
\ belongs to FOO, unchanged: COMPILE exit, SMUDGE, back to interpreting.
\
\ SEE handles the splice: lib/see.f recognises a BRANCH as a definition's
\ first cell as this pattern's own signature and jumps straight to the
\ binding prologue instead of decoding the splice cell by cell. What it
\ shows there is one word per local -- see BINDER WORDS below -- rather
\ than the raw LIT+xt pair the prologue used to compile.
\
\ BINDER WORDS. Each local also gets a second word, same name, in a
\ separate vocabulary DEFBINDS: a DOES>-word that already knows its own
\ local's storage cell and, called, does what "LIT a (LOC-BIND)" used to
\ do -- one thread cell in the prologue instead of three, and a name SEE
\ can print instead of two raw primitives. See (LOC-MAKE) below.
\
\ Cost per activation: one return-stack cell for the chain address, plus
\ two per local (old value + its cell address), i.e. 4+4n bytes on top of
\ the caller's address -- no extra trampoline entry cost per recursion
\ level, unlike the design this replaced. The return stack is 160 bytes
\ shared with the TIB, so recursion stays shallow -- the design doc's
\ figures were taken under the trampoline and want re-measuring here.
\ Overflowing it overwrites the input buffer, silently.
\
\ ABORT and THROW bypass the chain, so an aborted word leaves its locals
\ holding inner values. This is harmless: every entry rebinds all of them
\ from the stack before the body runs.
\
\ Every local name and cell is permanent: a scope costs n cells of
\ dictionary plus one heap header per name, none of it reclaimable -- and
\ now TWICE that, since the binder word (above) is a second full header
\ (DEFBINDS) and a second few dictionary cells (CREATE + DOES> runtime +
\ one data cell) for every local, paid to shrink the PROLOGUE's own
\ thread from three cells per local to one. The restore chain adds n+1
\ more dictionary cells per scope (12.4/12.7 in the plan doc), since it
\ is no longer a single table shared by every scope. An output local's
\ chain step, (LOC-EPOP), costs three more primitives at exit than a
\ plain (LOC-POP).
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

\ Per-local binder words (see (LOC-MAKE) below) live in a SECOND
\ vocabulary, not in DEFLOCALS alongside the reader they pair with: a
\ binder shares its local's own name, and two same-named headers in ONE
\ vocabulary would leave FIND -- so TO, so any body reference -- to pick
\ whichever is linked more recently, silently. A separate vocabulary
\ makes that collision impossible instead of relying on creation order.

VOCABULARY DEFBINDS

DEFBINDS
CONTEXT @   CONSTANT BND-VOC        \ address of DEFBINDS' LATEST cell
FORTH
BND-VOC @   CONSTANT BND-EMPTY      \ value of that cell when empty

VARIABLE #LOCALS        0 #LOCALS !     \ locals in the pending scope
VARIABLE #IN-LOCALS     0 #IN-LOCALS !  \ how many of #LOCALS come off the
                                        \ stack; the rest are outputs, after --
VARIABLE SCOPE-LINK     0 SCOPE-LINK !  \ LATEST when the scope was opened
VARIABLE OLD-CURRENT    0 OLD-CURRENT !
VARIABLE LOC-SLOT       0 LOC-SLOT !    \ address of BRANCH's unresolved offset
VARIABLE LOC-CHAIN-START  0 LOC-CHAIN-START !  \ this scope's own restore chain

\ Each local's binder word (see below) is recorded by CFA, in declaration
\ order; the binding preamble has to compile them in reverse, because the
\ last one declared is on top at run time.

CREATE LOCAL-BIND-XTS   MAXLOCALS CELLS ALLOT

: LOC-BIND-XT   ( i -- a )  CELLS LOCAL-BIND-XTS + ;

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

: (LOC-POP)   ( -- )                \ R: old a --
    R> R> R> !  >R
;

: (LOC-EPOP)  ( -- x )              \ R: old a --
    R> R> R>  DUP @  ROT ROT !  SWAP >R
;

\ ----------------------------------------------------------------------
\ Per-local binder words -- collapse "LIT a (LOC-BIND[0])" into one call
\
\ (LOC-MAKE) below creates, for every local, a SECOND word with the SAME
\ name as the local's own CONSTANT reader, but in DEFBINDS instead of
\ DEFLOCALS: a DOES>-word that already knows its own local's storage
\ address and, executed, does exactly what the three-cell sequence
\ "LIT a (LOC-BIND)" (or (LOC-BIND0) for an output local) used to do --
\ one thread cell instead of three. (LOC-BINDER-IN) and (LOC-BINDER-OUT)
\ are the two makers; which one runs is decided once, at creation time,
\ in (LOC-MAKE). (LOC-CLOSE) then compiles a direct call to the binder
\ instead of the old LIT+xt pair -- and because the binder carries the
\ local's own name, SEE shows that name in the binding preamble instead
\ of "LIT n (LOC-BIND)".

\ THE RETURN-STACK LEVEL. A binder is reached from FOO's thread through
\ its own CFA, which is a  CALL  into the maker's thread, where DOES> put
\ a second  CALL Enter_Ptr : that Enter_Ptr pushes FOO's IP on the return
\ stack and nothing else, so the DOES> body starts with FOO's own return
\ address on top -- exactly what a directly compiled (LOC-BIND) would see.
\ Calling (LOC-BIND) FROM the body would add one more level, and the R>
\ inside it would steal the body's return address instead of FOO's (the
\ bug of plan section 18.4). So the binding code is INLINED here, in the
\ body itself, rather than called: no extra level, nothing to compensate.
\ It is (LOC-BIND) / (LOC-BIND0) verbatim, minus their own call.

: (LOC-BINDER-IN)   ( a -- )   CREATE ,
    DOES>  @   R> SWAP DUP >R  DUP @ >R  ROT SWAP !  >R ;

: (LOC-BINDER-OUT)  ( a -- )   CREATE ,
    DOES>  @   R> SWAP DUP >R  DUP @ >R  0 SWAP !  >R ;

\ Each scope builds its OWN restore chain, instead of sharing one fixed
\ table: a single shared table cannot represent an arbitrary mix of POP
\ and EPOP steps at different positions for different scopes.
\ (LOC-STEP) decides which one a given declared position needs.

: (LOC-STEP)  ( i -- xt )
    #IN-LOCALS @ <  IF  ['] (LOC-POP)  ELSE  ['] (LOC-EPOP)  THEN
;

\ ----------------------------------------------------------------------
\ Compile-time support: BRANCH scavalco (v.6)
\
\ (LOC-OPEN) does NOT close the definition being compiled: FOO's own :
\ stays open the whole time. It only compiles an unconditional BRANCH
\ with an unresolved offset -- the same forward-reference idiom IF uses
\ (COMPILE 0branch HERE 0 , / THEN's HERE OVER - SWAP !), just always
\ taken. LOC-SLOT remembers the offset cell's address.
\
\ HERE is then used exactly as CREATE inside a colon-definition would
\ normally corrupt it (2.1): the local CONSTANTs get created right after
\ the branch, splicing real dictionary headers into the middle of FOO's
\ own thread. The BRANCH exists to jump over that splice at run time,
\ landing on the binding prologue that (LOC-CLOSE) compiles below --
\ never on the splice itself, and never on the restore chain (see next).
\
\ (LOC-CLOSE) runs after the local names are already created (the { and
\ LOCALS-FOR loops call (LOC-MAKE) before this). It lays down this
\ scope's own restore chain right where HERE now is -- one step per
\ local, POP or EPOP as (LOC-STEP) decides, followed by EXIT. The chain
\ is never reached by falling into it: only later, sideways, when the
\ body's own EXIT lands on the address the binding prologue below pushes
\ with >R. Landing there straight through, at FOO's entry, would run
\ (LOC-POP)/(LOC-EPOP) against a return stack nothing has bound yet --
\ which is exactly why the BRANCH must clear the chain too, not just the
\ local headers, and why its offset is patched here, before the
\ prologue, rather than after it (the natural place to end (LOC-CLOSE)
\ at, but the wrong address to land on).
\
\ ] re-affirms STATE as compiling before returning: nothing here should
\ have changed it (CREATE/CONSTANT do not touch STATE), but FOO's own :
\ is still open and the user's own upcoming words must still be compiled,
\ not executed -- so this is asserted, not assumed. FOO's own ; -- typed
\ by the user right after the body -- closes it normally: COMPILE exit,
\ SMUDGE, back to interpreting. No !CSP re-arm is needed either: unlike
\ the previous (trampoline) design, there is no second, nested
\ compilation to re-arm the check against -- the CSP that : saved at the
\ very start is still the right one for that ; to check.
\
\ FOO's thread contains the local headers and the restore chain in the
\ middle of what SEE otherwise expects to be straight code. lib/see.f
\ handles this: it recognises the leading BRANCH as this pattern's own
\ signature and jumps straight past the splice to the binding prologue
\ instead of decoding it cell by cell -- see prompts/LOCALS-PLAN.md
\ section 17.

: (LOC-OPEN)  ( -- )
    COMPILE BRANCH
    HERE  0 ,                       \ unresolved offset, patched below
    LOC-SLOT !
    ;

: (LOC-CLOSE) ( -- )
    HERE  LOC-CHAIN-START !         \ this scope's restore chain starts here
    #LOCALS @ 0 DO  I (LOC-STEP) ,  LOOP  \ #LOCALS is always >=1 here
    ['] EXIT ,

    \ KNOWN BEHAVIOUR, not a bug: CONTEXT stays on DEFLOCALS (emptied) after
    \ the closing ; -- nothing restores it until the next : (which resets
    \ CONTEXT from CURRENT, see : itself) or an explicit FORTH. Harmless:
    \ 2FIND (src/F18e.f) tries CONTEXT, then CURRENT, then FORTH outright,
    \ and CURRENT is already correct -- restored by (LOC-MAKE) below on
    \ every local. So every word typed right after ; is still found, via
    \ 2FIND's second attempt. Fixing this for real would mean redefining ;
    \ (save/call original, then OUTER-VOC @ CONTEXT !) -- the FLOATING/
    \ NUMBER pattern -- which would cost every ; in the system a check and
    \ would break the "LOCALS patches nothing" guarantee in lib/CLAUDE.md.
    \ See prompts/LOCALS-PLAN.md section 21.

    LOC-VOC CONTEXT !               \ local names visible in the body

    HERE  LOC-SLOT @ -  LOC-SLOT @ !  \ branch lands HERE: right before the
                                    \ prologue below, clearing the chain
                                    \ above along with the local headers

    \ bind every local, one DO across both kinds: last declared first,
    \ the one on top at run time for the stack-supplied ones. This keeps
    \ the chronological bind order the exact reverse of the chain's
    \ declared-position order (12.3) regardless of the -- split, which is
    \ what makes chain step j restore/push the local at position j.

    #LOCALS @ 0 DO
        I LOC-POS  LOC-BIND-XT @  ,     \ call this local's own binder
    LOOP

    COMPILE LIT
    LOC-CHAIN-START @ ,
    COMPILE >R

    ]                               \ re-affirm compiling: FOO's own : is
                                    \ still open, its ; will close it

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

    >IN @                           ( in )          \ where this name starts
    DEFLOCALS DEFINITIONS
    0 CONSTANT                      \ the local: a VALUE-like cell
    LATEST PFA                      ( in a )         \ this local's own cell

    SWAP >IN !                      ( a )            \ rewind: same name again
    DEFBINDS DEFINITIONS
    #IN-LOCALS @ 0<  IF  (LOC-BINDER-IN)  ELSE  (LOC-BINDER-OUT)  THEN
    LATEST PFA CFA  #LOCALS @ LOC-BIND-XT !

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
    BND-EMPTY BND-VOC !             \ empty the binders vocabulary
    0 #LOCALS !
    -1 #IN-LOCALS !                 \ sentinel: this form has no outputs,
                                    \ but (LOC-MAKE) still reads it per local
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

    (LOC-OPEN)                      \ open the branch scavalco
    (LOC-CLOSE)                     \ splice locals+chain, patch, bind, divert EXIT
;
IMMEDIATE

\ ----------------------------------------------------------------------
\ {  ccc1 ... cccn [ -- ccccn+1 ... ] }   -- IMMEDIATE, first in the body
\
\       : SUM3    { X Y Z }        X Y + Z + ;
\       : SUM-TO  { N -- ACC }     N 0> IF  N 0 DO  ACC I 1+ + TO ACC  LOOP  THEN ;
\
\ Declaration and use in one place: no count to keep in step, no separate
\ LOCALS-FOR to keep adjacent to the definition. It is the BRANCH scavalco
\ that makes this possible -- (LOC-OPEN) leaves FOO's own : open and just
\ jumps over whatever comes next, so CREATE is free to splice each local's
\ header right there.
\
\ Each name is parsed twice: >IN is rewound after the test against } (and
\ against --) so that CONSTANT parses the very same name. All the names,
\ the optional -- , and the } , must be on the SAME source line as the { .
\
\ On a malformed declaration the outer word survives as an unresolved
\ BRANCH (offset still 0, so calling it -- unreachable, since it also
\ stays smudged -- would spin), but stays smudged: (LOC-OPEN) does not
\ reveal it and QUIT never reaches the closing ; that would (KNOWN ISSUE,
\ carried over from the trampoline design -- see prompts/LOCALS-PLAN.md 14.5).

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
    BND-EMPTY BND-VOC !             \ empty the binders vocabulary
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
