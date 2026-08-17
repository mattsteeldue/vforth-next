\
\ 060-idiomatic-traps.f
\ A field guide to silent Forth/vForth traps: mistakes that compile
\ cleanly, run without an error message, and only misbehave later.
\
\ Every trap here was found and fixed at least once in this project's own
\ source -- inc/, lib/, or an earlier tutorial -- usually because it
\ produced a wrong answer or a crash with no diagnostic pointing at the
\ real cause. None of them are exotic: each is a case where two words (or
\ two usages of the same word) look interchangeable but are not, and the
\ difference only shows up once the wrong choice actually runs.
\
\ vForth-specific notes:
\   - Several traps here are general Forth idiom (any Forth system has an
\     interpret-state/compile-state split); a few are specific to this
\     project's own core (heap volatility, the block/screen file format,
\     the INCLUDE/NEEDS line reader). Both kinds bite the same way: no
\     error, just a wrong result.
\   - Hardware-register gotchas (AY mixer bit sense, sprite slot vs
\     pattern, Layer 2 palette auto-increment, ...) are NOT repeated here
\     -- they belong to, and are already covered by, their own tutorials
\     (034, 053, 056). This tutorial stays at the language/core level.
\
\ Starting FORTH (Brodie): no Brodie counterpart (this tutorial documents
\ vForth-specific and general-Forth idiom pitfalls, not a language feature
\ Brodie teaches).
\ Reference: sec.2 (core words), sec.3.20 (dictionary/heap structure).
\ Companion reading: root CLAUDE.md sections "CHAR vs [CHAR]" and
\ "DOES> and PFA"; tutorial/CLAUDE.md sections 6, 7, 12.
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   060 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 060 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 060: idiomatic traps loaded. ) CR
.(     Type NEWTASK to unload.              ) CR

NEEDS [']
NEEDS DEPTH
NEEDS PAD"

\ =============================================================================
\ 1. Interpret-state vs compile-state parsing words: '  vs  [']
\ =============================================================================
\
\ Some words come in pairs: one parses the next token IMMEDIATELY, right
\ where it is typed or loaded from (interpret state); the other is an
\ IMMEDIATE, compile-ONLY word meant for use inside a colon-definition,
\ where it parses at COMPILE TIME and compiles code that does the
\ equivalent job when the definition later RUNS. Using the wrong half is
\ silent: it compiles without complaint and only misbehaves at run time.
\
\ '  (tick) is NOT immediate in vForth (unlike some other Forths):
\   : '  -find 0= 0 ?error drop ;
\ It parses and looks up the next word AT RUN TIME. At the interpreter
\ prompt, or as top-level code in a loaded file, that is exactly what you
\ want: "look up the word that follows, right now, give me its xt." Used
\ INSIDE a colon-definition, '  compiles a CALL to ' itself plus an
\ ordinary call to whatever word follows in the SOURCE -- but ' does its
\ actual parsing at RUN TIME, grabbing whatever token follows wherever/
\ whenever the definition is CALLED, which is very unlikely to be the word
\ that happened to follow it in the source.
\
\ (Bug found and fixed in tutorial 049 INSTALL-COUNTER/REMOVE-COUNTER,
\ 2026-06-15; lib/MOUSE.f's "' MOUSE-DELTA ISR-XT !" at interpret time is
\ the correct use of the SAME line shape that would be wrong inside a
\ definition.)

: DOUBLE  ( n -- 2n )  2* ;
: TRIPLE  ( n -- 3n )  DUP 2* + ;
VARIABLE MY-HANDLER

\ RIGHT: at the interpreter (top level), ' grabs DOUBLE's xt right now.
' DOUBLE MY-HANDLER !

