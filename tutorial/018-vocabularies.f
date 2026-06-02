\
\ 018-vocabularies.f
\ Vocabularies: VOCABULARY, DEFINITIONS, FORTH, CONTEXT, CURRENT.
\
\ vForth organises its dictionary into named vocabularies.  At any
\ moment two vocabulary pointers are active:
\
\   CONTEXT  -- the vocabulary searched when executing words
\   CURRENT  -- the vocabulary that receives new definitions
\
\ At startup both point to the FORTH vocabulary, which holds the entire
\ standard dictionary.  Creating a new vocabulary with VOCABULARY gives
\ a fresh namespace whose words overlay FORTH when selected.
\
\ Switching vocabularies:
\   name         -- make name the CONTEXT vocabulary (search order)
\   name DEFINITIONS -- make name the CURRENT vocabulary (new defs go here)
\   FORTH        -- switch CONTEXT back to FORTH
\   FORTH DEFINITIONS -- switch CURRENT back to FORTH
\
\ Note: vForth's search order is single-vocabulary (no ALSO/PREVIOUS/ONLY).
\ CONTEXT holds exactly one vocabulary at a time.
\
\
\ Reference: sec.2.12.13
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   018 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 018 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 018: vocabularies loaded. ) CR
.(     Type NEWTASK to unload.   ) CR


\ ===========================================================================
\ 1. Creating a vocabulary
\ ===========================================================================
\
\ VOCABULARY name  ( -- )
\   Creates a new named vocabulary.  The vocabulary initially contains
\   the words of FORTH (it shares the same tail).
\
\   VOCABULARY MYWORDS      \ create the vocabulary
\   MYWORDS DEFINITIONS     \ new definitions go into MYWORDS
\   : HELLO  ." Hello from MYWORDS" CR ;
\   FORTH DEFINITIONS       \ switch back to FORTH
\
\ After the above, HELLO exists only in MYWORDS, not in FORTH.
\ To use it, make MYWORDS the CONTEXT:
\   MYWORDS   HELLO         \ => Hello from MYWORDS

VOCABULARY SHAPES
SHAPES DEFINITIONS

: .CIRCLE   ( -- )  ." O"  CR ;
: .SQUARE   ( -- )  ." []" CR ;
: .TRIANGLE ( -- )  ." /\" CR ;

FORTH DEFINITIONS

.( Try: SHAPES .CIRCLE   ) CR
.( Try: SHAPES .SQUARE   ) CR


\ ===========================================================================
\ 2. DEFINITIONS -- switching compilation target
\ ===========================================================================
\
\ Switching the CURRENT vocabulary controls where new definitions land.
\ The pattern is always:
\   name DEFINITIONS  \ switch to name
\   ...definitions...
\   FORTH DEFINITIONS \ switch back
\
\ Forgetting to switch back is the classic vocabulary mistake.

.( SHAPES vocabulary created with .CIRCLE, .SQUARE, .TRIANGLE. ) CR


\ ===========================================================================
\ 3. CONTEXT -- searching the right vocabulary
\ ===========================================================================
\
\ Executing a vocabulary name sets CONTEXT so the interpreter searches
\ that vocabulary first.  If the word is not found there, FORTH is
\ searched (because the new vocabulary's tail points to FORTH).
\
\ CONTEXT @  gives the address of the current context vocabulary PFA.
\ CURRENT @  gives the address of the current compilation vocabulary PFA.


\ ===========================================================================
\ 4. Searching order: CONTEXT is searched first
\ ===========================================================================
\
\ If a word with the same name exists in both vocabularies, the CONTEXT
\ vocabulary wins.  This is how vocabularies provide selective override.
\
\ Example: ASSEMBLER defines words like LD, JP, etc. that override
\ any same-named FORTH words while ASSEMBLER is CONTEXT.
\
\   ASSEMBLER       \ set CONTEXT to ASSEMBLER
\   ...assembler words...
\   FORTH           \ reset CONTEXT to FORTH
\
\ The same pattern is used by any domain-specific vocabulary.

.( Try: SHAPES WORDS    ) CR


\ ===========================================================================
\ 5. Cleaning up -- vocabulary words live until FORGET or MARKER
\ ===========================================================================
\
\ The MARKER placed at the top of this file (NEWTASK) forgets
\ everything defined here, including SHAPES and its words.
\ This is the recommended way to manage vocabulary lifetimes.
\
\ FORGET name  can also remove a specific word and everything after it,
\ but MARKER is preferred for module-level cleanup.


\ ===========================================================================
\ 6. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ NEEDS TESTING
\ T{  CURRENT @ .VOCAB  -> }T   \ prints "FORTH"
\ T{  SHAPES  CONTEXT @ .VOCAB -> }T  \ prints "SHAPES"
\ T{  FORTH    CONTEXT @ .VOCAB -> }T   \ prints "FORTH"
