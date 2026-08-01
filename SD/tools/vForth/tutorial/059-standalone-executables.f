\
\ 059-standalone-executables.f
\ Freezing a running vForth session into a standalone executable: ZAP / ZAP"
\
\ vForth is normally a live, interactive system: forth18e.bin + ram8.bin are
\ loaded by a BASIC loader, and you type commands at the "ok" prompt. ZAP and
\ ZAP" go the other way: they take a SNAPSHOT of the current running system
\ -- code, dictionary, block buffers, heap -- and freeze it into files that
\ boot straight into one chosen word, with no vForth prompt, no editor, just
\ your program starting up. This is how demo/chomp-chomp ships as a game a
\ player can run without ever seeing vForth itself (see demo/chomp-chomp/,
\ produced by ZAP, and demo/README.txt).
\
\ Two distinct output formats exist, covering the two vForth launch methods:
\   ZAP   -- three raw .bin snapshots (-core/-user/-heap) played back by a
\            BASIC loader such as Forth18_loader.bas. Fully working; this is
\            exactly what demo/chomp-chomp/game.bas does.
\   ZAP"  -- a single self-contained .nex file for the NextZXOS/CSpect
\            "run .nex" loader. Present in the source and documented in the
\            manual, but -- as section 7 shows by reading lib/ZAP~.f -- its
\            auto-launch patch is currently commented out. Treat it as
\            experimental, not yet a drop-in replacement for ZAP.
\
\ vForth-specific notes:
\   - "Available only for non dot-version" (vForth manual, sec.2.8): both
\     words assume the launcher-based vForth18_DOES boot flow (COLD reads
\     Forth18_loader.bas-style memory images). vForth18_DOT (the NextZXOS
\     dot-command variant) does not use this mechanism at all -- see
\     tutorial 057 for the dot-command route to a standalone NextZXOS
\     program instead.
\   - ZAP patches the CURRENT session's live COLD definition (section 4)
\     before it writes anything to disk. Read that section before typing
\     ZAP interactively for the first time -- it is not undone by FORGET.
\   - The manual calls this whole area "evolving for improvement" (sec.2.8);
\     this tutorial documents it exactly as shipped, gotchas included.
\
\ Starting FORTH (Brodie): no Brodie counterpart (vForth/NextZXOS extension).
\ Reference: sec.2.8 (Creation of standalone executable), sec.5.1 (ZAP
\ dictionary entry). ZAP" has no separate dictionary entry in the current
\ manual; sec.2.8 documents it jointly with ZAP.
\ Related: tutorial 042 (file I/O), tutorial 057 (dot commands -- the
\ NextZXOS-native alternative covering the same ground as ZAP").
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   059 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 059 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 059: standalone executables loaded. ) CR
.(     Type NEWTASK to unload.                     ) CR

\ =============================================================================
\ 1. The three things vForth is made of
\ =============================================================================
\
\ Root CLAUDE.md's Memory Layout describes the running system as three
\ regions, and ZAP saves exactly these three, as three separate files:
\
\   1. CODE     -- from ORIGIN ($6366 in tape/loader mode) up to HERE: the
\                  compiled Z80 code and the dictionary mirror area.
\   2. USER     -- the "system" zone below $E000: S0/TIB/R0/USER buffers and
\                  the block-buffer area (six 512-byte buffers).
\   3. HEAP     -- the MMU7-paged dictionary heap living at $E000-$FFFF,
\                  growing across 8K pages as you define words (lib/CLAUDE.md
\                  "Heap Memory Facility").
\
\ A BASIC loader that re-creates all three in memory, in the same relative
\ positions, and then jumps to the usual entry point reconstructs a working
\ vForth session byte-for-byte -- including whatever you just typed at the
\ prompt. ZAP's trick is to patch COLD (section 4) so that entry point runs
\ straight into your chosen word instead of the interactive REPL.


\ =============================================================================
\ 2. ZAP: the three-file snapshot
\ =============================================================================
\
\ NEEDS ZAP
\
\   INCLUDE demo/chomp-chomp.f     \ define your program first
\   ZAP CHOMP-CHOMP                \ note: bare name, NOT ' CHOMP-CHOMP
\
\ ZAP does not take its argument on the stack: like a plain word lookup, it
\ PARSES the next token from the input line itself (it uses the run-time,
\ non-immediate ' internally -- root CLAUDE.md's tick warning applies: this
\ only works typed at the prompt or as top-level source, never inside a
\ colon-definition). Usage is exactly:
\
\   ZAP filename
\
\ where filename is the NAME OF AN EXISTING WORD (the one you want to auto-
\ launch), and it doubles as the base of the three output filenames:
\
\   filename-core.bin
\   filename-user.bin
\   filename-heap.bin
\
\ demo/chomp-chomp/ contains exactly this triple (game-core.bin, game-user.bin,
\ game-heap.bin), produced by  ZAP GAME  against the chomp-chomp demo. This
\ tutorial does not run ZAP against a live word (section 4 explains why that
\ is not safe to do casually inside a loaded tutorial) -- read on, then try
\ it deliberately, in a session you are prepared to reboot afterward.