: RUN-HANDLER  ( n -- n' )  MY-HANDLER @ EXECUTE ;

\   5 RUN-HANDLER .    => 10   ( MY-HANDLER holds DOUBLE )

\ WRONG: the same idea, written INSIDE a definition.
: BUGGY-INSTALL  ( -- )
    '  MY-HANDLER !            \ ' parses its target at RUN TIME, not now
;

\ At compile time this merely compiles "call ' ", "call MY-HANDLER",
\ "call !" -- DOUBLE is never mentioned. When BUGGY-INSTALL later runs,
\ ' parses whatever token follows IT in the input at that moment. Because
\ this whole tutorial is itself just such an input stream, the next line
\ demonstrates it deterministically: BUGGY-INSTALL's internal ' grabs
\ TRIPLE off this very line, not DOUBLE.

BUGGY-INSTALL TRIPLE
\   5 RUN-HANDLER .    => 15, not 10 -- MY-HANDLER now silently means TRIPLE
5 RUN-HANDLER . CR

\ Restore MY-HANDLER to DOUBLE for the rest of the tutorial.
' DOUBLE MY-HANDLER !

\ To compile a specific word's xt as a literal INSIDE a definition, use
\ the compile-only immediate [']:
\
\   : INSTALL-DOUBLE  ( -- )  ['] DOUBLE MY-HANDLER ! ;
\
\ ['] parses DOUBLE at COMPILE time and compiles code that pushes its xt
\ (a literal) whenever INSTALL-DOUBLE later runs -- deterministic, no
\ matter what follows INSTALL-DOUBLE when it is called.

: INSTALL-DOUBLE  ( -- )  ['] DOUBLE MY-HANDLER ! ;

INSTALL-DOUBLE TRIPLE
\   5 RUN-HANDLER .    => 10 -- TRIPLE on the same line is irrelevant now,
5 RUN-HANDLER . CR      \ EXECUTE ran it as an ordinary call, unconsumed

\ The exact same pairing exists for CHAR / [CHAR]:
\   CHAR    -- interpret-state: parse the next word, push its first
\              character code, right now.
\   [CHAR]  -- compile-only immediate: parse at compile time, compile a
\              literal push for when the enclosing definition runs.
\
\ Real example (lib/DIR.f, found and fixed 2026-07-19): a VARIABLE
\ initialised right after CREATE/VARIABLE is TOP-LEVEL code -- interpreted,
\ not inside a colon-definition -- so it must use plain CHAR:
\
\   VARIABLE DIR-DRIVE   CHAR C DIR-DRIVE C!     \ right: top level
\   VARIABLE DIR-DRIVE   [CHAR] C DIR-DRIVE C!   \ wrong: [CHAR] belongs
\                                                 \ only inside : ... ;
\
\ (Historical: DIR-DRIVE has since been removed from lib/DIR.f -- DIR now
\ leaves the drive to the NextZXOS default '*'. The trap it illustrates is
\ unchanged, and applies to any VARIABLE initialised at top level.)
\
\ Just like '  vs [']: the rule is not "which one runs" (both may well
\ produce *something*) but "which state you are in" -- interpreting a
\ top-level line, or compiling a colon-definition's body.


\ =============================================================================
\ 2. N LITERAL: redundant, and silently wrong
\ =============================================================================
\
\ Inside a colon-definition, a bare number ALREADY auto-compiles as a
\ literal push. LITERAL is not "the word that makes a number a literal" --
\ it is for a VALUE COMPUTED AT COMPILE TIME inside [ ... ], one that
\ is NOT already sitting in the source as a plain number:
\
\   : FIVE   5 ;                    \ RIGHT: 5 auto-compiles as a literal
\   : FIVE   5 LITERAL ;            \ WRONG: see below
\
\   : SCREEN-TOP  [ $6000 $2000 - ] LITERAL ;   \ RIGHT use of LITERAL:
\                                                \ compiles the single
\                                                \ value $4000, computed
\                                                \ inside [ ], as a literal
\
\ "5 LITERAL" compiles "5" as a normal literal (pushing 5 at run time),
\ then LITERAL itself -- an IMMEDIATE word -- executes AT COMPILE TIME and
\ pops whatever happens to be on the REAL data stack at that moment (left
\ over from whatever was typed/loaded just before this definition, NOT the
\ "5" the source just mentioned, which was compiled, never pushed) and
\ compiles THAT as a second, spurious literal. The result: FIVE pushes TWO
\ cells at run time, not one -- silently, with no error at compile time.
\ (Bug found and fixed in tutorial 041 PEEK-L2-ROW, 2026-06-15.)

: RIGHT-FIVE   5 ;

\ LITERAL's compile-time pop needs SOMETHING on the real stack to grab. An
\ empty stack at this point would underflow WHILE COMPILING WRONG-FIVE --
\ before it is ever called -- and vForth's ";" separately checks that the
\ stack is exactly as deep as it was when the matching ":" ran (message 4,
\ "Bad definition end"); popping a value that was already there before
\ ":" started would upset that check and refuse to close the definition.
\ [ 0 ]  sidesteps both: it briefly drops back to interpret state to push
\ a harmless 0, entirely INSIDE this definition's own compile window, for
\ LITERAL to eat -- keeping ";" balanced while still proving the point.
\ In real broken code there is no such friendly stand-in: the value
\ LITERAL grabs is whatever was left lying around, unpredictable.
: WRONG-FIVE   5  [ 0 ]  LITERAL ;

: .GROWTH  ( xt -- )   \ how many EXTRA cells xt leaves beyond what
    DEPTH >R  EXECUTE  DEPTH R> -  .   \ EXECUTE itself already accounts for
;

' RIGHT-FIVE .GROWTH   \ => 0  (consumed the xt, pushed one 5: even)
DROP                    \ discard the 5 RIGHT-FIVE left behind

' WRONG-FIVE .GROWTH   \ => 1  (one EXTRA, unexpected cell on the stack!)
DROP DROP CR            \ discard WRONG-FIVE's two leftover cells


\ =============================================================================
\ 3. VARIABLE takes no initial value (breaking change since v1.52)
\ =============================================================================
\
\ VARIABLE always initialises to 0 and consumes NOTHING from the stack.
\ Executing a VARIABLE word just pushes its own address (PFA) -- full
\ stop. Older code (pre-1.52) that pushed a value first, expecting
\ VARIABLE to consume it as an initial value, is silently wrong now: the
\ value is simply left on the stack, untouched, ignored by VARIABLE.
\
\   VARIABLE COUNT       \ COUNT initialised to 0, nothing consumed
\   42 VARIABLE COUNT    \ WRONG assumption -- 42 just sits on the stack
\
\ Give a variable a non-zero starting value by storing into it explicitly,
\ right after creating it:

VARIABLE DEMO-COUNT
DEMO-COUNT @ . CR       \ => 0
42 DEMO-COUNT !
DEMO-COUNT @ . CR       \ => 42


\ =============================================================================
\ 4. Numeric-literal prefixes vs switching BASE mid-load
\ =============================================================================
\
\ BASE is one single, global setting. Changing it while a file is being
\ compiled/loaded (a stray HEX with no matching DECIMAL before the next
\ number) leaks into every number parsed afterwards -- in every file
\ NEEDS/INCLUDE pulls in next -- until something resets it. Prefer
\ per-literal prefix characters instead; they need no global state:
\
\   $FF          \ hex,          regardless of the current BASE
\   %11111111    \ binary,       regardless of the current BASE
\   #255         \ forces decimal (superfluous -- decimal is the assumed
\                \ default -- but a fine self-documenting marker in
\                \ otherwise hex-heavy code)
\
\ HEX/DECIMAL remain fine for OUTPUT formatting, tightly bracketed around
\ one line -- never left changed across a file boundary or a NEEDS/
\ INCLUDE call.

$FF . %11111111 . #255 . CR    \ => 255 255 255 -- three spellings, one value
255 HEX . DECIMAL CR            \ => FF -- BASE switch, used and reversed
                                 \ on the very same line


\ =============================================================================
\ 5. EMIT vs EMITC: masked vs full byte
\ =============================================================================
\
\ EMIT ( c -- ) masks its argument to 7-bit ASCII (0-127) before printing.
\ EMITC ( c -- ) sends the full byte (0-255) unmasked -- the one to use
\ for ZX Spectrum UDGs and the extended block-graphics character set
\ (128-255). Reach for EMIT out of habit when a UDG or extended character
\ was wanted, and the top bit silently vanishes: the character 128 LOWER
\ than the one asked for prints instead -- not an error, just the wrong
\ glyph.
\
\   144 EMIT     \ prints as if 16 was asked for (144 - 128 masked away)
\   144 EMITC    \ prints the real extended character 144

16 EMIT  SPACE  144 EMIT  SPACE  144 EMITC  CR   \ first two glyphs match


\ =============================================================================
\ 6. Heap pointers (FAR / HEAP) are volatile
\ =============================================================================
\
\ HP@ tracks the heap allocation frontier as a heap-pointer (page number
\ plus offset packed into one cell). FAR ( ha -- a ) decodes it: it maps
\ the target 8K page onto MMU7 ($E000-$FFFF) and returns a real address in
\ that window. That address stays valid ONLY until the NEXT FAR or HEAP
\ call remaps MMU7 to a different page -- including one made indirectly,
\ deep inside some other word that itself happens to touch the heap.
\
\   H" first"   H" second"        \ two heap-pointers, ha1 and ha2
\   ha2 FAR                       \ decode ha2 -> a2 (MMU7 now shows the
\                                 \ page holding "second")
\   ha1 FAR                       \ decode ha1 -> a1 (MMU7 REMAPPED here --
\                                 \ a2 is no longer valid memory to read!)
\
\ Using a1 now is fine; re-using the EARLIER a2 reads whatever now sits at
\ that offset in the NEW page -- garbage, silently, no error raised. Rule:
\ copy heap data you need to keep (to PAD or HERE) immediately after
\ decoding it with FAR, before any further FAR/HEAP call. See lib/CLAUDE.md
\ "Defensive patterns for heap addresses" for the worked FILENAME example
\ this rule is drawn from.


\ =============================================================================
\ 6bis. PAD is a single shared buffer -- not scoped to one string
\ =============================================================================
\
\ PAD" (inc/PAD~.f) is the RIGHT way to defuse the FAR/HEAP volatility trap
\ above: at run time it decodes the heap string and immediately CMOVEs it
\ into PAD, before any further FAR/HEAP call can remap MMU7 out from under
\ it. PAD" itself is not the trap here -- it is the idiomatic fix. But it
\ trades one volatility for another: PAD is ONE global scratch buffer,
\ shared by everything that happens to write through it -- WORD, FILENAME
\ (lib/TUTORIAL.f), DIR-PAD (lib/DIR.f), PAD" itself, and any word calling
\ any of those, often several calls deep with no hint in its name that it
\ touches PAD at all. Whatever a PAD" left there is only valid until the
\ NEXT such write, from anywhere, for any reason -- exactly the same "no
\ error, just a silently wrong value" shape as the FAR/HEAP trap, just
\ against a different resource.
\
\ (A second, smaller trap inside the trap: PAD" leaves a Z-STRING in PAD --
\ text then a single $00 terminator, no leading length byte, per >ZPAD in
\ inc/}ZPAD.f -- exactly what F_OPEN/LOAD-BYTES expect as a filename, but
\ NOT a counted string. PAD COUNT TYPE would misread the first character of
\ the text as a bogus length byte. .ZSTRING below just walks bytes to the
\ $00, the correct way to print what PAD" produces.)

: .ZSTRING  ( a -- )
    BEGIN
        DUP C@
    WHILE
        DUP C@ EMIT  1+
    REPEAT
    DROP
;

\   PAD" alpha"  PAD .ZSTRING     => alpha   (fine: read right away)
\
\   PAD" alpha"                      \ stash "alpha" in PAD
\   PAD" beta"                       \ ANY further PAD-writer silently wins
\   PAD .ZSTRING                     => beta, not alpha -- no error, ever
\
\ Rule: treat a string PAD" parks in PAD exactly like a freshly FAR-decoded
\ heap address -- read it, or copy it elsewhere, immediately, before calling
\ anything else -- not "eventually, once I'm done with other work."

PAD" alpha"  PAD .ZSTRING CR          \ => alpha

PAD" alpha"
PAD" beta"
PAD .ZSTRING CR                        \ => beta -- alpha silently lost


\ =============================================================================
\ 7. OPEN< is interpretation-only
\ =============================================================================
\
\ OPEN< can only be used in interpretation mode. Calling it inside a
\ colon-definition is not supported and produces INCORRECT behaviour --
\ not a clean error refusing the call, just wrong results. If a word needs
\ to open a file, have it call F_OPEN directly (the primitive OPEN< itself
\ wraps) rather than routing through OPEN< from inside a definition.


\ =============================================================================
\ 8. FLOATING / NO-FLOATING patches INTERPRET globally
\ =============================================================================
\
\ NEEDS FLOATING patches INTERPRET, replacing its NUMBER call with
\ FNUMBER, so a literal like 3.14 parses as floating point instead of a
\ double integer. This is a GLOBAL, session-wide patch, not scoped to any
\ one file or definition. Forgetting NO-FLOATING before returning to
\ integer work means every subsequent decimal-point number -- in any file
\ loaded afterwards -- silently misparses as a float instead of a double,
\ with no error at the point of the mistake.
\
\ The reverse trap exists too: after NO-FLOATING, a literal with a decimal
\ point goes back to being read as a double integer, not a float, so code
\ that still expects floating-point literals silently breaks the other
\ way. A tutorial or module that loads FLOATING must always provide its
\ own restore path -- see lib/CLAUDE.md's "Patch-requiring libraries"
\ section for the NEWTASK-calls-NO-FLOATING pattern tutorial 024 uses.


\ =============================================================================
\ 9. INCLUDE / NEEDS: the trailing-space-before-EOF crash
\ =============================================================================
\
\ INCLUDE (and NEEDS, which uses it) crashes -- typically a vertical grid
\ on screen -- if the loaded file's very last line ends with a space
\ immediately before the final newline. The rule is byte-exact: the
\ file's last byte must be $0A (LF), and the SECOND-TO-LAST byte must not
\ be $20 (space). Trailing blank lines are fine; a trailing space on an
\ INTERIOR line is harmless -- only the final two bytes of the whole file
\ matter. When authoring or generating a .f file, verify those two bytes
\ specifically rather than "cleaning" trailing whitespace throughout (that
\ produces needless diff noise for no safety benefit -- see root
\ CLAUDE.md's editing note on this rule).


\ =============================================================================
\ 10. Screens/Blocks: a stray NUL, and structures spanning a Block
\ =============================================================================
\
\ Two related traps in the block-based screen interpreter (LOAD):
\
\ - A NUL byte ($00) inside a screen silently STOPS interpretation right
\   there, mid-load, with no error message at all. Use EDIT to locate it
\   if a screen mysteriously loads "part way".
\ - A long structured definition (an ENUMERATED, for instance) cannot
\   straddle the boundary between the first and second half-KB Block of
\   the same Screen -- it must fit entirely within one Block. A definition
\   that grows past that boundary needs to be split or moved, not simply
\   continued onto the next Block.
\
\ Both are specific to the classic Screen/Block file format
\ (!Blocks-64.bin) and do not apply to ordinary file-based INCLUDE.


\ =============================================================================
\ Quick reference
\ =============================================================================
\
\   1.  '  vs [']            -- interpret-state vs compile-only lookup
\       CHAR vs [CHAR]        -- the same pairing, for a character literal
\   2.  N LITERAL              -- redundant; LITERAL is for [ ... ]-computed
\                                 values only, never a bare number
\   3.  VARIABLE                -- no initial value taken; always inits to 0
\   4.  BASE                    -- prefer $/%/# prefixes over HEX/DECIMAL
\                                 during compilation
\   5.  EMIT vs EMITC            -- 7-bit-masked vs full-byte output
\   6.  FAR / HEAP                -- decoded heap addresses are volatile
\   6bis. PAD                       -- one shared buffer; PAD" strings are
\                                      volatile against ANY next PAD-writer
\   7.  OPEN<                       -- interpretation-only
\   8.  FLOATING / NO-FLOATING       -- global INTERPRET patch; always pair them
\   9.  INCLUDE / NEEDS               -- last two file bytes must not be " \n"
\   10. Screens/Blocks                 -- NUL kills LOAD silently; no
\                                          structure may span a Block

\ NEEDS TESTING
\ T{  5 RUN-HANDLER  ->  10  }T
\ T{  DEMO-COUNT @    ->  42  }T
