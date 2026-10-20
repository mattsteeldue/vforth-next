# Chapter 18 - Sound and Music

[From NextBASIC to vForth](README.md)

Manual: Chapter 18, pp. 144-156.

## In short

`BEEP` carries over: `NEEDS BLEEP` gives a `BEEP` that takes a duration
and a pitch in the same order as BASIC, with the duration in
milliseconds. `PLAY` carries over too: `NEEDS PLAY` loads a `PLAY` that
reads the same music strings and drives the three sound chips (AY) of
the Next, up to nine channels. Under it there is direct access to the
chips, register by register, through `NEEDS AY`, and a player of
ready-made effects and tunes that runs in the interrupt (AFX). Every
command of a `PLAY` string has a register behind it, and this chapter
says which, for the programs that write the chips themselves. Digital
audio (WAV, MOD, PT3) is reached in BASIC through dot commands, and has
no counterpart.

## What changes

**`BEEP` is loaded, and counts milliseconds.** `NEEDS BLEEP` loads
`lib/bleep.f`, which defines `BEEP ( ms pitch -- )`. The pitch is the
manual's: semitones from middle C, negative below it, 12 to the octave.
The duration is an integer, so it is given in thousandths of a second:
`BEEP .5,7` is `500 7 BEEP`.

<!-- no-test -->
```forth
NEEDS BLEEP
500 0 BEEP  500 4 BEEP  500 7 BEEP  1000 12 BEEP
```

As in BASIC, the note is made by the CPU and the program waits until it
ends. While it plays, `BEEP` slows the CPU down to 3.5 MHz, the speed the
ROM routine is timed for, and then puts back the speed it found.

**The pitch becomes a frequency.** `BEEP-PITCH ( pitch -- hz8 )` turns
the semitones into a frequency, multiplied by 8 to keep three bits of
fraction in an integer. Middle C is 261.6 Hz, the A above it 440:

```forth
NEEDS BLEEP
0 BEEP-PITCH .                  \ => 2093
9 BEEP-PITCH .                  \ => 3520
```

**No `Integer out of range`.** BASIC stops a pitch it cannot play.
`BEEP` checks nothing, and today its useful range is narrower than
BASIC's: from -27, the A at 55 Hz, to 47, the B four octaves above middle
C. Outside it the note is wrong and no error is given:

- from 48 up, the note lasts several seconds, whatever duration was asked:
  the number of cycles is computed with signed arithmetic, and from 48 the
  frequency times 8 no longer fits in a positive cell;
- above 57 the pitch folds back down, so 58 sounds like 56;
- below -27 the timing overflows and the note comes out too high.

```forth
500 47 BEEP-PITCH BLEEP-CALC DROP U.    \ => 1975
500 48 BEEP-PITCH BLEEP-CALC DROP U.    \ => 63533
58 BEEP-PITCH  56 BEEP-PITCH  = .       \ => -1
```

The first two lines show the number of cycles for half a second: 1975 at
pitch 47, right, and 63533 at pitch 48, about fifteen seconds. The fix is
in `TODO.md`; until it is made, keep tunes between -27 and 47.

**Fractions of a semitone become frequencies.** `BEEP .5,0.5`, the
quarter tone, and the natural scale with its `2.039` and `3.86`, need a
pitch that is not a whole number. In vForth give the frequency itself.
`BLEEP-CALC` and `BLEEP` are the two halves of `BEEP` that follow
`BEEP-PITCH`; put together, with the change of speed, they make a beep by
frequency:

```forth
: BEEP-HZ8  ( ms hz8 -- )
    BLEEP-CALC  SPEED@ >R  0 SPEED!  BLEEP  R> SPEED! ;
: C+  ( num den -- hz8 )  0 BEEP-PITCH -ROT */ ;
9 8 C+ .  5 4 C+ .  3 2 C+ .    \ => 2354 2616 3139
```

`C+` gives a note of the natural scale as a ratio to middle C: 9/8 is D,
5/4 is E, 3/2 is G. Ratios are what the natural scale is made of, and
`*/` computes them exactly, where BASIC needs semitones with decimals.

**The key and the speed are `VALUE`s.** The manual suggests a variable
`key` added to every pitch and a variable `crotchet` for the length of a
beat. Both are `VALUE`s in Forth, changed with `TO`. The name `KEY` is
taken: it is the word that reads the keyboard ([Chapter 14](14-more-about-print-and-input.md)).

