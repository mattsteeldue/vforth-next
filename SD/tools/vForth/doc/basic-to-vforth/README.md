# From NextBASIC to vForth

A migration guide for programmers who know NextBASIC and want to move to
vForth, the Forth system for the ZX Spectrum Next.

> **Draft.** Chapters 1 to 25, Appendices A to D and the keyword index
> are written, and are being revised. Every Forth listing has been run;
> the BASIC listings are still being tried on the machine, and a few may
> need a touch. Corrections and suggestions are welcome.

## How to read this guide

The guide follows the table of contents of the *ZX Spectrum Next User Manual*,
third edition: one chapter here for each chapter there, with the same number
and title. References such as "p. 21" are page numbers of that manual's PDF.
The manual itself is not quoted: keep it open next to this guide.

The guide is not on the SD card. On the machine, tutorial 074
(`NEEDS TUTORIAL`, then `074 TUTORIAL`) gives the ten main differences in
brief, with an example each.

Every chapter is a file of its own and has the same six parts:

1. **In short** -- how much of the chapter carries over.
2. **What changes** -- where the Forth model differs from the BASIC one.
3. **Correspondence table** -- BASIC on the left, vForth on the right.
4. **Side by side** -- a few short programs in both languages.
5. **No equivalent** -- what vForth does not offer, and why.
6. **Further reading** -- tutorials, help entries, vForth manual sections.

Conventions used in the listings:

- The BASIC listings are written for this guide; they are not taken from the
  manual.
- In the Forth listings `\ => text` shows what the line prints. When the
  output takes several lines it follows the listing in a block of its own.
- `NEEDS name` loads a word that is not part of the core. Words used without
  a `NEEDS` are always available.
- Every Forth listing is typed into vForth, in an emulator, and its
  output compared with the guide, except those that wait for a key, never
  end, or need a part of the machine the emulator does not have (floating
  point, graphics, sound).
- A Forth line is carried out from left to right, but it is not always
  read that way by a human: a word takes values from its left (the stack)
  and may take a name from its right (the text that follows). `20 TO B`
  reads forwards, `' NEW IS OLD` backwards ("OLD is NEW").
  [Chapter 1](01-basic-programming-concepts.md) explains it.
- Type the Forth listings of a chapter in order: later ones may use earlier
  definitions.

## Trying the listings

The listings are on the SD card too, in the folder `bas2f` of vForth
(`tools/vForth/bas2f`), one file per listing:

- `bas2f/bas/NN-MM.bas` -- the BASIC listing MM of chapter NN, ready to `LOAD`
  from NextBASIC; `bas2f/txt/` has the same listing as plain text.
- `bas2f/f/NN-MM.f` -- its Forth side, to load from vForth with
  `INCLUDE bas2f/f/NN-MM.f`. Each file is complete: it brings with it
  the definitions from earlier in the chapter that it uses. When the
  guide gives several Forth versions of one listing they are
  `NN-MMb.f`, `NN-MMc.f` and so on.

`NN` is the chapter and `MM` the number of the listing within it.

## Chapters

A chapter without a link is not written yet.

1. [Basic Programming Concepts](01-basic-programming-concepts.md)
2. [Decisions](02-decisions.md)
3. [Looping](03-looping.md)
4. [Procedures and Subroutines](04-procedures-and-subroutines.md)
5. [READ, DATA, RESTORE](05-read-data-restore.md)
6. [Expressions](06-expressions.md)
7. [Strings](07-strings.md)
8. [Functions](08-functions.md)
9. [Mathematical Functions](09-mathematical-functions.md)
10. [Random Numbers](10-random-numbers.md)
11. [Arrays](11-arrays.md)
12. [Conditions](12-conditions.md)
13. [The Character Set](13-the-character-set.md)
14. [More about PRINT and INPUT](14-more-about-print-and-input.md)
15. [Colours](15-colours.md)
16. [Graphics](16-graphics.md)
17. [Time and Motion](17-time-and-motion.md)
18. [Sound and Music](18-sound-and-music.md)
19. [NextZXOS and alternatives](19-nextzxos-and-alternatives.md)
20. [Channels, Streams, Drivers and Windows](20-channels-streams-drivers-and-windows.md)
21. [Optional Features](21-optional-features.md)
22. [IN, OUT and the Next Registers](22-in-out-and-the-next-registers.md)
23. [The Memory](23-the-memory.md)
24. [The System Variables](24-the-system-variables.md)
25. [Using Machine Code](25-using-machine-code.md)

Appendices:

- A. [Character Set, Z80N Mnemonics and Control Codes](app-a-character-set-z80n-control-codes.md)
- B. [Reference](app-b-reference.md) -- reports, number systems
- C. [Machine Personalities](app-c-machine-personalities.md)
- D. [The Calculator](app-d-the-calculator.md)

[Keyword index](keyword-index.md): every keyword and function of NextBASIC,
alphabetically, with its vForth word and the chapter that explains it.
