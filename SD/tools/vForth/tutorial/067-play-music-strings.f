\
\ 067-play-music-strings.f
\ NextBASIC's PLAY in vForth: music strings on the three AY chips, with
\ lib/PLAY.f.
\
\ Tutorial 034 drives the AY chips register by register: a period for
\ the pitch, a volume, the mixer, and MS for the time in between. That is
\ the whole machine, and it is a lot of writing for a tune. NextBASIC
\ hides it behind PLAY, which reads a string of notes ("cdeC") and does
\ the rest. NEEDS PLAY loads the same thing for vForth: the language of
\ the strings is the manual's (ZX Spectrum Next User Manual, Chapter 18,
\ pp. 147-153), and a tune written for BASIC plays unchanged.
\
\ vForth-specific notes:
\   - PLAY takes the strings from the stack, an address and a length
\     each, and their number last: PLAY a$,b$ is  a$ b$ 2 PLAY.
\     PLAY" plays one literal string, at the prompt or in a definition.
\   - PLAY waits until the music ends, as in BASIC. H in a string, or
\     the BREAK key, stops it.
\   - The strings are READ WHILE THEY PLAY: keep them in the dictionary
\     (CREATE name ," text") -- see section 9 for why S" at the prompt
\     is not safe with more than one string.
\   - Under PLAY the register words of tutorial 034 (lib/AY.f) are still
\     there and still work.
\
\ no Brodie counterpart (vForth extension)
\ Reference: sec.3.13 (AY sound); lib/PLAY.f header; HELP PLAY and
\            HELP PLAY"; doc/basic-to-vforth/18-sound-and-music.md.
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   067 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 067 TUTORIAL
\
\ Run it with:  DEMO   (a canon in three voices; BREAK stops it)
\

MARKER NEWTASK

CR
.( --- Tutorial 067: PLAY music strings loaded. ) CR
.(     Type NEWTASK to unload.               ) CR

NEEDS PLAY

\ ===========================================================================
\ 1. A first note, a first scale
\ ===========================================================================
\
\ PLAY" reads up to the closing quote and plays it on channel A of the
\ first AY chip. Typed at the prompt it plays at once:
\
\   PLAY" c"                     => middle C, a crotchet (half a second)
\   PLAY" cdefgabC"              => the scale of C major, one octave
\
\ Inside a definition PLAY" is compiled, and the word plays when it runs:

: .SCALE  ( -- )  PLAY" cdefgabC" ;

\ The letters are the notes. Small letters c to b are the lower octave
\ of the current range, capitals C to B the octave above: so a range is
\ two octaves wide, and "cC" is an octave jump. Case matters -- every
\ other command is a capital, and a small letter that is not a note is
\ an error (section 9).


\ ===========================================================================
\ 2. Pitch: octaves, sharps and flats
\ ===========================================================================
\
\ O0 to O8 sets the range. The default is O5, the one with middle C at
\ its bottom: O5 c is middle C, O4 C is the same note, O4 c the C below.
\ The range stays set for every note that follows.
\
\   PLAY" O4cgCgc"               => C, G, C an octave up, G, C
\
\ # before a note makes it sharp, $ makes it flat; only that one note:
\
\   PLAY" c#cd$ed"               => C, C sharp, D, E flat, D
\
\ Under the hood the note becomes a tone period for the chip, the
\ number tutorial 034 writes with AY!!:  1750000 / (16 * f).  The A at
\ 440 Hz is 249, middle C is 418. Below about 27 Hz (low in O0 and O1)
\ the chip has no longer period, and the note stays at the lowest.

: .OCTAVES  ( -- )  PLAY" O3cO4cO5cO6cO7c" ;


