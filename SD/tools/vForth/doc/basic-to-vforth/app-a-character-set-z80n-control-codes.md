# Appendix A - Character Set, Z80N Mnemonics and Control Codes

[From NextBASIC to vForth](README.md)

Manual: Appendix A, pp. 282-287.

## In short

The table of the manual belongs to the machine, not to BASIC, and it
holds for vForth almost line by line: vForth prints through the same
ROM routine as `PRINT`, so a code means the same thing in both. Three
columns need a word of explanation. The control codes reach the screen
only through `EMITC`, because `EMIT` filters them. The tokens are a
matter of BASIC's program lines, and Forth source has none. And the
Z80N columns are exactly the bytes that the vForth assembler writes,
with the mnemonics spelled the Forth way.

## What changes

**Reading the table.** The manual gives every code in decimal and in
hexadecimal. vForth reads both: `$41` is a hexadecimal number whatever
the current base, and `HEX` ... `DECIMAL` switches the base for a
while.

```forth
$41 EMIT                        \ => A
CHAR A HEX . DECIMAL            \ => 41
```

**`EMIT` filters, `EMITC` does not.** `EMITC` hands any code from 0 to
255 to the ROM, as `PRINT CHR$ n;` does. `EMIT` is meant for text, and
looks at the code first:

- 6 (the `PRINT` comma), 8 (back one place) and 13 (new line) pass;
- 7 rings the bell, through the ROM's `BEEP`, and prints nothing;
- 9, the TAB of ASCII, becomes 6, the comma;
- 10, the end of a line in a file from a PC, becomes 13;
- every other code below 32 is dropped, and so are their arguments;
- 32 to 143 pass: text and the block graphics;
- from 144 up the top bit is cleared, and the result goes through the
  same rules: 193 is printed as `A`, 144 becomes 16 and is dropped.

So `16 EMIT 2 EMIT` does not change the ink: both codes are dropped. A
control code is sent with `EMITC`, or with the word made for it. The
word `SENT` below says how many characters `EMIT` let through, from
`OUT`, the count of characters printed on the line, which `EMIT` keeps
and `EMITC` does not:

```forth
: SENT  ( c -- n )  0 OUT !  EMIT  OUT @ ;
16 SENT .                       \ => 0
22 SENT .                       \ => 0
144 SENT .                      \ => 0
193 SENT .                      \ => A1
```

**Codes 0 to 31.** On Layer 0, the ROM acts on 6, 8, 13 and 16 to 23,
as in 48K BASIC, and prints `?` for the others. On the other layers
the system window of NextZXOS takes over and gives most of the
remaining codes the meaning of the "SW" column
([Chapter 20](20-channels-streams-drivers-and-windows.md)). The codes
of the "UW" column belong to the user windows, which vForth does not
have. Codes 16 to 23 take one or two bytes after them, sent with
`EMITC` too; a wrong one is an error of the ROM, and that ends in
BASIC, not at the `ok` prompt: `RUN` brings vForth back.

| Code | Manual | vForth |
|---|---|---|
| 0 to 3 | font controls (SW) | `EMITC`, not on Layer 0 |
| 4, 5 | cursor to top or bottom left (SW) | `EMITC`, not on Layer 0 |
| 6 | `PRINT` comma | `6 EMITC`, `6 EMIT`, `9 EMIT` |
| 7 | scroll (SW) | `7 EMITC`; `7 EMIT` rings the bell |
| 8 | left | `8 EMITC`, `8 EMIT` |
| 9 to 11 | right, down, up (SW) | `EMITC`, not on Layer 0 |
| 12 | backspace (SW) | `12 EMITC`, not on Layer 0 |
| 13 | new line | `CR` |
| 14 | clear the window (SW) | `CLS`, which sends it on the other layers |
| 15 | wash the window (SW) | `15 EMITC`, not on Layer 0 |
| 16 to 21 | `INK`, `PAPER`, `FLASH`, `BRIGHT`, `INVERSE`, `OVER` | `.INK`, `.PAPER`, `.FLASH`, `.BRIGHT`, `.INVERSE`, `.OVER` |
| 22 | `AT` | `.AT` |
| 23 | `TAB` | `.TAB` |
| 24, 25 | `ATTR`, `POINT` (SW) | `EMITC`, not on Layer 0 |
| 26 | auto pause (SW) | `26 EMITC n EMITC` |
| 27 | fill the window (SW) | `EMITC`, not on Layer 0 |
| 28 | double width (SW) | `28 EMITC n EMITC` |
| 29 | font height (UW) | user windows only |
| 30 | font width (SW) | `WIDECHAR`, `NARROWCHAR`, or `30 EMITC n EMITC` |
| 31 | redefine the character set (SW) | `EMITC`, not on Layer 0 |

The colour words come from `inc/`, one `NEEDS` each (`NEEDS .INK`):
[Chapter 15](15-colours.md) has them, and
[Chapter 14](14-more-about-print-and-input.md) has `.AT`, `.TAB` and
the size of the characters.

