# Chapter 15 - Colours

[From NextBASIC to vForth](README.md)

Manual: Chapter 15, pp. 95-112.

## In short

Most of this chapter describes the machine, not the language: attribute
cells, the 512 colours, palettes, layers, the video memory. All of that is
the same for a Forth program, and the manual is the place to read it. What
changes is how you give the orders. The colour statements become words
with a dot in front (`.INK`, `.PAPER`, `.BORDER`, ...), loaded with
`NEEDS`. `LAYER m,n` becomes one word per mode. `PALETTE` and the other
compound commands have no words of their own: they become writes to the
Next registers with `REG!`, which is what BASIC does underneath. `ATTR`
is a `C@` in the attribute area.

## What changes

**Colour words have a dot.** `INK 2` is `2 .INK`, and likewise `.PAPER`,
`.BRIGHT`, `.FLASH`, `.INVERSE`, `.OVER` and `.BORDER`, each loaded with
`NEEDS` and its own name. The dot is not decoration. `OVER` without it is
a Forth word you already know: it copies the second number on the stack.
BASIC's `OVER 1` is `1 .OVER`.

```forth
NEEDS .OVER
NEEDS .BORDER
1 .OVER  0 .OVER
1 .BORDER
```

**There is no statement form and no item form.** In BASIC `INK 2` on its
own changes the colours for good, and `PRINT INK 2;"x"` only until the
end of that `PRINT`. vForth has no statements and no `PRINT`, so neither
form exists as such. `.INK` and its relatives send the control codes of
[Chapter 13](13-the-character-set.md) to the ROM, which records them as
its *temporary* colours: they apply from there on, to everything printed
after them, until you change them. `.PERM` (`NEEDS .PERM`) copies them
into the permanent colours, the ones the ROM goes back to, for instance
after `CLS`. So `6 .PAPER ." x"` is `PRINT PAPER 6;"x"`, and
`6 .PAPER .PERM` is the statement `PAPER 6`.

<!-- no-test -->
```forth
NEEDS .INK
NEEDS .PAPER
NEEDS .PERM
1 .INK 6 .PAPER .PERM CLS
```

**The words keep the arguments in range, the codes do not.** `.INK` and
`.PAPER` pass their argument through `ATTRIB-MASK`, which keeps three bits
on the layers with attributes and all eight on LoRes and Layer 2.
`.BRIGHT`, `.FLASH`, `.INVERSE` and `.OVER` keep one bit. This protects
you from the `K Invalid colour` that a wrong control code raises (and
that ends in BASIC, as Chapter 13 explains). It also means that BASIC's
special values do not get through: `9 .INK` is `1 .INK`, blue, not the
contrasting ink, and `8 .BRIGHT` is `0 .BRIGHT`. For 8 (transparent) and
9 (contrast), send the code and its argument yourself:

<!-- no-test -->
```forth
16 EMITC 9 EMITC                \ INK 9
17 EMITC 8 EMITC                \ PAPER 8
19 EMITC 8 EMITC                \ BRIGHT 8
```

**One word per layer.** BASIC's `LAYER m,n` becomes `LAYER0`, `LAYER10`,
`LAYER11`, `LAYER12`, `LAYER13` and `LAYER2`, each loaded with `NEEDS`
and its own name. They change the mode and set the character width that
suits it. `LAYER12` (Timex HiRes, 64 columns) is the mode vForth starts
in and normally works in: a program that changes layer should go back
to it before it returns to the prompt. It is the default because its 512
pixels give 64 columns natively, with characters of the ordinary width
(`LAYER12` sends `WIDECHAR`, 8 pixels). The modes 256 pixels wide reach
the same 64 columns only with narrow characters: `LAYER11`, `LAYER13`
and `LAYER2` send `NARROWCHAR`, 4 pixels, and so does `LAYER10`. Only
`LAYER0` stays at 32 columns: Layer 0 has no narrow characters. `HELP`
goes one step further: its files may have lines of up to 80 columns, so
it prints them with characters 6 pixels wide, 85 to a row on `LAYER12`,
and sets the width back to 8 at the end. For drawing in a layer there
are the graphics libraries of Chapter 16; `LAYER22-GRAPHICS` and
`LAYER24-GRAPHICS` even reach the 320x256 and 640x256 modes of Layer 2,
which BASIC does not offer.

**`ATTR` is a fetch.** On Layer 0 the attributes are 768 bytes from `$5800`,
one per cell, row by row, 32 to a row: exactly what the manual describes.
The address of a cell is a little arithmetic, and `ATTR` a `C@` of it:

```forth
: ATTR-ADDR  ( row col -- a )  SWAP 32 * +  $5800 + ;
: ATTR  ( row col -- b )  ATTR-ADDR C@ ;
5 3 ATTR-ADDR .                 \ => 22691
```

The value has the layout of the manual: 128 for flash, 64 for bright, 8
times the paper, plus the ink. Building one is a multiplication and three
additions, or the shifts and masks of [Chapter 6](06-expressions.md):