\ =============================================================================
\ 3. What actually goes in each file
\ =============================================================================
\
\ From lib/ZAP.f (worth reading directly -- it is short):
\
\   SAVE-CORE   ( -- )   0 +ORIGIN HERE OVER -  ...  WRITE-CLOSE
\ Everything from ORIGIN through the current HERE: the whole compiled system,
\ including every word you defined interactively before calling ZAP.
\
\   SAVE-USER   ( -- )   R0 @ $E000 OVER -  ...  WRITE-CLOSE
\ The system zone from R0 (top of the return-stack/buffer area) up to $E000:
\ S0/TIB/R0/USER and the six block buffers. Before saving, SAVE-USER forces
\ the standard error-message screens into their buffers first:
\   17 8 DO I BLOCK DROP LOOP
\ (root CLAUDE.md's Blocks/Screens table: Screens 4-7 = Blocks 8-15 hold the
\ text that ?ERROR / ERROR / MESSAGE display) -- so a standalone executable
\ can still report a sensible error message without needing the SD block
\ file open.
\
\   SAVE-HEAP   ( -- )   $0000 FAR PAGE-SIZE ... $2000 FAR PAGE-SIZE ...
\ Two consecutive 8K MMU7 pages (heap pages 0 and 1 -- one 16K bank in the
\ BASIC-bank sense, root CLAUDE.md's "Banks vs Pages") starting at the base
\ heap page. Only bank 16 is captured this way; SAVE-HEAP contains commented-
\ out code (banks 17/18/19, guarded by `$4000 HP@ <` etc.) for programs whose
\ heap has grown past the first 16K, disabled by default -- if your program
\ defines enough words to overflow one heap bank, you must uncomment the
\ matching block before calling ZAP (and edit the loader to load the extra
\ file too, section 6).


\ =============================================================================
\ 4. The live COLD patch -- read this before typing ZAP
\ =============================================================================
\
\ ZAP's very first action, before any file is written, is:
\
\   : ZAP
\       '                       \ parse filename -> xt
\       ['] COLD >BODY !        \ COLD's first cell := xt of your word
\       ['] BYE                 \ 'BYE
\       ['] COLD >BODY CELL+ !  \ COLD's second cell := xt of BYE
\       ...
\
\ COLD is an ordinary colon-definition; its first two "tokens" are STOREd
\ over directly. This is a live, in-place edit of the word COLD in the
\ dictionary you are CURRENTLY running -- not a copy, not something scoped
\ to the files being written. From the instant ZAP executes onward, in THIS
\ session, COLD no longer does its usual S0/R0/BLK-INIT/ABORT/AUTOEXEC
\ sequence: it runs your word, then BYE.
\
\ Consequences:
\   - This is exactly why the three .bin files, reloaded by a BASIC loader
\     that ends by invoking COLD, boot straight into your program: that IS
\     the point, and it is documented behaviour (vForth manual sec.2.8:
\     "ZAP modifies the definition of COLD by patching the first xt to be
\     cccc and the second xt to be BYE").
\   - It is NOT undone by FORGET. lib/ZAP.f's own MARKER TASK removes ZAP's
\     definitions from the dictionary, but MARKER only unwinds the
\     dictionary pointer -- it does not know how to reverse an arbitrary
\     STORE into a word's body that already existed before the marker.
\   - If you call ZAP interactively while continuing to work in the SAME
\     session, nothing breaks immediately (WARM/QUIT keep running), but the
\     NEXT time this session's COLD runs -- whether you type COLD yourself,
\     or the machine resets and re-executes the in-memory image -- it jumps
\     straight to your word and BYE, not back to the interactive prompt.
\
\ Rule of thumb: treat ZAP as the LAST thing you do with a session before
\ discarding it (power-cycle the real hardware, or reset the emulator, to
\ get a clean interactive vForth back). Do not ZAP in the middle of ordinary
\ development work.


\ =============================================================================
\ 5. Filename mechanics
\ =============================================================================
\
\ FILENAME ( -- cccc ) parses one blank-delimited word and copies it into a
\ fixed 48-byte buffer (CREATE FN 48 ALLOT); OPEN-FN appends one of the fixed
\ suffix strings (S-CORE/S-USER/S-HEAP, e.g. ," -core.bin") and opens the
\ result for write via NextZXOS F_OPEN mode %1110 (create-or-overwrite).
\ Because the base name plus the longest suffix ("-heap.bin", still short of
\ 48 bytes) must fit in FN, keep your ZAP target name reasonably short --
\ there is no bounds check beyond the fixed ALLOT, so an oversized name
\ silently overruns into whatever follows FN in the dictionary.
\
\ Files are created in the CURRENT working directory (whatever directory
\ vForth itself was started from -- tutorial 046's PATH GOTCHA applies
\ identically here).


\ =============================================================================
\ 6. Wiring up the BASIC loader
\ =============================================================================
\
\ ZAP writes the three .bin files but does not touch any .bas loader --
\ per the manual: "You have to manually modify the basic loader
\ 'Standard-Loader.bas' in order to load these three binary files and
\ invoke a vForth cold-start that runs cccc instead."
\
\ demo/chomp-chomp/game.bas is exactly that kind of edited loader (its own
\ banner calls it a "Generic standalone executable loader", a sibling
\ template to Standard-Loader.bas at the repo root -- same idea, same DATA-
\ line convention, not guaranteed byte-identical): its DATA line has been
\ changed from the generic placeholder to the real base name, e.g.:
\
\   DATA "Game"
\
\ At RUN time the loader reads that DATA string, builds the three filenames
\ by appending "-core.bin" / "-user.bin" / "-heap.bin", LOADs each at the
\ matching fixed address (the same addresses SAVE-CORE/SAVE-USER/SAVE-HEAP
\ used -- ORIGIN for the core image, and so on), and finally performs a
\ machine-code COLD start at ORIGIN. Because COLD itself was patched
\ (section 4) at the moment the snapshot was taken, that COLD start runs
\ your word, then BYE -- the player never sees "ok".
\
\ To ship your own: copy Standard-Loader.bas, change its DATA line to your
\ ZAP base name, and place it alongside the three generated .bin files (see
\ demo/chomp-chomp/ for the shipped example: game.bas + game-core.bin +
\ game-user.bin + game-heap.bin).


\ =============================================================================
\ 7. ZAP": the single-file .nex path (experimental)
\ =============================================================================
\
\ NEEDS ZAP"
\
\ ZAP" (lib/ZAP~.f -- FAT-mapped filename, root CLAUDE.md's quote-to-tilde
\ rule) targets the NextZXOS/CSpect .nex loader instead of a BASIC loader.
\ Documented usage (lib/ZAP~.f's own header comment):
\
\   ' cccc  ZAP" filename.nex"
\
\ Unlike ZAP, this DOES take its target as an xt already on the stack
\ (hence '  before it), and the filename is consumed the same way OPEN">
\ always works (tutorial-style: type the closing quote, it is not optional).
\
\ ZAP" builds a standard 512-byte .nex header (see the inline comment in
\ lib/ZAP~.f linking the NEX file format wiki page) and then writes a fixed
\ list of 16K banks, in the order the .nex format requires:
\
\   BANK-LIST:  5, 2, 0, 1, 8, 16
\
\ -- the base 128K working set (banks 5/2/0/1, matching CLAUDE.md's boot
\ regions), bank 8, and heap bank 16 (the same one SAVE-HEAP captures for
\ ZAP). Banks 3/4/6/7 and heap banks 17-19 are present in the source but
\ commented out, exactly like SAVE-HEAP's extra banks (section 3) -- same
\ caveat: uncomment the matching lines if your program needs more heap.
\
\ Header fields are POKEd directly via  value offset +HEADER !/C!  once
\ NEX-HEADER is set up; nothing stops you from overriding one AFTER loading
\ lib/ZAP~.f and BEFORE calling ZAP" -- see section 8 for why you may want to.


\ =============================================================================
\ 8. Known gotchas in the current ZAP" (found by reading lib/ZAP~.f)
\ =============================================================================
\
\ Two things in the shipped source do not match the documented behaviour.
\ Neither has been exercised on CSpect for this tutorial -- they are called
\ out here as exactly what the source currently does, not as a confirmed
\ CSpect failure.
\
\ (a) The auto-launch patch is commented out.
\ ZAP" declares  ( xt -- CCCC )  and its header comment implies the same
\ COLD-patch trick as ZAP (section 4), but every line that would perform it
\ is prefixed with \ in the source:
\
\       \ first save current COLD
\   \   ['] COLD >BODY       @ >R
\   \   ['] COLD >BODY CELL+ @ >R
\       \ put xt as first definition to execute at COLD start.
\   \   ['] COLD >BODY       !
\   \   ['] BYE
\   \   ['] COLD >BODY CELL+ !
\       ...
\       \ restore COLD
\   \   R> ['] COLD >BODY CELL+ !
\   \   R> ['] COLD >BODY       !
\
\ As shipped, the xt you push before ZAP" is accepted (the stack comment
\ still says so) but never consumed anywhere in the body -- it is simply
\ left sitting on the stack once ZAP" returns, and COLD is left exactly as
\ it was. A .nex built this way boots into whatever COLD currently does in
\ that memory image: ordinary interactive vForth, UNLESS you have already
\ live-patched COLD another way first (see the combination trick below).
\
\ (b) The saved Program Counter is a hardcoded literal, not derived from a
\     symbol:
\
\    $7634        14  +HEADER  !
\ \  4 +ORIGIN   14  +HEADER  !     <- an alternative form, also commented
\ \  0           14  +HEADER  !     <- "0 = don't run, just load"
\
\ Dictionary/code addresses shift with every core rebuild (root CLAUDE.md's
\ build-number convention), and this literal is not one of the canonical
\ locations that /bump-build updates -- so it can silently go stale. As a
\ concrete check: cross-referencing $7634 against the CURRENT build's
\ project/vForth18_DOES/list/main.lst places it in the middle of COLD's own
\ compiled token list (past the S0/USER-pointer setup, mid-way through a
\ later LIT/PLUS pair) -- not at a genuine Z80 instruction boundary. Jumping
\ there via the .nex loader's raw CPU JP is not the same thing as invoking
\ COLD through the normal boot chain (root CLAUDE.md's Boot Sequence
\ section: entry -> ColdRoutine -> COLD). Before relying on the PC field,
\ verify it against the build you are actually running, or override it
\ explicitly right before calling ZAP":
\
\   [ find the correct entry address for your build, e.g. from main.lst ]
\   CONSTANT REAL-ENTRY
\   REAL-ENTRY 14 +HEADER !        \ after NEEDS ZAP" has run NEX-HEADER's init
\   ' MYWORD ZAP" myfile.nex"
\
\ Practical combination, until (a) is fixed upstream: since ZAP itself DOES
\ patch COLD correctly (section 4), running ZAP first and ZAP" immediately
\ after, in the same session, means ZAP"'s saved banks already contain a
\ live-patched COLD -- ZAP" merely needs to jump into the ordinary boot
\ chain (ORIGIN, not a raw literal into COLD's middle) to reach it:
\
\   ZAP MYWORD                     \ patches COLD (section 4); also writes
\                                   \ 3 .bin files you can ignore here
\   ' MYWORD ZAP" myfile.nex"      \ freezes the now-patched image to .nex
\
\ This still inherits caveat (b) above -- confirm the PC field before
\ trusting the result to auto-run.


\ =============================================================================
\ 9. Further reading
\ =============================================================================
\
\ lib/ZAP.f              full source of ZAP (SAVE-CORE/SAVE-USER/SAVE-HEAP).
\ lib/ZAP~.f              full source of ZAP" (.nex header, BANK-LIST).
\ demo/chomp-chomp.f      the demo program ZAP was run against for the
\ demo/chomp-chomp/       shipped example (game.bas + the three .bin files).
\ demo/README.txt         "Chomp-chomp.f" entry documents the same workflow
\                         from the player's side.
\ Standard-Loader.bas     the generic loader template to copy and edit
\ Forth18_loader.bas      (repo root); the ordinary (non-ZAPped) loader for
\                         comparison -- same structure, no DATA name to edit.
\ tutorial 042            file-io (F_OPEN/F_WRITE/F_CLOSE primitives both
\                         ZAP and ZAP" build on).
\ tutorial 057            dot-commands: the NextZXOS-native alternative for
\                         a standalone program, unrelated machinery, useful
\                         point of comparison with ZAP"'s .nex approach.

\ NEEDS TESTING
\ This tutorial deliberately performs no file writes and no COLD patch of
\ its own (sections 4 and 8 explain why that would not be safe to do simply
\ by loading a tutorial). Verifying ZAP/ZAP" end to end means: NEEDS ZAP,
\ ZAP a small test word, copy Standard-Loader.bas with its DATA line edited,
\ and boot the result on CSpect or real hardware -- outside the scope of an
\ automated T{ }T block.