**Codes 32 to 127.** ASCII, with three shapes of the Spectrum's own:
94 `^` is drawn as an arrow pointing up, 96 `` ` `` as the pound sign,
127 as the copyright sign. vForth source is plain 7-bit ASCII, so in
the source a pound sign is a backquote, or its number; what reaches the
screen is code 96, and the Next prints it as the pound sign:

```forth
5 ." Price: " 96 EMIT .         \ => Price: £5
```

On the Next the price comes out with a real pound sign before the 5; the
backquote is only how the PC shows code 96. The keyboard of vForth gives
these characters directly: the SYMBOL SHIFT keys that
BASIC turns into tokens type ASCII instead, `~` on SYMBOL+A, `|` on S,
`\` on D, `{` and `}` on F and G, `[` and `]` on Y and U, and the
copyright sign, 127, on I.

**Codes 128 to 143.** The block graphics, as in BASIC. `EMIT` lets them
through; `GRAPHICS` in [Chapter 13](13-the-character-set.md) prints all
sixteen.

**Codes 144 to 164.** The UDGs `A` to `U`, drawn from the table that the
system variable UDG points to ([Chapter 13](13-the-character-set.md)).
Only `EMITC` prints them. The manual shows NextBASIC's own tokens on
these codes, and on most of the block graphics: `TIME`, `PRIVATE`,
`PROC` and the rest are kept in that form in a BASIC program line,
while on the screen, through the ROM, the codes are graphics. 163 and
164, `SPECTRUM` and `PLAY` for 128K BASIC, are the UDGs `T` and `U`
here.

**Codes 165 to 255.** The keywords of 48K BASIC, from `RND` to `COPY`.
`EMITC` of one of them prints the whole keyword, through the ROM, as
`LIST` does:

<!-- no-test -->
```forth
165 EMITC 32 EMIT 255 EMITC     \ prints RND COPY
```

That is the ROM's way, on Layer 0. On Layer 1,1 the game
`demo/chomp-chomp/chomp-chomp.f` draws codes 165 to 169 as five more
UDGs, `V` to `Z`, from a longer table: see "More than 21 UDGs" in
[Chapter 13](13-the-character-set.md). On every layer but Layer 0 the
UDGs go on in the same way up to 255.

Forth source has no tokens: a word is typed letter by letter, and `RND`
in a vForth program is three letters, the name of a word of its own
([Chapter 10](10-random-numbers.md)).

**The Z80N columns are the assembler.** Every code is also an
instruction, and the right-hand columns give its mnemonic, alone or
after the prefix `CB` or `ED`. These are the bytes that `NEEDS
ASSEMBLER` writes into a `CODE` word
([Chapter 25](25-using-machine-code.md)); the prefix is added by the
assembler itself. The mnemonics are spelled the Forth way, one word for
each part:

| Manual | vForth assembler | Rule |
|---|---|---|
| `ld b,c` | `ld b'\| c\|` | `'\|` marks the destination, `\|` the source. |
| `ld b,N` | `ldn b'\| n N,` | `N,` compiles a byte. |
| `ld hl,NN` | `ldx hl\| nn NN,` | `NN,` compiles two bytes, low first. |
| `ld hl,(NN)` | `ldhl() a AA,` | `AA,` for an address. |
| `jr nz,DIS` | `jrf nz'\| d D,` | Flags of `jr` with `'\|`. |
| `add a,b` | `adda b\|` | The `A` of `add a,` is in the name. |
| `ex de,hl` | `exdehl` | A comma or a bracket glues the name together. |
| `bit 7,c` | `bit 7\| c\|` | |
| `in h,(c)` | `in(c) h'\|` | |

The names are written here in small letters, as vForth reads them while
`CASEON` is off; `src/Z80N-Assembler-Dictionary.txt` lists every form,
in capitals, with its Z80 mnemonic beside it. Check a form there before
using it: the table above shows the rules, not the whole set.

**The Z80N instructions.** The shaded instructions of the `ED` column
are those the Next adds to the Z80. The assembler knows all of them:

| Manual | Code | vForth assembler |
|---|---|---|
| `swapnib` | `ED 23` | `swapnib` |
| `mirror a` | `ED 24` | `mirrora` |
| `test N` | `ED 27` | `testn n N,` |
| `bsla de,b` ... `brlc de,b` | `ED 28` ... `ED 2C` | `bslade,b` `bsrade,b` `bsrlde,b` `bsrfde,b` `brlcde,b` |
| `mul d,e` | `ED 30` | `mul` |
| `add hl,a`, `add de,a`, `add bc,a` | `ED 31` ... `ED 33` | `addhl,a` `addde,a` `addbc,a` |
| `add hl,NN`, `add de,NN`, `add bc,NN` | `ED 34` ... `ED 36` | `addhl, nn NN,` `addde, nn NN,` `addbc, nn NN,` |
| `push NN` | `ED 8A` | `pushn nn LH,` |
| `outinb` | `ED 90` | `outinb` |
| `nextreg r,N` | `ED 91` | `nextreg r P, n N,` |
| `nextreg r,a` | `ED 92` | `nextrega r P,` |
| `pixeldn`, `pixelad`, `setae` | `ED 93` ... `ED 95` | `pixeldn` `pixelad` `setae` |
| `jp (c)` | `ED 98` | `jp(c)` |
| `ldix`, `ldws`, `lddx` | `ED A4`, `ED A5`, `ED AC` | `ldix` `ldws` `lddx` |
| `ldirx`, `ldpirx`, `lddrx` | `ED B4`, `ED B7`, `ED BC` | `ldirx` `ldpirx` `lddrx` |