```forth
NEEDS VALUE
0 VALUE KEY#
400 VALUE CROTCHET
: Q  ( pitch -- )  CROTCHET  SWAP KEY# +  BEEP ;
: H  ( pitch -- )  CROTCHET 2*  SWAP KEY# +  BEEP ;
```

`Q` plays a crotchet and `H` a minim, both in the current key: `7 Q` is
`BEEP crotchet,key+7`. They are used in "Side by side".

**`PLAY` is a library, and takes the strings from the stack.**
`NEEDS PLAY` loads `lib/PLAY.f`. Each string is an address and a length,
as in [Chapter 7](07-strings.md), and the number of strings comes last:
`PLAY a$,b$` is `a$ b$ 2 PLAY`, with up to nine strings for the nine
channels, three per chip. `PLAY"` plays one literal string, at the
prompt or inside a definition.

<!-- no-test -->
```forth
NEEDS PLAY
PLAY" T180O5cdefgabC"
S" O4ceg" S" O4egC" S" O3c))" 3 PLAY
```

The language is the manual's, command for command: notes, `#`, `$`, `O`,
durations and triplets, `_`, `&`, `N`, `V`, `U`, `W`, `X`, `T`, `( )`,
`! !`, `H`, `M`, `L`, `R` and `S`. `O5 c` is middle C. Like BASIC's,
`PLAY` waits until the music ends; `H` or BREAK stops it. A few
differences:

- an empty string, for a silent channel, is `PAD 0`: `S" "` does not
  give an empty text;
- the strings are read while they play, so they must stay where they
  are: in the dictionary, or in the heap only in the same 8K page (two
  `S"` typed at the prompt may not be);
- a wrong character is reported when `PLAY` reaches it, after the notes
  before it have been played;
- `Y` and `Z`, the MIDI commands, are read and ignored.

**Under `PLAY`, the chips.** `NEEDS AY` loads `lib/AY.f`, which writes
the chip's registers directly:

- `b reg AY!` writes one register (0 to 13);
- `n reg AY!!` writes a 12-bit tone period into a pair: 0 for channel A,
  2 for B, 4 for C;
- `n AYSELECT` chooses the chip (1 to 3) that the next writes go to;
- `SHH` silences the current chip; `AYSETUP` silences all three.

A register keeps its value until it is written again: the chip goes on
playing a note until you change it. So a program that writes the chips
itself takes care of the time that `PLAY` takes care of: it writes the
note, waits (`n MS`, `NEEDS MS`), writes the next.

**A note is a period, not a name.** The chip is told how long a wave
lasts, in units of 16 clock cycles at 1.75 MHz. For a frequency in Hz:

```forth
NEEDS AY
NEEDS MS
: PERIOD  ( hz -- p )  16 * >R  1750000. R> UM/MOD NIP ;
440 PERIOD .                    \ => 248
```

Written by hand, `PLAY`'s note names, its `#`, `$` and `O`, become a
table of periods that your program builds once, with `PERIOD` or with
numbers taken from tutorial `034`. `lib/PLAY.f` keeps one octave of
them and shifts it for the others.

**In register 7 a 0 switches on.** The mixer, register 7, says which
channels play a tone and which play noise. It has the bits of `PLAY`'s
`M`, the same order and the same values (1, 2, 4 for the tones of A, B,
C; 8, 16, 32 for their noise), but each bit *disables* its channel. `M7`,
the three tones, is therefore the opposite of 7:

```forth
%00111000 7 AY!                 \ M7: tones on A, B, C; no noise
```

**Every `PLAY` command has a register.**

| `PLAY` | AY register | Note |
|---|---|---|
| `c` ... `B`, `#`, `$`, `O` | 0-1, 2-3, 4-5 | Tone period of A, B, C: `p 0 AY!!`. |
| `V` | 8, 9, 10 | Volume of A, B, C, 0 to 15. |
| `U` | 8, 9, 10 | Volume 16: the channel follows the envelope. |
| `W` | 13 | Shape of the envelope; writing it restarts it. |
| `X` | 11-12 | Period of the envelope: `n 11 AY!!`. |
| `M` | 7 | Mixer, bits inverted. |
| noise | 6 | Period of the noise, 0 to 31. |
| durations, `&`, `T`, `( )` | -- | The program: `MS` between notes, `DO` ... `LOOP`. |
| `H` | 7 | `SHH`. |
| `L`, `R`, `S` | port `$FFFD` | See below. |