```forth
: ATTR-BYTE  ( flash bright paper ink -- b )
    SWAP 8 * +  SWAP 64 * +  SWAP 128 * + ;
1 0 6 1 ATTR-BYTE .             \ => 177
```

The name is not `ATTRIB` on purpose: that one belongs to the graphics
library of [Chapter 16](16-graphics.md), where it holds the colour
the drawing words use.

And `b row col ATTR-ADDR C!` colours a cell without printing anything in
it, faster than any `PRINT AT`.

**`PALETTE` is a handful of Next registers.** NextBASIC's palette commands
write the registers that the manual lists in Chapter 22, and in vForth
you write them yourself with `REG! ( b n -- )`:

| Register | What it does | NextBASIC |
|---|---|---|
| `$40` | index of the palette entry to write | the index in `LAYER PALETTE` |
| `$41` | colour of that entry, 8 bits (RRRGGGBB) | `LAYER PALETTE` with `PALETTE DIM 8` |
| `$44` | the same, 9 bits, in two writes | `LAYER PALETTE` with 9 bits |
| `$43` | which palette is written, which are shown | `LAYER PALETTE n` |
| `$42` | number of inks of the EnhancedULA | `PALETTE FORMAT` |
| `$14` | the transparent colour | `PALETTE OVER` |

A colour of the manual's tables, three bits each of red, green and blue,
fits the 8-bit format by dropping the lowest blue bit:

```forth
: RGB8  ( r g b -- c )  2/  SWAP 2 LSHIFT OR  SWAP 5 LSHIFT OR ;
7 3 0 RGB8 .                    \ => 236
```

That is an orange: red 7, green 3, blue 0. With the 9-bit format the blue
bit that `2/` dropped goes in the second byte written to `$44`.

**vForth changes its own blue.** The start-up colours, yellow on blue,
are not quite the standard ones. Screen 11 and `lib/autoexec.f` rewrite
two entries of the ULA palette before the banner appears: entry 25, the
blue of the paper, becomes a darker blue, since the standard one is too
light for the author's taste, and entry 14, the yellow of the ink, a
lighter yellow. In the terms of the table above:

<!-- no-test -->
```forth
0 $43 REG!                      \ write the first ULA palette
25 $40 REG!  %00000001 $41 REG! \ entry 25: a darker blue
14 $40 REG!  %11111001 $41 REG! \ entry 14: a lighter yellow
17 EMITC 1 EMITC                \ PAPER 1
```

It is a matter of taste, and both places are yours to edit: remove the
lines to keep the palette of NextZXOS, or choose other colours. They are
in both places on purpose: a change of layer may change the colours,
and `11 LOAD` puts the dark blue paper back at any time.

**`LAYER OVER` is three bits of register `$15`.** The eight orders of the
manual are the values 0 to 7 in bits 4 to 2 of the register, in the same
order. The other bits switch the sprites on and must be left alone:

<!-- no-test -->
```forth
: LAYER-OVER  ( n -- )
    2 LSHIFT  $15 REG@ %11100011 AND  OR  $15 REG! ;
```

**The second half of bank 5 is not at `$6000`.** The bitmap and the
attributes of Layer 0 are where BASIC has them, from `$4000`. The HiRes
and HiColour modes also use the second display file, the 8K page 11 that
BASIC reaches with `BANK 5 POKE 8192+m`, normally at `$6000`. In vForth
that address is taken by the dictionary itself: the page is reached
through the MMU7 window, `11 MMU7!` and then `$E000 m +`, and that has
its own rules ([Chapter 23](23-the-memory.md)). The `LAYER12` and
`LAYER13` libraries do it for you.

## Correspondence table

| NextBASIC | vForth | Note |
|---|---|---|
| `INK n` | `n .INK` | `NEEDS .INK`. Masked to 0-7 on attribute layers. |
| `PAPER n` | `n .PAPER` | `NEEDS .PAPER`. Same mask. |
| `BRIGHT n`, `FLASH n` | `n .BRIGHT`, `n .FLASH` | `NEEDS` each. 0 or 1 only. |
| `INVERSE n`, `OVER n` | `n .INVERSE`, `n .OVER` | `NEEDS` each. `OVER` alone is a stack word. |
| `BORDER n` | `n .BORDER` | `NEEDS .BORDER`. |
| `INK 8`, `INK 9` | `16 EMITC 8 EMITC`, `16 EMITC 9 EMITC` | `.INK` would mask them. |
| `BRIGHT 8`, `FLASH 8` | `19 EMITC 8 EMITC`, `18 EMITC 8 EMITC` | |
| `PRINT INK n;...` | `n .INK` before the printing words | Lasts until changed. |
| `INK n` as a statement | `n .INK .PERM` | `NEEDS .PERM`. |
| `CHR$ 16` ... `CHR$ 21` | `16 EMITC` ... `21 EMITC` + argument | Wrong argument: `K Invalid colour`, back to BASIC. |
| `ATTR (r,c)` | `r c ATTR` | Defined above. Layer 0. |
| `LAYER 0` | `LAYER0` | `NEEDS LAYER0`. |
| `LAYER 1,n` | `LAYER10` ... `LAYER13` | `NEEDS` each. `LAYER12` is vForth's text mode. |
| `LAYER 2` | `LAYER2` | `NEEDS LAYER2`. |
| `LAYER 2,0`, `LAYER 2,1` | bit 7 of register `$69` | |
| `LAYER OVER n` | `n LAYER-OVER` | Defined above: bits 4-2 of `$15`. |
| `LAYER PALETTE n,i,c` | `$43`, then `i $40 REG!`, then `$44` twice | |
| `PALETTE DIM 8` | write `$41` instead of `$44` | |
| `PALETTE FORMAT n` | `n $42 REG!`, bit 0 of `$43` | |
| `PALETTE OVER n` | `n $14 REG!` | |
| `BANK 5 POKE m,v` | `v $4000 m + C!` | The first 6912 bytes. |
| `BANK 5 POKE 8192+m,v` | through MMU7, page 11 | See [Chapter 23](23-the-memory.md). |

