\
\ 027-assembler.f
\ ASSEMBLER vocabulary: writing CODE words in Z80/Z80N assembly.
\
\ vForth provides the ASSEMBLER vocabulary as an alternative way to
\ write CODE definitions using readable Z80 mnemonics rather than raw
\ hex literals.  After NEEDS ASSEMBLER, the word CODE automatically
\ switches to the assembler context so mnemonics are found; C; closes
\ the definition and returns to FORTH.
\
\ Case convention inside CODE bodies (matches the documentation, sec.3.9):
\   Z80 mnemonics and register specifiers  -- lowercase
\     halt  exx  nop  pop bc|  adda (hl)|  jpf pe|  ld c'| a|  ...
\   Forth meta-words and commaers          -- UPPERCASE
\     HERE  NEXT  HOLDPLACE  BACK,  DISP,  AA,  N,  NN,  C;  ...
\
\ Two examples are developed here:
\
\   VIDEO-SYNC  ( -- )  -- wait for the next video-frame interrupt.
\       The simplest possible CODE word: one opcode and NEXT.
\
\   CHECKSUM2   ( a u -- n )  -- sum u bytes starting at address a,
\       result mod 256.  Demonstrates backward loops using HERE and
\       jpf pe| AA, and illustrates how CODE words preserve the vForth
\       register map via exx.
\
\ Starting FORTH (Brodie): no Brodie counterpart (vForth extension)
\ Reference: sec.3.9
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   027 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 027 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 027: ASSEMBLER vocabulary loaded. ) CR
.(     Type NEWTASK to unload.                   ) CR

NEEDS ASSEMBLER

CR

\ ===========================================================================
\ 1. The vForth register map
\ ===========================================================================
\
\ Inside a CODE word the Z80 registers have fixed roles:
\
\   BC   -- Instruction Pointer (IP).  Preserve it across calls.
\   DE   -- Return Stack Pointer (RP).  Same rule.
\   SP   -- Forth calculation stack (data stack).
\   IX   -- Inner-interpreter pointer: jp (ix) = NEXT, return to Forth.
\   IY   -- Reserved for ZX system interrupts.  Do not modify.
\
\ A CODE word that needs BC or DE for its own use must first call exx to
\ swap BC, DE, HL with their alternate counterparts.  The originals are
\ safely preserved in the alternate bank.  A second exx at the end
\ restores them before NEXT returns control to the interpreter.
\
\ pop rr|  reads one cell from the Forth data stack (SP goes up).
\ push rr| writes one cell to the Forth data stack (SP goes down).
\
\ NEXT  ( jp (ix) ) terminates the CODE word and continues the interpreter.


\ ===========================================================================
\ 2. Op-code notation
\ ===========================================================================
\
\ Register specifiers push a flag value at assembly time; they are Forth
\ words evaluated while the CODE body is being compiled.
\
\   r|    source register:    b| c| d| e| h| l| a| (hl)|
\   r'|   destination reg.:   b'| c'| d'| e'| h'| l'| a'| (hl)'|
\   rr|   register pair:      bc| de| hl| sp| ix| iy| af|
\   f|    flag (JP/CALL/RET): nz| z| nc| cy| po| pe| p| m|
\   f'|   flag (JR only):     nz'| z'| nc'| cy'|
\   b|    bit position:        0| 1| 2| 3| 4| 5| 6| 7|
\
\ Commaers consume a value from the Forth stack and emit bytes:
\
\   N,   emit 1-byte literal           ldn  a'| $00 N,   \ ld a, $00
\   NN,  emit 2-byte integer           ldx  bc| 100 NN,  \ ld bc, 100
\   AA,  emit 2-byte address           jpf  z|  addr AA, \ jp z, addr
\   D,   emit 1-byte displacement      jr   disp D,      \ jr disp


\ ===========================================================================
\ 3. Example 1: VIDEO-SYNC
\ ===========================================================================
\
\ On the ZX Spectrum, a maskable interrupt fires every 20 ms (50 Hz PAL).
\ halt suspends the Z80 until that interrupt arrives, then resumes.
\ Used at the start of an animation loop it locks rendering to the video
\ frame, eliminating tearing.
\
\ This is the minimal CODE word: one opcode, then NEXT.
\ No stack items are consumed or produced.
\
\ Try:
\   : FLASH-LOOP  BEGIN  VIDEO-SYNC  1 .BORDER  VIDEO-SYNC  0 .BORDER
\                        ?TERMINAL UNTIL ;
\   NEEDS .BORDER  FLASH-LOOP

CODE VIDEO-SYNC  ( -- )
    halt
    NEXT
C;

.( VIDEO-SYNC defined. ) CR