The eight volume effects `W0` to `W7` are eight of the chip's envelope
shapes. In the order of the manual's table they are 0 (decay then stop),
4 (attack then stop), 11 (decay then hold), 13 (attack then hold), 8
(repeated decay), 12 (repeated attack), 14 (attack-decay) and 10
(decay-attack).

**Nine channels and stereo.** `ENABLE-TURBOSOUND` turns on the second
and third chip; `n AYSELECT` then chooses which one the registers belong
to. `ENABLE-MONO` and `DISABLE-MONO` correspond to `S`, more or less.
`L` and `R` are bits 6 and 5 of the byte that `AYSELECT` writes to port
`$FFFD`; `AYSELECT` always sets both, so for one side only write the port
yourself with `P!`.

**Music while the program runs.** BASIC's `BEEP` and `PLAY` both keep the
program waiting. vForth can do better: `NEEDS AFXFRAME` loads a player
that the interrupt calls fifty times a second, while your program goes
on. It plays effects and tunes in the `.afx` format, prepared with an
editor on a PC. Tutorials `050` and `055` show how.

**The keyboard does not click.** `POKE 23609,n` sets the length of
BASIC's key click. vForth's `KEY` makes no click at all, so the variable
has no effect while Forth runs.

## Correspondence table

| NextBASIC | vForth | Note |
|---|---|---|
| `BEEP d,p` | `ms p BEEP` | `NEEDS BLEEP`. Milliseconds, whole semitones. |
| `BEEP d,p` with a fractional `p` | `ms hz8 BEEP-HZ8` | Defined above: frequency times 8. |
| pitch out of range | -- | No error: keep to -27 ... 47. |
| `key+p` | `KEY# +` | `KEY` reads the keyboard. |
| `crotchet` | `CROTCHET` | A `VALUE`, in milliseconds. |
| `POKE 23609,n` | -- | `KEY` does not click. |
| `PLAY a$` | `a n 1 PLAY`, `PLAY" ..."` | `NEEDS PLAY`. |
| `PLAY a$,b$,c$` | `a1 n1 a2 n2 a3 n3 3 PLAY` | Up to nine strings. By hand: `0`, `2`, `4 AY!!`. |
| `PLAY ""` for a silent channel | `PAD 0` | `S" "` is not empty. |
| note names, `O` | `hz PERIOD reg AY!!` | Defined above. |
| `V n` | `n 8 AY!` (A), `9` (B), `10` (C) | |
| `U`, `W n`, `X n` | volume 16, `shape 13 AY!`, `n 11 AY!!` | |
| `M n` | `n INVERT 63 AND 7 AY!` | Bits inverted. `NEEDS INVERT`. |
| durations, `T` | `n MS` between notes | `NEEDS MS`. |
| `( )` | `DO` ... `LOOP`, or a word called twice | |
| `H` | `SHH` | |
| nine channels | `ENABLE-TURBOSOUND`, `n AYSELECT` | |
| `L`, `R`, `S` | port `$FFFD`, `ENABLE-MONO` | |
| `Y`, `Z` (MIDI) | -- | `PLAY` reads them and ignores them. |
| `.wavplay32`, `.nxmod`, `.playpt3` | -- | No dot commands from vForth. |
| `.pisend` | -- | `NEEDS RPi0` talks to the Pi, but sends no files. |
| (not in BASIC) | `NEEDS AFXFRAME` | Effects played by the interrupt. |

## Side by side

**A scale.** The C major scale, one note a quarter of a second.

```
10 FOR n=1 TO 8
20   READ p: BEEP .25,p
30 NEXT n
40 DATA 0,2,4,5,7,9,11,12
```

```forth
CREATE SCALE  0 C, 2 C, 4 C, 5 C, 7 C, 9 C, 11 C, 12 C,
: MAJOR  ( -- )  8 0 DO  250  SCALE I + C@  BEEP  LOOP ;
```

