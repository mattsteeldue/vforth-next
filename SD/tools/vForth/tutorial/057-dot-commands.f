\
\ 057-dot-commands.f
\ Building standalone NextZXOS ".dot" commands with vForth's ASSEMBLER.
\
\ A dot command is a tiny machine-code program the NextZXOS shell loads
\ from C:/DOT/ and runs on its own -- vForth is not present at run time.
\ This tutorial shows how to use vForth itself (its ASSEMBLER vocabulary
\ and file words) as a cross-development tool to WRITE, TEST and SAVE
\ such a program, entirely from the interactive session.
\
\ Four worked demos already exist in demo/*.dot.f (helloworld, echo,
\ parser, savebank).  This tutorial extracts and explains the technique
\ they share, using the simplest of them (helloworld.dot.f) as the
\ running example, and points to the other three for further reading.
\
\ vForth-specific notes:
\   - A dot command runs at a FIXED origin ($2000), but the CODE word
\     that builds it compiles wherever HERE happens to be right now in
\     the live dictionary.  Any address embedded in the code (a jump
\     target, the address of an embedded string) must be translated
\     from "wherever it is now" to "where it will actually run".  This
\     is the DOT-RELATIVE technique (section 3).
\   - An ordinary CODE word ends in NEXT (jp (ix)) to hand control back
\     to the vForth inner interpreter.  A dot command is invoked by a
\     genuine Z80 CALL from NextZXOS and must end in a genuine RET.
\     These are two different, non-interchangeable calling conventions
\     (section 2) -- picking the wrong one is a silent crash, not an
\     error message.
\   - demo/helloworld.dot.f defines a RELEASE flag and a RETURN word
\     meant to let the very same CODE word serve double duty (tested
\     interactively with NEXT, saved for release with RET), but its
\     own print loop does not actually use RETURN -- see the gotcha in
\     section 11 before copying that file verbatim.
\
\ Starting FORTH (Brodie): no Brodie counterpart (vForth/NextZXOS
\ extension) -- Brodie predates the ZX Spectrum Next by decades.
\ Reference: sec.3.11 (ASSEMBLER vocabulary); sec.9 covers the file
\ words PAD"/SAVE-BYTES/UNLINK used here (see also tutorial 042).
\ Authoritative source for the dot-command ABI itself: NextZXOS and
\ esxDOS APIs manual, "Dot commands" (doc/NextZXOS_and_esxDOS_APIs.md,
\ printed page 31).
\
\ Prerequisite: tutorial 027 (ASSEMBLER vocabulary basics: HERE, NEXT,
\ HOLDPLACE, BACK,, DISP,, AA,, N,, NN,, C;, the vForth register map).
\ This tutorial assumes that one has already been read.
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   057 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 057 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 057: dot commands loaded. ) CR
.(     Type NEWTASK to unload.           ) CR

NEEDS ASSEMBLER
NEEDS UNLINK
NEEDS SAVE-BYTES
NEEDS PAD"
NEEDS LOAD-BYTES

\ =============================================================================
\ 1. What is a dot command?
\ =============================================================================
\
\ NextZXOS runs a dot command (".mydot") by loading it from C:/DOT/ into
\ DivMMC RAM at a FIXED origin, $2000, and jumping to it.  The contract:
\
\   - Maximum size 8K (only the first 8K of a bigger file is loaded).
\   - On ENTRY:  HL = address of the arguments after the command name
\                     (0 if there were none)
\                BC = address of the whole command line (including the
\                     name, excluding the leading ".")
\   - Arguments/command line end at $00, CR ($0D), or ':' outside a
\     quoted string.
\   - On EXIT:   carry CLEAR  = success
\                carry SET, A = error code       -- standard esxDOS error
\                carry SET, A = 0, HL = message   -- custom error text,
\                     last character with bit 7 set
\
\ Nothing about vForth is present once the dot command is running: no
\ dictionary, no stacks, no NEXT.  It is a plain Z80 subroutine, called
\ once by the OS and returning once, in the same 8K window regardless of
\ where it happened to be assembled inside vForth's own dictionary.


\ =============================================================================
\ 2. Two calling conventions: NEXT vs RET
\ =============================================================================
\
\ Tutorial 027 already showed SP doubles as the Forth CALCULATION stack:
\ push/pop inside a CODE word read and write the SAME stack the language
\ sees.  This has a sharp consequence.  EXECUTE ( xt -- ), the word that
\ makes the interpreter run an arbitrary word, is compiled as nothing but
\   RET
\ (see project/vForth18_DOES/source/L0.asm).  The xt sitting on top of
\ the stack IS the "return address" that RET pops into PC.  Every word
\ typed at the prompt, and every CODE word threaded inside a colon
\ definition, is reached this same way (directly, or via this trick), so
\ every ordinary CODE word must terminate with
\   NEXT   ( jp (ix) )
\ to continue the interpreter's own thread -- NOT with RET.  A stray RET
\ there pops whatever data happens to be on top of the stack and jumps to
\ it: a silent, hard-to-diagnose crash, not a clean error.
\
\ A dot command's entry point is different: NextZXOS reaches $2000 via a
\ genuine hardware CALL (there is no vForth interpreter to hand control
\ back to), so it must end with a genuine RET, carrying the exit-carry
\ protocol from section 1.  Internally, a dot command's own subroutines
\ may freely use CALL/RET to talk to each other exactly like any Z80
\ program -- CALL pushes the return address on SP and the callee's RET
\ pops it back, a perfectly ordinary, self-balanced pair.  This is legal
\ specifically because at that point SP is no longer doing double duty
\ as the live Forth stack: NextZXOS gave the dot command its own 8K
\ window and (per the esxDOS manual) permits relocating SP inside it.
\
\ Rule of thumb for this tutorial:
\   - a word you want to type at the vForth prompt          -> NEXT
\   - a routine that is (or is called by) the dot command   -> RET


\ =============================================================================
\ 3. The relocation problem: ORG and DOT-RELATIVE
\ =============================================================================
\
\ The CODE word you are about to write compiles at whatever HERE happens
\ to be right now.  Once saved and reloaded as a dot command, the exact
\ same bytes will run at $2000.  Anything coded as a JR (a relative
\ displacement) survives the move unchanged.  Anything that embeds an
\ ABSOLUTE address -- a CALL/JP target, the address of a string placed
\ right after the code -- does NOT: it must be translated from
\ "wherever it is now" to "where it will be at $2000".
\
\ ORG remembers the address HERE had when this CODE word started:

VARIABLE ORG

\ DOT-RELATIVE ( a1 -- a2 )  translates an address computed against the
\ CURRENT dictionary position into the equivalent address relative to
\ $2000, i.e. as if this whole block had been assembled starting there:
\
\   a2 = (a1 - ORG) + $2000

: DOT-RELATIVE ( a1 -- a2 )
    ORG @ -  $2000 +
;

\ REL-AA, / REL-NN, apply DOT-RELATIVE and then the matching commaer
\ (AA, for a memory address operand, NN, for an immediate word value --
\ see lib/assembler.f's own glossary comment for that distinction):

: REL-AA,   DOT-RELATIVE ASSEMBLER AA, ;
: REL-NN,   DOT-RELATIVE ASSEMBLER NN, ;

\ Use REL-AA,/REL-NN, for every address that must survive relocation:
\ a CALL/JP target inside the dot command, or the address of embedded
\ data.  Plain AA,/NN, is only correct for an address that is already
\ position-independent -- practically never, inside a dot command, so
\ if in doubt, use the REL- form.  (demo/parser.dot.f is a worked example
\ of three valid ways to do this translation -- and, until 2026-07-18, of
\ what happens when a CALL skips all three; see the gotcha in section 11
\ and tutorial/CLAUDE.md section 17.)


\ =============================================================================
\ 4. Embedding data right after the code: Z" and JR HOLDPLACE
\ =============================================================================
\
\ A short constant string is cheapest placed inline, immediately after
\ the code that uses it, rather than in a separate CREATEd buffer far
\ away in the dictionary.  Three pieces make this work:
\
\   1. A JR HOLDPLACE right at the start jumps OVER the string bytes to
\      the real code (tutorial 027 section 5); HERE DISP, patches it
\      once the real code's start address is known.
\   2. ," compiles a counted-z-string (length byte + text + a trailing
\      NUL -- see root CLAUDE.md) at HERE.
\   3. Z" captures the address of the string's TEXT (HERE 1+, skipping
\      the length byte) BEFORE ," writes it, so the address is ready to
\      store away the moment the bytes exist:

: Z" ( -- a )  HERE 1+  ," ;

\ Typical use, inside a CODE ... C; block:
\
\   jr holdplace
\   Z" Hello, World!"  MSG !     \ text address saved in variable MSG
\   here disp,                  \ patch the jr from step 1
\   ... rest of the routine, using  MSG @ REL-NN,  to load HL with it


\ =============================================================================
\ 5. Why plain ' works inside CODE ... C; (unlike inside a : ... ; body)
\ =============================================================================
\
\ Root CLAUDE.md's rule about tick is: ' is not IMMEDIATE, so it parses and
\ looks up the next word at RUN TIME.  Typed at the console, or as top-level
\ code in a loaded file, that is exactly when you want it: STATE is 0
\ (interpreting), so ' runs immediately and the xt it finds lands on the
\ stack right there.  Inside a compiled colon definition STATE is 1:
\ writing ' FOO there compiles a call to ' itself, plus a separate compiled
\ call to whatever word follows next in the source -- NOT the xt of FOO.
\ That is why every earlier tutorial uses the immediate ['] inside a
\ : ... ; body instead:
\   : INSTALL  ['] FOO  HANDLER ! ;
\
\ CODE ... C; is a THIRD context, and this tutorial is the first to lean on
\ it: a CODE body is never compiled in that sense at all.  Between CODE and
\ C; vForth interprets one assembler word at a time -- HERE, ld, pop, AA,,
\ REL-AA, and the rest are each executed immediately, and each is
\ responsible for appending its own bytes (or patching an earlier one) via
\ C, as it runs.  STATE stays 0 throughout, exactly as if the whole block
\ had been typed at the prompt.  So a bare
\   call  ' PRINT AA,
\ inside a CODE body works precisely like typing it at the console: ' PRINT
\ runs right then, pushes PRINT's xt, and AA, (or REL-AA,, section 3)
\ immediately consumes it and emits the operand bytes.  ['] would be
\ pointless here -- there is no compile-time/run-time split left to bridge.
\
\ Rule of thumb: inside CODE ... C;, use plain ' (matching every demo in
\ demo/*.dot.f and sections 6-8 below); inside an ordinary : ... ; body,
\ use ['] as always.
\
\
\ =============================================================================
\ 6. Testing before you relocate: the TESTER harness
\ =============================================================================
\
\ A routine written with plain CALL/RET (no embedded addresses of its
\ own -- only register-passed arguments, like a print-a-z-string loop)
\ needs no relocation at all: it works exactly where it currently sits
\ in the dictionary.  That makes it safe to test RIGHT NOW, without
\ saving anything to disk, using a small wrapper.  This is the TESTER
\ pattern from demo/parser.dot.f and demo/savebank.dot.f:
\
\   CODE TESTER
\       push  bc|              \ save IP
\       push  de|              \ save RP
\       push  ix|              \ save NEXT-ptr
\       call  ' ROUTINE-UNDER-TEST AA,
\       pop   ix|
\       pop   de|
\       pop   bc|
\       NEXT
\   C;
\
\ Why this is safe: TESTER is an ordinary CODE word (entered and exited
\ via NEXT, section 2).  Saving BC/DE/IX first means the CALL below can
\ borrow SP for its own return address without disturbing anything the
\ rest of the system needs; ROUTINE-UNDER-TEST's own RET pops exactly
\ that address back off, landing right after the CALL.  Restoring
\ BC/DE/IX and finishing with NEXT then hands control back to the
\ interpreter exactly as any other CODE word would.
\
\ This only applies to a routine that is itself CALL/RET-shaped and
\ free of un-relocated addresses.  Section 7's PRINT routine is exactly
\ that kind of leaf routine, and is tested this way below.  An ENTRY
\ point that has already been given REL-AA,/REL-NN, addresses (section
\ 3) is NOT safely callable in place any more -- its internal addresses
\ now point at $2000-relative offsets, valid only once the file has
\ actually been relocated there.  Verifying THAT part means either
\ saving and running the real dot command, or loading the saved bytes
\ back to $2000 with LOAD-BYTES and jumping there deliberately.


\ =============================================================================
\ 7. Building the example: a leaf routine, PRINT
\ =============================================================================
\
\ PRINT takes a z-string address in HL, emits characters via RST $10
\ until the terminating NUL, and returns.  No embedded addresses, so no
\ REL- translation is needed anywhere inside it -- a genuine RET is
\ correct both here (tested in place) and later (running at $2000).
\
\ Note ANDA A ( AND A,A ) doubles as the NUL test AND, as a side effect,
\ clears the carry flag -- exactly the "success" state the dot-command
\ ABI (section 1) wants on the RET that ends the loop.

CODE PRINT  ( -- )  \ hl = z-string address in/out; not a Forth-stack word
HERE
    ld    a'|  (hl)|
    anda   a|
    retf   z|          \ NUL reached: return, carry already clear
    rst   10|
    incx  hl|
    jr    Back,
C;

.( PRINT defined. ) CR

CREATE GREETING  ," Hello, World!"

\ TESTER takes the z-string address as an ordinary stack argument, like
\ any well-behaved Forth word -- POP HL lifts it off the stack into the
\ register PRINT expects it in.

CODE TESTER  ( a -- )
    pop   hl|              \ a -- the z-string address
    push  bc|
    push  de|
    push  ix|
    call  ' PRINT AA,
    pop   ix|
    pop   de|
    pop   bc|
    NEXT
C;

.( TESTER defined. ) CR
CR .( Try:  GREETING 1+ TESTER  => Hello, World! ) CR


\ =============================================================================
\ 8. The relocatable entry point
\ =============================================================================
\
\ Now the piece that DOES need REL-AA,/REL-NN,: a self-contained CODE
\ word that will become the dot command itself.  It is entered with
\ HL/BC per section 1's ABI (both ignored here -- this demo takes no
\ arguments), prints the embedded greeting via PRINT, and returns with
\ carry clear.  Compare with demo/helloworld.dot.f: same structure,
\ VARIABLE ORG made explicit up front instead of assumed.

VARIABLE MSG

CODE .HELLO  ( -- )  \ NextZXOS ABI: hl = args, bc = cmdline; exit via carry
HERE  ORG !
    jr    holdplace

    Z" Hello, World!"  MSG !
    here disp,

    ldx   hl|  MSG @ REL-NN,
    call  ' PRINT REL-AA,
    ret                        \ carry already clear from PRINT's ANDA A
C;

.( .HELLO defined. ) CR

\ .HELLO is NOT safely callable interactively any more: its CALL target
\ was written with REL-AA, (a $2000-relative address), which is only
\ correct once the file truly sits at $2000.  Verifying it means saving
\ it and running it as a real dot command (section 10), or loading the
\ saved bytes back to $2000 with LOAD-BYTES and jumping there.


\ =============================================================================
\ 9. The exit-carry protocol, explicitly
\ =============================================================================
\
\ .HELLO's final "ret" relies on ANDA A inside PRINT having left carry
\ clear.  That is fine for a routine that always succeeds, but do not
\ leave success/failure to a borrowed side effect once real error
\ conditions exist.  Report them explicitly, per section 1:
\
\   success:        ASSEMBLER  ora a| ret          \ or: just "ret"
\                    after any instruction that is known to clear carry
\   esxDOS error:    ASSEMBLER  scf   ldn a'| <code> N,  ret
\   custom message:  ASSEMBLER  scf   xora a|  ldx hl| <msg> REL-NN, ret
\                    ( last byte of <msg> must have bit 7 set )
\
\ demo/savebank.dot.f's BAILOUT/CLOSE-BAILOUT/WRONGINTERVAL routines are
\ worked examples of the first two forms.


\ =============================================================================
\ 10. Saving it to C:/DOT/
\ =============================================================================
\
\ Three words, already NEEDS-loaded at the top of this file, do the
\ actual work:
\
\   UNLINK <name>    remove any old copy first (SAVE-BYTES refuses to
\                     overwrite an existing file) -- safe to run even if
\                     nothing exists yet: it only reports an error.
\   PAD" <name>"      hold the filename in PAD (note the leading space:
\                     it is required, but is not part of the filename).
\   <a> <n> SAVE-BYTES   write n bytes starting at a to that filename.
\
\ ORG @ HERE OVER -  computes exactly (start-address, length) from the
\ ORG variable section 3 set at the top of .HELLO's CODE block:

.( About to write C:/DOT/HELLO -- CR then run the two lines below. ) CR
CR .(   UNLINK c:/dot/hello ) CR
CR .(   PAD" c:/dot/hello"  ORG @ HERE OVER -  SAVE-BYTES ) CR
CR .( (left commented out here so loading this tutorial has no ) CR
CR ."  side effect on your SD card -- run them yourself)." CR

\ UNLINK c:/dot/hello
\ PAD" c:/dot/hello"  ORG @ HERE OVER -  SAVE-BYTES

\ Once saved, run it from NextBASIC or the Next's file browser as
\ .hello -- it prints "Hello, World!" and returns to BASIC.  This last
\ step (does the SAVED FILE actually work when NextZXOS loads it at
\ $2000 and calls it cold) can only be confirmed on CSpect or real
\ hardware; it cannot be checked from inside this vForth session.


\ =============================================================================
\ 11. Known gotchas
\ =============================================================================
\
\ - demo/helloworld.dot.f defines a VARIABLE RELEASE and a RETURN word
\   ( RELEASE @ IF ASSEMBLER RET ELSE ASSEMBLER NEXT THEN ) meant to let
\   one CODE word serve as both an ordinary Forth word under test
\   (RELEASE false -> NEXT) and the final relocated dot command
\   (RELEASE true -> RET).  VARIABLE RELEASE defaults to 0 (test in
\   place); set it to 1 before the final save.  One thing to know
\   before reusing the idea as-is: the file's own print loop ends with
\   a plain "retf z|" (a genuine conditional RET), not with RETURN, so
\   RELEASE's NEXT branch is not actually exercised by that loop -- its
\   only exit is a mid-loop conditional return, correct as a real RET
\   in both modes (tested via TESTER, section 6, or released as-is).
\   RETURN is there for a routine whose FINAL, unconditional exit needs
\   to differ between the two modes; this tutorial's own PRINT/.HELLO
\   split follows demo/savebank.dot.f's simpler convention instead: a
\   routine is written once, for RET, and tested via TESTER rather than
\   by toggling its terminator.
\ - demo/parser.dot.f previously had two un-relocated CALLs (MAIN's
\   "call ' PARSE AA," and HELP's "call ' PRINT AA," used the plain,
\   untranslated form) -- fixed 2026-07-18. The file also turned out to
\   use THREE different, equally valid mechanisms to translate an address
\   for $2000: the REL-AA,/REL-NN, shorthand, a manual "dot-relative ...
\   AA,", and a direct post-hoc patch into dictionary memory. Each
\   relocation point in the file now carries a comment naming which one it
\   uses, plus one at TESTER's own "call ' main AA," explaining why plain
\   AA, is *correct* there (TESTER calls MAIN in place, before relocation
\   -- section 6). Full write-up, including why interactive testing via
\   TESTER never caught the bug: tutorial/CLAUDE.md section 17.
\ - Maximum size is 8K; NextZXOS loads only the first 8K of a bigger
\   file (see "Large dot commands" in the esxDOS manual for the
\   technique to load more afterwards).
\ - The stack may be relocated inside the 8K area, EXCEPT while calling
\   an external ROM routine via RST $10/RST $18 (or the +3DOS M_P3DOS
\   hook) -- those expect the ROM's own stack conventions.


\ =============================================================================
\ 12. Further reading
\ =============================================================================
\
\ demo/helloworld.dot.f  the minimal single-CODE-word dot command (the
\                        basis for this tutorial's .HELLO).
\ demo/echo.dot.f        a second minimal example; echoes the argument
\                        text back via RST $10, one character at a time.
\ demo/parser.dot.f      a small recursive-descent parser for a BASIC
\                        command line, with an embedded HELP message
\                        shown when HL = 0 (no arguments) -- see the
\                        gotcha above before copying its CALLs.
\ demo/savebank.dot.f    the most complete example: parses "n,m,file"
\                        arguments (PARSEINT/PARSECHAR/SKIPBLANKS),
\                        saves MMU7 8K pages #16.. to an SD file, and
\                        reports both esxDOS and custom errors on exit
\                        -- read this one once the pattern above feels
\                        comfortable.

\ NEEDS TESTING
\ T{  GREETING 1+ TESTER  ->  }T   \ prints "Hello, World!", no stack effect