\ ===========================================================================
\ 4. Example 2: CHECKSUM2
\ ===========================================================================
\
\ Compute the checksum (sum mod 256) of u bytes starting at address a.
\
\ Register assignment (after exx):
\   HL  = a   (source address, incremented by cpi)
\   BC  = u   (counter, decremented by cpi)
\   A   = running sum (mod 256 -- byte overflow ignored)
\
\ Algorithm:
\   exx              save IP and RP into alternate register bank
\   pop  bc          u from Forth stack
\   pop  hl          a from Forth stack
\   xor  a           A = 0
\ loop:
\   add  a, (hl)     accumulate byte at HL
\   cpi              HL++, BC-- ; sets P/V when BC != 0  (loop test only)
\   jp   pe, loop    P/V set (PE) = BC not yet zero, keep looping
\   ld   c, a        move result into C (B is 0 after loop: BC decremented
\                    to 0)
\   push bc          push 16-bit result = 0*256 + checksum
\   exx              restore IP and RP
\   NEXT
\
\ Why cpi?  cpi (Compare and Increment) is a single 2-byte instruction
\ that simultaneously increments HL, decrements BC and sets P/V.  The
\ comparison result is discarded; only the side-effects are wanted.
\ It is the compact Z80 idiom for counted-loop iteration.
\
\ Backward loop pattern with HERE and AA,:
\   HERE saves the current compile address onto the Forth stack.
\   Instructions between HERE and AA, are compiled normally.
\   AA, consumes that saved address and emits it as the jump target.
\
\ Alternative using CONSTANT as a label (clearer for longer loops):
\   HERE CONSTANT LOOP-ADDR
\   ... instructions ...
\   jpf  pe|  LOOP-ADDR  AA,

CODE CHECKSUM2  ( a u -- n )
    exx
    pop   bc|
    pop   hl|
    xora   a|
HERE                        \ ( loop-addr ) -- remember loop start
    adda (hl)|
    cpi
    jpf  pe|  AA,           \ jp pe, loop-addr -- loop while BC != 0
    ld   c'|  a|
    push  bc|
    exx
    NEXT
C;

.( CHECKSUM2 defined. ) CR
.( Try: DECIMAL 448 60 CHECKSUM2 .  ) CR    \ => 67


\ ===========================================================================
\ 5. Forward jumps and BACK,
\ ===========================================================================
\
\ The backward-jump pattern (HERE + AA,) only works because the target
\ address is already known.  For forward jumps the target is ahead, so a
\ placeholder must be reserved and patched later.
\
\ HOLDPLACE  ( -- a )
\   Emit a zero displacement byte; return its address for later patching.
\
\ DISP,  ( a1 a2 -- )
\   Compute the displacement from a2 to a1; store it at a2.
\   Called as  HERE DISP,  once the branch target is reached.
\
\ Forward conditional JR -- IF-THEN pattern:
\
\   jrf  nc'| HOLDPLACE    \ jr nc, ?  (placeholder at HOLDPLACE result)
\       nop                \ ... code executed when carry is clear ...
\   HERE DISP,             \ patch: fill in the displacement  (THEN,)
\
\ Backward JR -- BACK, shorthand:
\   BACK,  is defined as  HOLDPLACE SWAP DISP,
\
\   HERE                   \ mark loop start  (*)
\       nop                \ ... loop body ...
\   jr  BACK,              \ jr back to (*)
\
\ Note: jr range is -126 to +129 bytes.  For longer distances use jp AA,.


\ ===========================================================================
\ 6. Releasing CODE words to inc/
\ ===========================================================================
\
\ The ASSEMBLER vocabulary occupies ~7 KB of dictionary space.  Once a
\ CODE word is finalised, convert each mnemonic to a raw hex literal
\ with C,.  The result needs no ASSEMBLER at runtime.
\
\ VIDEO-SYNC in release form (inc/VIDEO-SYNC.f):
\
\   CODE VIDEO-SYNC  ( -- )
\       $76 C,             \ halt
\       $DD C, $E9 C,      \ jp (ix)   -- NEXT
\       SMUDGE
\
\ The SMUDGE at the end replaces C; when ASSEMBLER is not loaded.
\ Use C; during development; use SMUDGE alone in the release inc/ file.
\
\ Opcode bytes for CHECKSUM2:
\   D9          exx
\   C1          pop  bc
\   E1          pop  hl
\   AF          xor  a
\   86          add  a, (hl)    <-- loop target
\   ED A1       cpi
\   EA lo hi    jp   pe, target
\   4F          ld   c, a
\   C5          push bc
\   D9          exx
\   DD E9       jp   (ix)       -- NEXT


\ ===========================================================================
\ 7. Quick-reference tests (uncomment to run)
\ ===========================================================================
\
\ NEEDS TESTING
\ NEEDS CHECKSUM
\
\ T{ DECIMAL 448 60 CHECKSUM2 -> 67 }T
\ T{ ' VIDEO-SYNC >BODY  HERE OVER -  CHECKSUM  -> $03 }T

