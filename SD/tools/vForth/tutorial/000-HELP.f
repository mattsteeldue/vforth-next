\
\ 000-HELP.f
\ HELP: on-line documentation for vForth words.
\
\ Every word shipped with vForth (core, inc/, and lib/) has a matching
\ plain-text file under help/.  HELP fetches and prints the file for a
\ given word name, so you can look up a word's stack effect and purpose
\ without leaving the interactive session.  Because it is the single most
\ useful tool while working through the rest of this tutorial series, it
\ is numbered 000 and meant to be read first.
\
\ no Brodie counterpart (vForth extension)
\ Reference: sec.2.12 (utility words); see help/CLAUDE.md for file format
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   000 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 000 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 000: HELP loaded. ) CR
.(     Type NEWTASK to unload.   ) CR

NEEDS HELP

\ ===========================================================================
\ 1. What HELP is
\ ===========================================================================
\
\   HELP cccc  ( -- )   print the help file for word cccc
\
\ HELP parses the next word from the input (like : or CREATE do), maps it
\ to a filename in the help/ directory using the same FAT-safe character
\ mapping as NEEDS and INCLUDE (see root CLAUDE.md, "FAT Filename Character
\ Mapping" -- e.g. ? becomes ^, / becomes %), and sends the matching .txt
\ file straight to the display.
\
\   HELP DUP     \ prints help/dup.txt
\   HELP SWAP    \ prints help/swap.txt
\
\ Try it now:
\   HELP DUP
\   HELP DROP
\   HELP OVER
\   HELP ROT

\ ===========================================================================
\ 2. What a help file looks like
\ ===========================================================================
\
\ Each file is short, plain ASCII text: the word name and stack effect on
\ the first line, a blank line, then one to three lines of prose.  For
\ example help/dup.txt reads:
\
\     DUP  n -- n n
\
\   Duplicate top of stack.
\
\ HELP DUP shows exactly this.  The format is documented in help/CLAUDE.md
\ for anyone adding a new word and its help file together.

\ ===========================================================================
\ 3. When help is not found
\ ===========================================================================
\
\ If no help/ file exists for the name you typed, VIEW-FILE-PAD (the word
\ HELP hands the filename to) reports the standard NextZXOS open error
\ (message 41).  This is normal for words you defined yourself, or for a
\ typo in the name -- HELP does not search the dictionary, only the help/
\ directory, so it cannot tell "unknown word" from "no help file yet".
\
\   HELP NOSUCHWORD    => (reports "NextZXOS Open error.")

\ ===========================================================================
\ 4. FAT-mapped names
\ ===========================================================================
\
\ Words containing characters illegal in FAT filenames are looked up under
\ their mapped form automatically -- you still type the real Forth name:
\
\   HELP /MOD    \ looks up help/%mod.txt
\   HELP >R      \ looks up help/}r.txt
\   HELP S"      \ looks up help/s~.txt
\
\ See root CLAUDE.md, "FAT Filename Character Mapping", for the full table.

\ ===========================================================================
\ 5. Caveat: HELP is interpret-state only
\ ===========================================================================
\
\ HELP is an ordinary (non-immediate) word: it fetches its argument with
\ BL WORD at RUN time, the same way ' (tick) does (see tutorial/CLAUDE.md
\ sec.7).  Compiling  HELP DUP  into a colon definition does NOT bind DUP
\ as HELP's argument -- the compiler just compiles two separate calls,
\ HELP and DUP, one after the other.  When such a definition later runs
\ from the prompt, >IN has already moved past the whole command line, so
\ HELP's own BL WORD finds nothing left to read and reports "file not
\ open" instead of showing help for DUP.
\
\ The mistake is silent at compile time, exactly like the ' gotcha --
\ there is no error until you notice the wrong (or missing) help text.
\
\ Typed directly at the interactive prompt this is not a problem: HELP's
\ BL WORD shares the very same input line as the interpreter loop that
\ is calling it, so several lookups chain correctly on one line:
\
\   HELP DUP    HELP DROP    HELP SWAP    HELP OVER    HELP ROT
\
\ Rule: always invoke HELP directly at the prompt (or as top-level code
\ in a loaded source file).  Never wrap it inside a colon definition --
\ by the time a compiled word runs, the line that invoked it has already
\ been fully consumed, so there is nothing left for HELP's BL WORD to
\ read.

CR
.( Try: HELP DUP  ) CR
.( Try: HELP SWAP ) CR

\ ===========================================================================
\ 6. Notes on testing
\ ===========================================================================
\
\ HELP writes to the console via VIEW-FILE-PAD and leaves nothing on the
\ stack, so it has no automated {..}T tests.  Verify it by hand:
\
\   HELP DUP           \ see the DUP help file printed
\   HELP NOSUCHWORD     \ see the "NextZXOS Open error." message instead