\ ===========================================================================
\ 3. Durations, rests, ties and tempo
\ ===========================================================================
\
\ A number from 1 to 12 sets the length of the notes that follow:
\
\    1 semiquaver        4 dotted quaver     7 minim
\    2 dotted semiquaver 5 crotchet          8 dotted minim
\    3 quaver            6 dotted crotchet   9 semibreve
\   10 11 12  triplet semiquaver, quaver, crotchet
\
\ The default is 5, the crotchet. The triplets are special: they apply
\ to the next three notes only, then the length before them comes back.
\
\   PLAY" 3cdef5g7C"             => four quavers, a crotchet, a minim
\   PLAY" 11cde5f"               => a quaver triplet, then a crotchet
\
\ & is a rest, as long as a note of the current length. _ ties two
\ lengths into one note: 3_5c is a quaver plus a crotchet.
\
\   PLAY" c&e&g"                 => three notes with rests between
\   PLAY" 3_5c"                  => one C, as long as a dotted crotchet
\
\ T60 to T240 is the tempo, in crotchets per minute (default 120: a
\ crotchet lasts 500 ms). N separates two numbers that would otherwise
\ run together: T240N3c is "tempo 240, then a quaver C", where T2403c
\ would be read as tempo 2403 -- an error.
\
\ Only the FIRST string sets the tempo: a T in the others is read and
\ ignored, as in BASIC.

: .RHYTHM  ( -- )  PLAY" T180 3cdef5g7C 11gfe5d9c" ;


\ ===========================================================================
\ 4. Several channels: strings in the dictionary
\ ===========================================================================
\
\ BASIC's PLAY a$,b$,c$ plays three strings at once, one per channel of
\ the first chip. In vForth each string is an address and a length, and
\ the number of strings comes last:
\
\   a1 n1 a2 n2 a3 n3 3 PLAY
\
\ The safe place for a string that PLAY must read while it plays is the
\ dictionary. ," compiles a counted string at HERE, so a CREATE word
\ followed by ," is a string constant, and COUNT turns it into a n:

CREATE TOP     ," O5ceg7C"
CREATE MIDDLE  ," O5egC7E"
CREATE BOTTOM  ," O3c3gCg7c"

: .CHORDS  ( -- )
    TOP COUNT  MIDDLE COUNT  BOTTOM COUNT  3 PLAY ;

\ Each channel keeps its own octave, length, volume and position in its
\ string: the three strings above have different rhythms, and PLAY
\ moves each one on when its own note ends. PLAY returns when the
\ longest string is over.
\
\ An empty string leaves its channel silent. Write it PAD 0 (any address,
\ length 0): S" " does not give an empty text in vForth (TODO.md).
\
\   TOP COUNT  PAD 0  BOTTOM COUNT  3 PLAY     => melody and bass only


\ ===========================================================================
\ 5. Repeats, comments and H
\ ===========================================================================
\
\ ( ) repeats what is inside once: "(cde)" plays six notes. They nest,
\ and each level doubles: "((c))" is four Cs, "(((c)))" eight.
\
\ A ) with no ( before it repeats from the start of the string, so a
\ string ending with )) repeats FOR EVER. That is how BASIC writes an
\ ostinato bass; an H in another string stops the whole PLAY, all
\ channels at once.
\
\ ! ... ! is a comment, skipped. Spaces are skipped too (BASIC refuses
\ them; vForth allows them for readability).

CREATE THEME   ," !theme! T150 O5 (3cegC) (3dfaD) 9C H"
CREATE OSTINATO ," !bass, for ever! O3 3c&g& ))"

: .OSTINATO  ( -- )  THEME COUNT  OSTINATO COUNT  2 PLAY ;

\ Without the H the bass would never end, and only BREAK would stop it.


\ ===========================================================================
\ 6. Volume and envelope
\ ===========================================================================
\
\ V0 to V15 sets a fixed volume (default 15, the loudest; V0 is
\ silence). U hands the volume to the chip's envelope generator, which
\ changes it while the note plays; W0 to W7 chooses the effect:
\
\   W0 decay then stop      W4 repeated decay
\   W1 attack then stop     W5 repeated attack
\   W2 decay then hold      W6 repeated attack-decay
\   W3 attack then hold     W7 repeated decay-attack
\
\ and X0 to X65535 its period: the larger, the slower (default 65535).
\ With U every note restarts the envelope, so W0 gives each note the
\ attack of a plucked string. A V turns the envelope off again.
\
\   PLAY" UX1500W0 cegC"         => four plucked notes
\   PLAY" UX300W4 9c"            => a note that throbs
\
\ The envelope belongs to the chip, not to the channel: the three
\ channels of one chip share its shape and period.

: .PLUCKED  ( -- )  PLAY" T100 UX1500W0 3cegCgec 7c" ;


