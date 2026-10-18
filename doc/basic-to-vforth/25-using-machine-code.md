# Chapter 25 - Using Machine Code

[From NextBASIC to vForth](README.md)

Manual: Chapter 25, pp. 275-281.

## In short

This is where vForth is furthest ahead of BASIC. NextBASIC has no
assembler of its own: the manual has you translate the code by hand,
`POKE` the
bytes above a `CLEAR`, and call them with `USR`. vForth has an assembler
of its own, loaded with `NEEDS ASSEMBLER`, and a word for machine code,
`CODE`. The code goes into the dictionary like any other word, gets a
name, and is called by typing that name; it takes its arguments from
the stack and leaves its results there. `USR` itself survives as
`CALL#`, for code that is already in memory, and the calls to NextZXOS
that the manual sets up by hand are one word, `M_P3DOS`.

## What changes

**The code gets a name.** In BASIC the machine code is a range of
addresses that you choose, protect with `CLEAR` and remember. In vForth
`CODE name` starts a word whose body is machine code. Here is the
routine of the first listing in "Side by side", written as bytes:

```forth
CODE NN80  ( -- n )
    $21 C, 80 ,                 \ ld hl,80
    $E5 C,                      \ push hl
    $DD C, $E9 C,               \ jp (ix)
    SMUDGE
NN80 .                          \ => 80
```

`C,` compiles one byte, `,` two (low byte first, as the Z80 wants), and
`SMUDGE` makes the new word visible. No `CLEAR`, no address: the
dictionary finds the room, and the word stays where it is.

**Results go on the stack, not in BC.** `USR` returns BC; a `CODE` word
pushes its results on the data stack, which is the Z80 stack, and pops
its arguments from there. So the 80 above is loaded into HL and pushed,
and there may be as many arguments and results as you like. A string,
as in `USR$`, is two cells: push the address, then the length.

**Leave through `jp (ix)`, not `ret`.** A `CODE` word is not called: it
is jumped to by the interpreter, and goes back to it with `jp (ix)`.
`NEXT` in the assembler.

**Three registers belong to Forth.** BC holds the instruction pointer,
DE the return stack pointer, IX the address of the interpreter. A
`CODE` word that needs them saves them, usually with `exx`, which swaps
BC, DE and HL with their alternate set and swaps them back at the end.
IY belongs to the ROM's interrupt, as in BASIC. SP is the data stack:
use `push` and `pop` freely, but leave it balanced as the stack comment
says.

**The assembler.** `NEEDS ASSEMBLER` loads a Z80 assembler written in
Forth, about 7K of dictionary. Its mnemonics are postfix and use `|` to
mark registers: `ld e'| l|` is `ld e,l`, `pop hl|` is `pop hl`, a
literal is followed by `N,` (one byte) or `NN,` (two). It knows the
Z80N instructions of the Next too: `NEXTREG`, `MUL`, `SWAPNIB`,
`MIRRORA`, `LDIRX`, `PIXELAD` and the others of Appendix A. This one
multiplies two bytes with `MUL`:

```forth
NEEDS ASSEMBLER
CODE TIMES  ( u1 u2 -- u )
    exx
    pop hl|  ld e'| l|
    pop hl|  ld d'| l|
    mul
    push de|
    exx
    NEXT
C;
12 11 TIMES .                   \ => 132
```

`C;` ends the word, as `;` ends a colon definition. The files in `inc/`
are written as bytes, with the instruction in a comment, so that they do
not need the assembler: tutorial `027` shows both forms.