The `DATA` line becomes a table of bytes ([Chapter 5](05-read-data-restore.md)),
and the loop reads it with `C@`. Type `MAJOR` to hear it.

**A tune in any key.** Two bars of *Twinkle, twinkle*, at a speed and in
a key that can be changed.

```
10 LET k=0: LET c=.4
20 FOR r=1 TO 2
30   BEEP c,k: BEEP c,k: BEEP c,k+7: BEEP c,k+7
40   BEEP c,k+9: BEEP c,k+9: BEEP 2*c,k+7
50 NEXT r
```

```forth
: TWINKLE  ( -- )  0 Q 0 Q 7 Q 7 Q 9 Q 9 Q 7 H ;
: TUNE  ( -- )  2 0 DO  TWINKLE  LOOP ;
```

`TWINKLE` names the bar, which BASIC can only repeat with a loop. To hear
it a tone higher and faster:

<!-- no-test -->
```forth
2 TO KEY#  300 TO CROTCHET  TUNE
```

**A chord.** C, E and G together, which `BEEP` cannot do.

```
10 PLAY "c","e","g"
```

<!-- no-test -->
```forth
NEEDS PLAY
S" c" S" e" S" g" 3 PLAY
```

That is the whole translation. Written out by hand, register by register,
the chord is:

```forth
: CHORD  ( -- )
    1 AYSELECT
    262 PERIOD 0 AY!!  330 PERIOD 2 AY!!  392 PERIOD 4 AY!!
    15 8 AY!  15 9 AY!  15 10 AY!
    %00111000 7 AY!
    500 MS  SHH ;
CHORD
```

Three periods, three volumes, the mixer, half a second of waiting, and
silence: what `PLAY` does with three strings is written out in full. The
waiting is the duration of the chord, and nothing stops the program
from doing something else instead of `MS`, which `PLAY` cannot do.

**A plucked note.** A note that starts loud and dies away: `PLAY`'s
`W0`.

```
10 PLAY "UX1000W0c"
```

<!-- no-test -->
```forth
NEEDS PLAY
PLAY" UX1000W0c"
```

By hand:

```forth
: PLUCK  ( -- )
    1 AYSELECT
    262 PERIOD 0 AY!!
    1000 11 AY!!                \ X1000: the envelope period
    16 8 AY!                    \ U: channel A follows the envelope
    %00111110 7 AY!             \ M1: tone on A only
    0 13 AY! ;                  \ W0: decay, then silence
PLUCK
```

The note dies by itself: the chip does it, and `PLUCK` returns at once.
Write register 13 again to pluck again.

## No equivalent

- **Durations and tempo inside the chip.** The chip holds a note until it
  is told otherwise; `PLAY`, or the program, measures the time.
- **MIDI (`Y`, `Z`).** `PLAY` reads them and ignores them.
- **Music while the program runs, from a string.** `PLAY` waits until
  the music ends, as BASIC's does; playing in the background is done
  today with AFX.
- **Digital audio.** The players of WAV, MOD and PT3 are dot commands,
  which vForth cannot launch. The DACs of the Next are reachable through
  the Next registers `$2C` to `$2E`, but there is no player.
- **`POKE 23609`.** vForth's keyboard makes no click.
- **A pitch error.** `BEEP` plays what it computes, right or wrong.

## Further reading

- Tutorial `033` -- the beeper: `BEEP`, `BLEEP`, `BLEEP-CALC`.
- Tutorial `034` -- the AY chips: registers, periods, the mixer, `AY!`.
- Tutorial `050` -- `AFXFRAME`: tunes played by the interrupt.
- Tutorial `055` -- an AFX sound board.
- Tutorial `032` -- timing: `MS` and frames.
- `HELP PLAY`, `HELP PLAY"`, `HELP BEEP`, `HELP MS`, `HELP AY!`,
  `HELP SHH`, `HELP AYSELECT`.
- `lib/PLAY.f` -- the string interpreter, and the choices it makes where
  the manual says nothing.
- [Chapter 17](17-time-and-motion.md) -- time, frames, interrupts.

<!-- nav -->
---

Previous: [Chapter 17 - Time and Motion](17-time-and-motion.md) |
[Contents](README.md) |
Next: [Chapter 19 - NextZXOS and alternatives](19-nextzxos-and-alternatives.md)