`push NN` is the one instruction of the Z80 family that stores its
operand high byte first; `LH,` compiles it that way, so `nn` is written
as a plain number. The register of `nextreg` is compiled by `P,`, as the
port of `out (n),a` is. Three of them at work: `swapnib` swaps the
halves of a byte, `mirrora` reverses its bits, `addhl,a` adds a byte to
a cell.

```forth
NEEDS ASSEMBLER
CODE NIBS  ( b -- b2 )
    pop hl|  ld a'| l|  swapnib  ld l'| a|  push hl|
    NEXT
C;
$12 NIBS HEX . DECIMAL          \ => 21
CODE MIRROR  ( b -- b2 )
    pop hl|  ld a'| l|  mirrora  ld l'| a|  push hl|
    NEXT
C;
1 MIRROR .                      \ => 128
CODE +A  ( u b -- u2 )
    exx  pop hl|  ld a'| l|  pop hl|  addhl,a  push hl|  exx
    NEXT
C;
1000 24 +A .                    \ => 1024
```

`+A` keeps BC and DE, which belong to Forth, by working in the other
register set (`exx`); `NIBS` and `MIRROR` touch only HL and A, which are
free.

**Without the assembler.** The table is also the way to read the
`inc/` files written as bytes: `$ED C, $23 C,` is `swapnib`, and
`$ED C, $91 C, r C, n C,` is `nextreg r,n`
([Chapter 25](25-using-machine-code.md)).

## Correspondence table

| NextBASIC | vForth | Note |
|---|---|---|
| `PRINT CHR$ n;` | `n EMITC` | Any code, 0 to 255. |
| `PRINT "text"` | `." text"`, `EMIT` | `EMIT` drops most control codes. |
| `CHR$ 13` | `CR` | |
| `CHR$ 6` | `6 EMITC` | `9 EMIT` too. |
| `CHR$ 7` | `7 EMIT` | The bell. |
| `CHR$ 14` | `CLS` | |
| `CHR$ 16` ... `CHR$ 21` | `.INK` ... `.OVER` | `NEEDS .INK` and so on. |
| `CHR$ 22`, `CHR$ 23` | `.AT`, `.TAB` | `NEEDS .AT`, `NEEDS .TAB`. |
| `CHR$ 30;CHR$ n` | `WIDECHAR`, `NARROWCHAR` | Or `30 EMITC n EMITC`. |
| `CHR$ 96` | `96 EMIT` | The pound sign, a backquote in source. |
| `CHR$ 127` | `127 EMITC` | Copyright; SYMBOL+I at the keyboard. |
| `CHR$ 128` ... `CHR$ 143` | `n EMIT` | Block graphics. |
| `CHR$ 144` ... `CHR$ 164` | `n EMITC` | UDGs `A` to `U`. |
| `CHR$ 165` ... `CHR$ 255` | `n EMITC` | Prints the 48K keyword. |
| a hex code, `$41` | `$41` | Or `HEX` ... `DECIMAL`. |
| an opcode | `NEEDS ASSEMBLER` | Or the bytes with `C,`. |
| a Z80N opcode | `swapnib`, `mul`, `nextreg`, ... | The assembler adds the `ED`. |

## No equivalent

- **NextBASIC's own tokens.** The pink tokens of the manual, codes 129
  to 164, exist only in NextBASIC program lines.
- **Tokens at all.** Forth source is text, typed letter by letter.
- **The user window codes.** The "UW" column needs the windows of
  NextBASIC, which vForth does not open
  ([Chapter 20](20-channels-streams-drivers-and-windows.md)).

## Further reading

- Tutorial `031` -- screen control codes.
- Tutorial `027` -- the assembler, `CODE`, `C;`, the register map.
- Tutorial `060` -- `EMIT` against `EMITC` among the idiomatic traps.
- `src/Z80N-Assembler-Dictionary.txt` -- every mnemonic of the assembler.
- `HELP EMIT`, `HELP EMITC`, `HELP CR`, `HELP CLS`.
- [Chapter 13](13-the-character-set.md) -- characters, UDGs, fonts.
- [Chapter 14](14-more-about-print-and-input.md) -- `.AT`, `.TAB`,
  character size.
- [Chapter 15](15-colours.md) -- the colour codes.
- [Chapter 25](25-using-machine-code.md) -- `CODE` words.

<!-- nav -->
---

Previous: [Chapter 25 - Using Machine Code](25-using-machine-code.md) |
[Contents](README.md) |
Next: [Appendix B - Reference](app-b-reference.md)
