\
\ 059-standalone-executables.f
\ Freezing a vForth program into a standalone executable: ZAP / ZAP"
\
\ vForth is normally a live, interactive system: forth18e.bin + ram8.bin are
\ loaded by a BASIC loader, and you type commands at the "ok" prompt. ZAP and
\ ZAP" go the other way: they take a SNAPSHOT of the running system -- code,
\ dictionary, user area, block buffers, heap -- and freeze it into files that
\ boot straight into one chosen word, with no prompt and no editor: just your
\ program starting up. This is how demo/chomp-chomp ships as a game a player
\ can run without ever seeing vForth itself.
\
\ Two output formats, two ways of starting the result:
\   ZAP   -- raw .bin snapshots (-core, -user, one -heap per 16K bank) that
\            a BASIC loader copied from Standard-Loader.bas loads and starts.
\            demo/chomp-chomp/ holds game.bas and the files of ZAP GAME.
\   ZAP"  -- one .nex file, started from the NextZXOS Browser (or .nexload):
\            no loader to edit, no addresses to keep aligned.
\            demo/chomp-chomp/chomp-chomp.nex is the same game made so.
\ Both were confirmed on CSpect with chomp-chomp on 2026-11-08.
\
\ vForth-specific notes:
\   - "Available only for non dot-version" (vForth manual, sec.2.8): both
\     words assume the launcher-based vForth18_DOES memory layout. The
\     dot-command variant (.vforth) cannot use them; tutorial 057 shows the
\     dot-command route to a standalone NextZXOS program instead.
\   - NEEDS ZAP (or NEEDS ZAP") must be the LAST thing loaded before ZAP:
\     the image is the dictionary as it was just before it (section 3).
\   - ZAP leaves the live session as it found it: it patches a few cells
\     only while it writes, then puts them back (section 4). You can keep
\     working, and ZAP again.
\
\ Starting FORTH (Brodie): no Brodie counterpart (vForth/NextZXOS extension).
\ Reference: sec.2.8 (Creation of standalone executable), sec.6.1 (ZAP
\ dictionary entry). HELP ZAP, HELP ZAP" give the short form.
\ Related: tutorial 042 (file I/O), tutorial 057 (dot commands).
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
\ 1. What a running vForth is made of
\ =============================================================================
\
\ ZAP saves the running system as three kinds of memory image:
\
\   CORE  -- from ORIGIN ($6366, 25446) up to HERE: the compiled code of the
\            core and of every word you defined, and the dictionary mirror.
\   USER  -- from R0 @ (53652 on the current build) up to $E000: the user
\            variables (BASE, DP, HP, WARNING...) and the seven 512-byte
\            block buffers.
\   HEAP  -- the names of the dictionary and anything else allotted there,
\            living in 8K pages reached through MMU7 at $E000-$FFFF. Saved
\            one 16K BASIC bank at a time: bank 16 (pages $20/$21), then
\            17, 18, 19, as far as HP has reached.
\
\ A loader that puts all three back where they were, and then enters at
\ ORIGIN, rebuilds the session byte for byte. What makes it a standalone
\ program rather than a copy of your session is how ZAP prepares the image
\ (section 4): it starts your word instead of the ok prompt.


\ =============================================================================
\ 2. ZAP in practice
\ =============================================================================
\
\ A word to freeze -- anything that runs from start to end by itself:

: HELLO-ZAP ( -- )
    CR ." Hello from a standalone vForth image." CR
    ." Press a key to go back to BASIC." CR
    KEY DROP
;

\ Then, typed at the prompt:
\
\   NEEDS ZAP
\   ZAP HELLO-ZAP
\
\ ZAP parses the next word itself, as ' does: write the bare name, not
\ ' HELLO-ZAP. The name is also the base of the file names:
\
\   HELLO-ZAP-core.bin
\   HELLO-ZAP-user.bin
\   HELLO-ZAP-heap.bin       bank 16
\   HELLO-ZAP-heap1.bin      bank 17, only if HP went past 16K; and so on
\
\ It also prints, as a reminder, the BASIC SAVE commands the three parts
\ correspond to, e.g. for chomp-chomp:
\
\   SAVE "HEAP" BANK 16 TO 16
\   SAVE "CORE" CODE 25446 19524
\   SAVE "USER" CODE 53652 3692
\
\ The files go into the CURRENT directory: the one vForth was started from,
\ not the one your source lives in (the PATH GOTCHA of tutorial 046).
\
\ Messages ZAP may give:
\   #67 defined after NEEDS ZAP.   the word would not be in the image
\   #14 Patching the wrong ...     COLD or ABORT are not in the state ZAP
\                                  expects (e.g. a previous ZAP was broken
\                                  off half way)
\   #41 / #47 / #42                opening, writing or closing a file failed


\ =============================================================================
\ 3. NEEDS ZAP comes last
\ =============================================================================
\
\ lib/ZAP.f opens with  MARKER NO-ZAP . ZAP does not save the dictionary as
\ it is now: it saves the one NO-ZAP would give back -- the dictionary just
\ before NEEDS ZAP, with its DP, HP, LATEST and vocabularies. ZAP itself is
\ therefore left out of the deliverable (about 0.9 KB of code space and some
\ heap), and so is anything defined after NEEDS ZAP. So:
\
\   INCLUDE demo/chomp-chomp.f      \ the whole program first
\   NEEDS ZAP                       \ then ZAP, last
\   ZAP GAME
\
\ A word defined after NEEDS ZAP is refused with message #67, and no file
\ is written: it would not exist in the image.
\
\ The heap banks saved are counted from that same HP: the HP of the image,
\ not the live one. To try a two-bank image, push HP over 16K before
\ NEEDS ZAP (that is how the multi-bank loader was tested):
\
\   #17000 HP !   NEEDS ZAP   ZAP HELLO-ZAP     \ writes -heap1.bin too
\
\ A bank holding data that HP never reached is not seen. Save it by hand,
\ after ZAP, with its BASIC number (16-19), and load it in your loader:
\
\   19 SAVE-BANK                    \ writes HELLO-ZAP-heap3.bin
\
\ Simpler, when you can: allot the data in the heap at HP while the
\ program is being INCLUDEd, so HP covers it. chomp-chomp does that with
\ its mazes (MAZE-HA in demo/chomp-chomp.f): no extra bank, no extra line
\ in the loader.


\ =============================================================================
\ 4. How the image starts your word, and how it ends
\ =============================================================================
\
\ COLD begins with two NOOPs, left in the core on purpose (L3.asm) as a
\ slot for ZAP. While it writes the CORE file, and only then, ZAP stores:
\
\   COLD   NOOP NOOP  ->  [xt of your word] BYE
\   ERROR  ... QUIT   ->  ... BYE
\   ABORT  ... NOOP QUIT  ->  ... BYE QUIT
\
\ So the image enters at ORIGIN, runs COLD, which runs your word, then BYE;
\ and an error (ERROR, ABORT, ABORT") ends in BYE too, instead of at an ok
\ prompt nobody asked for. Right after the write the three cells get their
\ live values back: the session you are typing in is unchanged, and ZAP
\ can be repeated. Error #14 guards against a session left half patched.
\
\ While the USER file is written, WARNING is 0. In the image an error
\ therefore prints only "msg#n": MESSAGE never goes looking for the block
\ file, which a standalone program does not have. ZAP also FLUSHes first,
\ so no buffer marked for update is frozen in the image.
\
\ Two consequences to keep in mind:
\
\   - QUIT is NOT patched. A program that leaves with QUIT stops at the ok
\     prompt of the standalone, with no block file and WARNING at 0 --
\     handy to look around (HP@ U., variables...), but not what a player
\     expects. Leave with ABORT (or simply return) to go back to BASIC.
\     chomp-chomp uses ABORT on BREAK, and says in its source when QUIT
\     is the better choice.
\   - A standalone program has no block file: BLOCK, LOAD and LIST cannot
\     work in it. Read what the program needs from blocks while it is
\     being INCLUDEd, and keep it in memory.


\ =============================================================================
\ 5. The BASIC loader
\ =============================================================================
\
\ ZAP writes the files, not the loader. Standard-Loader.bas (in the vForth
\ directory) is the template; its listing, slightly abridged:
\
\   1110  CLEAR 25087
\   1120  PROC getfilename()
\   1150  LOAD c$ CODE 25446                core at ORIGIN
\   1160  LET r=DPEEK 25466                 R0 as the core image holds it
\   1165  LOAD d$ CODE r                    user area at R0
\   1170  LOAD h$ BANK 16                   first heap bank
\   1180  LET dp=DPEEK (r+26)               HP, from the user area
\   1185  FOR i=1 TO INT (dp/16384)
\   1190   LOAD f$+"-heap"+STR$ i+".bin" BANK 16+i
\   1195  NEXT i
\   1210  LET a=USR 25446                   enter at ORIGIN: COLD
\   1220  STOP
\   ...
\   7990  DATA "Standard-Loader"            the base name
\   ...
\   9999  RESTORE : READ f$: SAVE f$+".bas" LINE 10
\
\ No address in it depends on the build: R0 is read from the core image
\ (25466 = ORIGIN + $14), HP from the user area, and the number of heap
\ banks from HP. To make the loader of your program, from BASIC:
\
\   NEW
\   MERGE "Standard-Loader.bas"     \ MERGE: LOAD would autostart it
\   7990 DATA "HELLO-ZAP"           \ the name you gave ZAP
\   GO TO 9999                      \ saves HELLO-ZAP.bas, LINE 10
\
\ Put HELLO-ZAP.bas next to the .bin files (demo/chomp-chomp/game.bas is
\ exactly this, with DATA "Game"). RUN it: the program starts, and when it
\ ends BYE comes back from the USR and line 1220 stops with "Stop" -- the
\ same report any error in the program leads to.
\ A bank saved by hand with SAVE-BANK needs a line of its own, e.g.
\   1197  LOAD f$+"-heap3.bin" BANK 19


\ =============================================================================
\ 6. ZAP": one .nex file
\ =============================================================================
\
\   INCLUDE demo/chomp-chomp.f
\   NEEDS ZAP"                      \ loads ZAP too; still the last thing
\   ' GAME  ZAP" chomp-chomp.nex"
\
\ Unlike ZAP, ZAP" takes the word as an xt on the stack (hence the '), and
\ the file name runs up to the closing quote; the extension is not added
\ for you. A name over 47 characters gives error -18.
\
\ The image is prepared exactly as for ZAP (same patch of COLD, ERROR and
\ ABORT, same WARNING 0, same dictionary before NEEDS ZAP, same #67 and
\ #14), but written in the NEX format: a 512-byte header, then the 16K
\ banks 5, 2 and 0 (screen and system variables, dictionary, user area
\ and buffers) and the heap banks HP has reached (16 and up). A bank of
\ data beyond HP is added with its number before ZAP":
\
\   19 NEX-BANK  ' GAME ZAP" chomp-chomp.nex"
\
\ The .nex loader has no idea of vForth: it loads the banks and jumps to
\ the PC of the header with the SP of the header. Both point into the 16
\ bytes just below ORIGIN, which the core does not use: there ZAP" puts,
\ for the time of the write, a small stub that sets IY to the system
\ variables and jumps to ORIGIN -- a COLD start, with no address that
\ changes from build to build.
\
\ There is no BASIC program to go back to. BYE is meant to end in a soft
\ reset of the Next (NEXTREG 2,1, in the same stub). On CSpect, breaking
\ out of chomp-chomp.nex ended instead with the BASIC report
\ "4 Out of memory" (2026-11-08): harmless, but not the clean reset the
\ design aims at.
\
\ The banks are saved as the development session sees them, bank 5 (the
\ system variables and channels) included: the .nex starts with the
\ NextZXOS state of the session that made it.


\ =============================================================================
\ 7. Further reading
\ =============================================================================
\
\ lib/ZAP.f              ZAP, SAVE-BANK; the patch and the image (ZAP-PATCH,
\                         ZAP-IMAGE) shared with ZAP".
\ lib/ZAP~.f             ZAP", NEX-BANK, the .nex header and the stub.
\ Standard-Loader.bas    the loader template (section 5).
\ demo/chomp-chomp/      game.bas + the ZAP GAME files, and chomp-chomp.nex.
\ demo/chomp-chomp.f     the program; see its MAZE-HA and LOAD-MAZES for
\                         data read from blocks at INCLUDE time.
\ tutorial 042           file I/O: F_OPEN/F_WRITE/F_CLOSE, which ZAP uses.
\ tutorial 046           the PATH GOTCHA: where files are written.
\ tutorial 057           dot commands, the other way to a standalone program.

\ NEEDS TESTING  DECIMAL          \ lib/testing.f leaves BASE in HEX
\ There is nothing to test from inside a tutorial: the result of ZAP runs
\ only after a reboot through its loader. The headless emulator does the
\ round trip in emu/test_zap_standalone.py (ZAP, then the files loaded as
\ the loader would) and emu/test_zap_nex.py (ZAP", then the banks loaded
\ as the .nex loader would).