\ ===========================================================================
\ 7. Tone and noise: the mixer
\ ===========================================================================
\
\ M0 to M63 chooses, for the chip of the string, which channels play a
\ tone and which play noise -- the sum of:
\
\   tone   A 1   B 2   C 4        noise  A 8   B 16   C 32
\
\ The default is M7, three tones. M8 is noise on channel A only, M9
\ tone and noise together on A. (In the AY's own register 7 the bits
\ are inverted, a 0 switches a channel on: tutorial 034 section on the
\ mixer. M takes the BASIC sense and inverts it for you.)
\
\ On a noise channel the note also sets the pitch of the noise, as far
\ as the chip allows (31 is its lowest): high notes hiss, low ones rumble.

: .DRUM  ( -- )  PLAY" T160 M8UX800W0 O8 3 C&C&5C&C& 3CCC&9C" ;


\ ===========================================================================
\ 8. Nine channels and stereo
\ ===========================================================================
\
\ The Next has three AY chips. Strings 4 to 6 go to channels A, B, C of
\ the second chip, 7 to 9 to the third; with more than three strings
\ PLAY switches Turbosound on by itself. A channel you do not need is
\ PAD 0.
\
\ L and R send the chip of the string to the left or the right speaker
\ only, S back to both. They act on the whole chip, so give them in the
\ first string of each chip:

CREATE LEFT-HAND   ," L O4 (3cegCgeg)"
CREATE RIGHT-HAND  ," R O5 (3CgecegCg)"

: .STEREO  ( -- )
    LEFT-HAND COUNT  PAD 0  PAD 0       \ AY1: left only
    RIGHT-HAND COUNT                    \ AY2: right only
    4 PLAY ;

\ After PLAY every chip it used is silent and back on both sides.


\ ===========================================================================
\ 9. Traps
\ ===========================================================================
\
\ - S" at the prompt, more than once. S" puts its text in the heap and
\   hands back an address in the window at $E000, where the heap pages
\   come and go. A second S" may map another page, and the first
\   address then shows other bytes. Inside a definition, or with ," in
\   the dictionary as in section 4, the problem does not arise.
\
\ - Errors come when PLAY reaches them. A wrong character is reported
\   only when its turn comes, so the notes before it have been played:
\     PLAY" cxd"   => plays c, then  cxd? Syntax error.
\   Other errors: a number out of its range (V16, O9, 13, T300, M64),
\   more than five ( open, more than nine strings. The chips are
\   silenced before the report.
\
\ - PLAY waits. The program does nothing else until the music ends;
\   the time is counted with MS, so PLAY does not depend on the
\   interrupts. For music while the program runs there is AFX
\   (tutorials 050 and 055).
\
\ - Y and Z, BASIC's MIDI commands, are read and ignored.


\ ===========================================================================
\ 10. DEMO: a canon in three voices
\ ===========================================================================
\
\ A round is one tune in several voices, each starting a few bars after
\ the one before. Here a well-known traditional round: four phrases,
\ each played twice, the second voice two bars late (two semibreve
\ rests, 9&9&), the third four bars late and an octave lower.

CREATE VOICE-1  ," T144 O4 (5CDEC)(5EF7G)(3GAGF5EC)(5Cg7C)"
CREATE VOICE-2  ," O4 9&& (5CDEC)(5EF7G)(3GAGF5EC)(5Cg7C)"
CREATE VOICE-3  ," O3 9&&&& (5CDEC)(5EF7G)(3GAGF5EC)(5Cg7C)"

: DEMO  ( -- )
    CR ." A round in three voices; BREAK stops it." CR
    VOICE-1 COUNT  VOICE-2 COUNT  VOICE-3 COUNT  3 PLAY
    ." Done." CR ;

\ Things to try:
\   - change T144 in VOICE-1 (only the first string sets the tempo);
\   - put the third voice on another chip, alone on the left:
\       VOICE-1 COUNT VOICE-2 COUNT PAD 0  PAD 0 PAD 0 VOICE-3 COUNT
\       6 PLAY                    (and add L at the start of VOICE-3)
\   - give the second voice a softer, plucked sound with UX1500W0.


\ ===========================================================================
\ Tests (commented out). With real PLAY they make sound and take time;
\ test/PLAY-TESTS.f checks the same things silently, with stand-ins for
\ the chips.
\ ===========================================================================
\
\ NEEDS TESTING
\ T{ TOP COUNT NIP ->  7 }T
\ T{ 1 2 PLAY" c"  ->  1 2 }T         \ PLAY leaves the stack as it was
