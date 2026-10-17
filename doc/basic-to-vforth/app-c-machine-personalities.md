# Appendix C - Machine Personalities

[From NextBASIC to vForth](README.md)

Manual: Appendix C, pp. 297-302.

## In short

This appendix is about the machine, not about a language: updating the
core, the firmware and the System/Next distribution, choosing a
personality at power-on, and what to check when the screen stays blank.
All of it is done before vForth starts, and none of it changes because
the program that runs afterwards is written in Forth. Three points touch
vForth: it needs one of the two Next personalities, a program can read
the core version and the speed from the Next registers, and the
`OUT` sequences that open the expansion bus are `REG!` in Forth.

## What changes

**vForth runs in the Next personalities only.** vForth is a NextZXOS
program: one version is started by a NextBASIC loader, the other is the
dot command `.vforth`, and both call NextZXOS to read the block file and
the source files. The two Next entries of the personality menu, standard
and with the Looking Glass 48K ROM, boot NextZXOS and are the same for
vForth. The other personalities turn the Next into an older machine
that has no NextZXOS, and vForth is not meant for them.

**There is a vForth before the Next.** The repository
`github.com/mattsteeldue/vforth`, alongside `vforth-next`, keeps a
version of vForth back-ported to the 48K and 128K Spectrum, and the
vForth manual mentions it briefly. It does not use NextZXOS, but its
blocks need storage the plain Spectrum does not have: a Sinclair ZX
Interface 1 with ZX Microdrives, or, in the other version, a DISCiPLE
(MGT) interface with its disk drives. Without that hardware it needs an
emulator able to emulate it, such as Fuse; CSpect and MAME, the
emulators used for the Next, are not the ones for it. It is another
machine and another set of files: this guide is about the Next version.

**The configuration options are the machine's.** The upper part of the
options screen (keyboard or mouse on the PS/2 port, sound on HDMI,
stereo mode, scanlines) holds in every mode, so it holds under vForth
too: the stereo mode, for one, decides where the three channels of the
AY end up (`NEEDS AY`). The lower part is set by NextZXOS by itself, and
vForth finds it as NextZXOS left it. A program that needs a different
setting writes the Next register, as a NextBASIC program would with
`REG`.

**The core version is two registers.** The boot screen shows it, and so
does the vForth banner, the line "Core Version" of `lib/AUTOEXEC.f`.
Register 1 holds the major number in the high nibble and the minor in
the low one, register 14 the sub-minor:

```forth
: .CORE  ( -- )
    1 REG@  DUP 4 RSHIFT 0 .R  [CHAR] . EMIT
    15 AND 0 .R  [CHAR] . EMIT
    14 REG@ 0 .R ;
.CORE
```

A program that depends on a feature of a recent core can compare these
numbers and refuse to run, instead of misbehaving.

**The expansion bus is a register.** The manual opens the bus for an
external peripheral with pairs of `OUT` to ports 9275 and 9531, which
select a Next register and write it: register 136 (`$88`) is written
with 219, then register 128 (`$80`) with 128. In vForth each pair is one
`REG!`, value first:

<!-- no-test -->
```forth
219 136 REG!  128 128 REG!      \ the bus is open from now
```

The second example of the manual writes 8 into register 128, which opens
the bus only at the next soft reset, and then asks for that reset by
writing 1 into register 2. A reset ends vForth, as it ends a BASIC
program: start vForth again after it.

**An open bus slows the machine.** With the bus open the CPU runs at
3.5 MHz, whatever speed was asked for. `SPEED@`
([Chapter 22](22-in-out-and-the-next-registers.md)) gives the speed
asked for, bits 1 and 0 of register 7; the speed the CPU actually runs
at is in bits 5 and 4:

```forth
: SPEED-NOW  ( -- n )  7 REG@ 4 RSHIFT 3 AND ;
SPEED-NOW .
```

As with `SPEED!`, 0 is 3.5 MHz and 3 is 28 MHz. Close the bus when the
peripheral is no longer needed, to have the speed back.

**Updating vForth is copying files.** vForth is not part of System/Next
and no updater knows about it. A new version is a set of files on the
SD card: the folder `tools/vForth` with the binaries, the block file,
`inc/`, `lib/` and the rest, and `dot/vforth` for the dot command. They
come from the repository `github.com/mattsteeldue/vforth-next`, folder
`SD`, and are copied over the old ones. Keep a copy of `!Blocks-64.bin`
if you wrote into the block file: a new version brings a new one.

## Correspondence table

| NextBASIC | vForth | Note |
|---|---|---|
| core update, AB core, extra cores | -- | Done at power-on, outside any language. |
| firmware and System/Next update | -- | vForth is updated by copying its files. |
| choosing a personality | -- | vForth needs one of the two Next personalities. |
| version on the boot screen | `1 REG@`, `14 REG@` | `.CORE` above; also in the vForth banner. |
| `.nextver` | `DOSVER` | `NEEDS DOSVER`; the NextZXOS version. |
| `OUT 9275,n: OUT 9531,v` | `v n REG!` | Value first. |
| `REG 128,128` | `128 128 REG!` | Opens the expansion bus. |
| speed asked for | `SPEED@` | `NEEDS SPEED@`. |
| speed in use | `7 REG@ 4 RSHIFT 3 AND` | `SPEED-NOW` above. |
| 50 or 60 Hz | `5 REG@ 4 AND` | Not zero at 60 Hz; [Chapter 17](17-time-and-motion.md). |

## No equivalent

- **The other personalities**: the 48K, 128K, +2, +2A/+3, +3e, ZX80,
  ZX81, Timex, Investronica and Pentagon modes. They have no NextZXOS,
  and vForth does not run in them; the pre-Next vForth
  (`github.com/mattsteeldue/vforth`) targets the 48K and 128K Spectrum,
  but needs Interface 1 and Microdrives, or a DISCiPLE, that the Next
  does not provide.
- **Updating the core, the AB core, the extra cores and the firmware.**
  Key presses at power-on; no program takes part.
- **The NMI shortcuts and the troubleshooting.** A blank or red screen,
  the 60 Hz display, the PS/2 keyboard: the remedies are the manual's,
  whatever program runs.

## Further reading

- Tutorial `040` -- the Next registers: `REG@` and `REG!`.
- Tutorial `057` -- dot commands, the form `.vforth` takes.
- `HELP REG@`, `HELP REG!`, `HELP SPEED!`, `HELP SPEED@`.
- `lib/AUTOEXEC.f` -- the banner: core version, NextZXOS version, speed.
- [Chapter 19](19-nextzxos-and-alternatives.md) -- NextZXOS and the SD
  card.
- [Chapter 22](22-in-out-and-the-next-registers.md) -- `P!`, `REG!` and
  the speed.

<!-- nav -->
---

Previous: [Appendix B - Reference](app-b-reference.md) |
[Contents](README.md) |
Next: [Appendix D - The Calculator](app-d-the-calculator.md)