**On the BASIC side, `.asm`.** The manual does not mention it, but there
is a third-party dot command, `.asm` by taylorza (the
[NextBASIC Inline Assembler](https://taylorza.itch.io/nextbasic-inline-assembler)),
that is very handy in BASIC: the assembly is written with the BASIC
editor itself, in program lines that start with `;`, right after the
line that runs `.asm`. The code is assembled at `$C000` unless told
otherwise, above a `CLEAR`, and called with `USR` as usual. It is the
nearest thing BASIC has to `CODE`; in vForth the assembler is a word
away, and the code gets a name.

**`USR` is `CALL#`.** For code that is already in memory, written by
someone else or loaded from a file, `CALL# ( n1 a -- n2 )` does what
`USR` does: it puts `n1` into BC (and its low byte into A), calls the
address with an ordinary `call`, so the code ends with `ret`, and gives
back BC. It saves and restores the registers of Forth itself.

```forth
NEEDS CALL#
DECIMAL
CREATE MC  1 C, 80 C, 0 C, $C9 C,     \ ld bc,80 : ret
0 MC CALL# .                    \ => 80
```

These are the four bytes of the listing, unchanged; the 0 stands for the
parameter that `USR` does not have. `USR` with more parameters, which
BASIC leaves on the calculator stack, has no counterpart: give a `CODE`
word as many as it needs on the data stack.

**`BANK n USR` is `MMU7!` and `CALL#`.** Code kept in a page of your own
([Chapter 23](23-the-memory.md)) runs once the page is in the window at
`$E000`: map it, `CALL#` the address, put the old page back. The code
must have been written to run at `$E000`, and must not use the names of
the words while it runs, since their page is out of the window.

**Saving the code.** `SAVE "name" CODE a,n` and the loader that runs it
become, in vForth, simply the source file: `INCLUDE` or `NEEDS`
compiles the `CODE` words again, in a moment. `SAVE-BYTES` and
`LOAD-BYTES` ([Chapter 19](19-nextzxos-and-alternatives.md)) save and
load bytes, if you need to; and for a program that starts by itself,
`ZAP` freezes the whole running vForth into one file (tutorial `059`).

**Calling NextZXOS is one word.** The manual's example switches ROM and
RAM, moves the stack below `$BFE0`, calls the DOS, and puts everything
back, in a page of assembly. In vForth `M_P3DOS` does all that:

    n1 n2 n3 n4 a M_P3DOS ( -- n5 n6 n7 n8 f )

`n1` to `n4` go into HL, DE, BC and A, `a` is the address of the entry
in the jump table; on return the four registers come back in the same
order, and `f` is 0 when NextZXOS reports success, 1 when it reports an
error. `NEW-PAGE` and `FREE-PAGE` in [Chapter 23](23-the-memory.md) are
two examples. The common calls are words already: `F_OPEN`, `F_READ`,
`F_WRITE`, `F_SEEK`, `F_CLOSE`, `IDE_RTC`, `M_GETDATE`
([Chapter 19](19-nextzxos-and-alternatives.md) and
[Chapter 20](20-channels-streams-drivers-and-windows.md)), and the
catalogue of the example is `DIR`.

**Interrupts.** The manual's warnings about the I register and the
stack during paging are for an interrupt routine written by hand. `NEEDS
INTERRUPTS` sets one up for you and lets you write it in Forth
([Chapter 22](22-in-out-and-the-next-registers.md)).

## Correspondence table

| NextBASIC | vForth | Note |
|---|---|---|
| an assembler (Zeus, Odin, SPED, the `.asm` dot command) | `NEEDS ASSEMBLER` | Inside vForth, compiles into the dictionary. |
| `CLEAR n` to make room | -- | `CODE` takes the room in the dictionary. |
| `DATA` and `POKE` of the bytes | `CODE name ... C, ... SMUDGE` | Or the bytes in a `CREATE` table for `CALL#`. |
| `USR a` | `n a CALL#` | BC in, BC out; the code ends with `ret`. |
| `USR (a,p)` | `p a CALL#` | One parameter. |
| `USR (a,p1,p2,...)` | a `CODE` word | Arguments on the data stack. |
| `USR$ a` | a `CODE` word leaving `a n` | |
| `BANK n USR o` | `MMU7!` then `CALL#` | Code written to run at `$E000`. |
| `ret` | `jp (ix)`, `NEXT` | In a `CODE` word. |
| result in BC | `push` on the data stack | |
| `SAVE "n" CODE a,l` | the source file; `SAVE-BYTES` | `NEEDS SAVE-BYTES`. |
| `LOAD "n" CODE a,l` | `INCLUDE`; `LOAD-BYTES` | `NEEDS LOAD-BYTES`. |
| `SAVE "loader" LINE 10` | `ZAP` | Tutorial `059`. |
| calling NextZXOS, changing ROM and RAM | `M_P3DOS` | Does the switching itself. |
| `DOS_CATALOG` | `DIR` | |
| interrupt routine, register I | `NEEDS INTERRUPTS` | [Chapter 22](22-in-out-and-the-next-registers.md). |
| Z80N instructions | the assembler, or bytes with `C,` | `MUL`, `NEXTREG`, `LDIRX`... |

## Side by side

**A routine, the BASIC way and the Forth way.** Four bytes put above
RAMTOP, just below the user-defined graphics, and called.

```
10 CLEAR USR "A"-81
20 LET addr=USR "A"-80
30 FOR N=0 TO 3: READ byte: POKE addr+N,byte: NEXT N
40 PRINT USR addr
50 DATA 1,80,0,$C9
```

There is no address written in the listing: it is worked out from
`USR "A"`, the address of the pattern of the first user-defined graphic
([Chapter 13](13-the-character-set.md)). The 21 patterns, 168 bytes, sit
at the very top of memory, and the routine gets 80 bytes of its own just
under them; `CLEAR` puts RAMTOP one byte lower still, so BASIC leaves
both alone. With the graphics where the machine puts them, at `$FF58`
(65368), the first line is `CLEAR 65287` and `addr` is 65288; but point
the system variable UDG elsewhere and the same lines follow it, no
number to fix by hand.

The same bytes called with `CALL#` are `MC` above; written as a `CODE`
word they are `NN80`. The word is the usual form: it needs neither an
address nor `CALL#`.

**A parameter.** Double a number: the parameter arrives in BC, the
result goes back in BC.

```
10 CLEAR USR "A"-81
20 LET addr=USR "A"-80
30 FOR N=0 TO 5: READ byte: POKE addr+N,byte: NEXT N
40 PRINT USR (addr,21)
50 DATA $60,$69,$29,$44,$4D,$C9
```

```forth
NEEDS CALL#
DECIMAL
CREATE TW
    $60 C,                      \ ld h,b
    $69 C,                      \ ld l,c
    $29 C,                      \ add hl,hl
    $44 C,                      \ ld b,h
    $4D C,                      \ ld c,l
    $C9 C,                      \ ret
21 TW CALL# .                   \ => 42
CODE TWICE  ( n -- 2n )
    $E1 C,                      \ pop hl
    $29 C,                      \ add hl,hl
    $E5 C,                      \ push hl
    $DD C, $E9 C,               \ jp (ix)
    SMUDGE
21 TWICE .                      \ => 42
```

The same six bytes, in the same order, as in the `DATA` line: they move
the number from BC to HL and back. `TWICE` has nothing to move: the
number is already on the stack, and so is the result.

**A Z80N instruction.** `MUL` multiplies D by E; the two bytes arrive
packed in one parameter.

```
10 CLEAR USR "A"-81
20 LET addr=USR "A"-80
30 FOR N=0 TO 6: READ byte: POKE addr+N,byte: NEXT N
40 PRINT USR (addr,$0C0B)
50 DATA $50,$59,$ED,$30,$42,$4B,$C9
```

In hex the packing shows: `$0C0B` is 12 in B and 11 in C. The bytes are
`ld d,b` (`$50`), `ld e,c` (`$59`), `mul d,e` (`$ED $30`), `ld b,d`
(`$42`), `ld c,e` (`$4B`), `ret` (`$C9`). In Forth it is `TIMES` above, which takes the two numbers as two
arguments, written with mnemonics instead of numbers.

## No equivalent

- **Calculator parameters.** `USR` with more than one parameter leaves
  them on BASIC's calculator stack; vForth has no calculator stack to
  read from, and does not need one.
- **The type flags of `USR`.** The zero and carry flags that tell a
  routine whether it got and must return a number or a string: in vForth
  the stack comment of the word says it.
- **The external assemblers.** Zeus, Odin, SPED and the `.asm` dot
  command are not needed; code they produce can still be loaded with
  `LOAD-BYTES` and called with `CALL#`.

## Further reading

- Tutorial `027` -- the assembler, `CODE`, `C;`, the register map.
- Tutorial `073` -- `CALL#`, a ROM routine with more registers, `M_P3DOS`.
- Tutorial `057` -- dot commands.
- Tutorial `059` -- `ZAP`, a program that starts by itself.
- Tutorial `049` -- interrupts.
- `HELP CODE`, `HELP CALL#`, `HELP M_P3DOS`.
- The vForth manual, section 3.9 -- the assembler.
- [NextBASIC Inline Assembler](https://taylorza.itch.io/nextbasic-inline-assembler)
  -- the `.asm` dot command, for assembly inside a NextBASIC program.

<!-- nav -->
---

Previous: [Chapter 24 - The System Variables](24-the-system-variables.md) |
[Contents](README.md) |
Next: [Appendix A - Character Set, Z80N Mnemonics and Control Codes](app-a-character-set-z80n-control-codes.md)