## Side by side

**The eight papers.** A column of colours down the left of the
screen, one paper on each line.

```
10 FOR c=0 TO 7
20   PAPER c: PRINT "    "
30 NEXT c
40 PAPER 7
```

<!-- no-test -->
```forth
: COLUMN  ( -- )
    8 0 DO  I .PAPER  ."     "  7 .PAPER CR  LOOP ;
```

`I` is the loop index, used directly as the colour. The `PRINT` without
a `;` goes to the next line; in Forth that is `CR`, which comes after
`7 .PAPER`, so that only the four spaces take the colour.

**An accent.** An `e` with an apostrophe printed over it.

```
10 PRINT "e";CHR$ 8;OVER 1;"'";OVER 0
```

```forth
: E-ACUTE  ( -- )  ." e" 8 EMITC  1 .OVER ." '" 0 .OVER ;
```

`8 EMITC` goes back one place, as `CHR$ 8` does; `.OVER` switches on the
XOR printing of the manual, and off again.

**Reading a colour back.** A star on yellow, and its attribute.

```
10 PRINT AT 5,3;PAPER 6;INK 1;"*"
20 PRINT AT 6,0;ATTR (5,3)
```

<!-- no-test -->
```forth
NEEDS .AT
: STAR  ( -- )
    5 3 .AT  1 .INK 6 .PAPER ." *"
    6 0 .AT  5 3 ATTR . ;
```

It prints 49: paper 6 times 8, plus ink 1.

**Changing a colour of the palette.** Red ink becomes orange, on the
standard ULA screen: entry 2 of the first ULA palette.

```
10 LAYER PALETTE 0,2,BIN 111011000
```

<!-- no-test -->
```forth
: ORANGE  ( -- )
    0 $43 REG!                  \ write the first ULA palette
    2 $40 REG!                  \ entry 2: ink 2, red
    7 3 0 RGB8 $41 REG! ;
```

Writing 0 to `$43` also selects the first palette of every layer for
display and switches the EnhancedULA off: it is the state after a reset.
In the standard ULA palette entries 0 to 7 are the inks, 8 to 15 the
bright inks, 16 to 23 the papers and 24 to 31 the bright papers; to
change the red paper write entry 18 as well.

## No equivalent

- **`LAYER CLEAR`, `PALETTE CLEAR`.** No single word puts layers and
  palettes back to their defaults. The palette can be rewritten entry by
  entry, as tutorial `056` does for Layer 2.
- **`LAYER PALETTE n BANK b,o`**, a whole palette from memory. A loop of
  `C@` and `REG!` does it.
- **Colours of the lower screen.** vForth has no lower screen.
- **`INK 8`, `INK 9` through `.INK`.** Send the control codes.
- **`ATTR` on other layers.** As in BASIC, it means something only on
  Layer 0; on the others read the pixel (Chapter 16).

## Further reading

- Tutorial `030` -- the ULA screen: `.INK`, `.PAPER`, `.BORDER`, `.AT`,
  `LAYER12`.
- Tutorial `031` -- `.INVERSE`, `.OVER` and the attribute memory.
- Tutorial `056` -- palettes: registers `$40`, `$41`, `$43`, `$44`, `$14`.
- Tutorial `040` -- `REG!` and `REG@`.
- Tutorial `052` -- the graphics libraries, one per layer.
- `HELP .INK`, `HELP .PAPER`, `HELP .PERM`, `HELP .BORDER`, `HELP .OVER`,
  `HELP LAYER12`, `HELP REG!`.
- [Chapter 22](22-in-out-and-the-next-registers.md) -- the Next registers.

<!-- nav -->
---

Previous: [Chapter 14 - More about PRINT and INPUT](14-more-about-print-and-input.md) |
[Contents](README.md) |
Next: [Chapter 16 - Graphics](16-graphics.md)
