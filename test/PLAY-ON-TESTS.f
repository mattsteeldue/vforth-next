\
\ PLAY-ON-TESTS.f
\
\ Tests for lib/PLAY-ON.f -- lib/PLAY.f in the background, on the frame
\ interrupt.
\
\ Silent, like PLAY-TESTS.f, and with no interrupt at all: the words of
\ lib/AY.f, MS, the ISR words of lib/INTERRUPTS.f and REG@ (for the
\ 50/60 Hz bit of NextReg 5) are replaced by stand-ins before the two
\ libraries are INCLUDEd. A frame is one call of the xt in the stand-in
\ ISR-XT, so T-RUN counts the frames the music lasts.
\
\ At T120 a crotchet is 24 units and 2T = 240 is added every frame:
\ 25 frames at 50 Hz (a unit every 250), 30 at 60 Hz (every 300).
\
\ Expected warnings: "P! has already been defined." and
\ "REG@ has already been defined." (the stand-ins).
\ In the headless emulator: python emu/test_core_suite.py
\ test/PLAY-ON-TESTS.f
\

MARKER TESTING-TASK

DECIMAL

\ ---------------------------------------------------------------------------
\ stand-ins for lib/AY.f, P!, MS, lib/INTERRUPTS.f and REG@
\ ---------------------------------------------------------------------------

VARIABLE AY                     \ as in lib/AY.f
$FFFD CONSTANT AY-register-port

VARIABLE T-CHIP                 \ chip selected, 1 to 3
VARIABLE T-TONES                \ writes of a tone period (low byte)
VARIABLE T-MS                   \ milliseconds waited: none in background
CREATE T-REGS  48 ALLOT         \ 16 registers for each chip

: P!  ( b port -- )             \ only the chip select of PLAY.f
    $FFFD = IF
        DUP $80 AND IF  DUP 3 AND 4 SWAP - T-CHIP !  THEN
    THEN  DROP ;

: T-REG  ( chip reg -- a )  SWAP 1- 16 * + T-REGS + ;

: AY!  ( b reg -- )
    DUP 6 < OVER 1 AND 0= AND IF  1 T-TONES +!  THEN
    T-CHIP @ SWAP T-REG C! ;

: AY!!  ( n reg -- )  >R  DUP 255 AND R@ AY!  8 RSHIFT R> 1+ AY! ;
: SHH  ( -- )  $FF 7 AY! ;
: AYSELECT  ( n -- )  3 AND DUP AY !  ?DUP IF  T-CHIP !  THEN ;
: ENABLE-TURBOSOUND  ( -- )  ;
: MS  ( n -- )  T-MS +! ;

VARIABLE T-ON                   \ ISR-ON calls
VARIABLE T-OFF                  \ ISR-OFF calls
VARIABLE T-60                   \ true: NextReg 5 says 60 Hz

CREATE ISR-XT  ' NOOP ,
: ISR-DI   ( -- )  ;
: ISR-EI   ( -- )  ;
: ISR-ON   ( -- )  1 T-ON +! ;
: ISR-OFF  ( -- )  1 T-OFF +! ;
: INTERRUPTS  ( -- )  ;         \ so that NEEDS INTERRUPTS loads nothing

: REG@  ( reg -- b )  5 = IF  T-60 @ IF  4  ELSE  0  THEN  ELSE  0  THEN ;

\ ---------------------------------------------------------------------------
\ the libraries, compiled against the stand-ins
\ ---------------------------------------------------------------------------

INCLUDE lib/PLAY.f
INCLUDE lib/PLAY-ON.f

    NEEDS TESTING

TESTING \ PLAY-ON, PLAY in the background

DECIMAL

\ helpers

: T0  ( -- )
    T-REGS 48 ERASE  0 T-MS !  0 T-TONES !  0 AY !
    0 T-ON !  0 T-OFF !  0 T-60 ! ;

: T-AY@  ( chip reg -- b )  T-REG C@ ;

: T-PERIOD  ( chip voice -- p )
    2* 2DUP T-AY@ >R  1+ T-AY@ 8 LSHIFT  R> OR ;

: T-FRAME  ( -- )  ISR-XT @ EXECUTE ;

: T-RUN  ( -- frames )          \ the frames until the music ends
    0  BEGIN  PLAYING?  OVER 10000 < AND  WHILE  T-FRAME 1+  REPEAT ;

: STR  ( "name" "text<quote>" -- )
    CREATE  [CHAR] " WORD C@ 1+ ALLOT  DOES>  COUNT ;

STR S-C c"
STR S-CDEC cdeC"
STR S-CDEF cdef"
STR S-TRIP 11ACE"
STR S-FAST T240N1c1c1c1c"
STR S-MELODY CDEFH"
STR S-BASS O3c))"
STR S-BAD cxd"
STR S-EMPTY V5))"
STR S-TEMPO T60c"

VARIABLE T-AFX                  \ frames seen by another ISR word
: T-OTHER  ( -- )  1 T-AFX +! ;

\ ---------------------------------------------------------------------------
\ time in frames
\ ---------------------------------------------------------------------------

T{  T0 S-C 1 PLAY-ON  PLAYING?  T-ON @  ->  -1 1  }T
T{  T-RUN  ->  25  }T
T{  T0 S-CDEC 1 PLAY-ON  T-RUN  T-TONES @  T-MS @  ->  100 4 0  }T
T{  T0 -1 T-60 !  S-CDEC 1 PLAY-ON  T-RUN  ->  120  }T

\ triplets: three notes of 8 units, a crotchet in all
T{  T0 S-TRIP 1 PLAY-ON  T-RUN  ->  25  }T

\ T240: 1.92 units a frame; four notes of 6 units take 13 frames, not 16:
\ what a frame takes past the end of a note comes off the next one
T{  T0 S-FAST 1 PLAY-ON  T-RUN  ->  13  }T

\ T60: a crotchet is a second
T{  T0 S-TEMPO 1 PLAY-ON  T-RUN  ->  50  }T

\ the first note is written by PLAY-ON itself, before any frame
T{  T0 S-C 1 PLAY-ON  1 0 T-PERIOD  ->  418  }T
T{  T-RUN DROP  ->  }T

\ ---------------------------------------------------------------------------
\ the end, PLAY-OFF, PLAY
\ ---------------------------------------------------------------------------

\ at the end the chips are quiet and ISR-XT holds NOOP again
T{  T0 S-C 1 PLAY-ON  T-RUN DROP
    1 7 T-AY@  1 8 T-AY@  ISR-XT @ ' NOOP =  ->  255 0 -1  }T

\ H in one string stops the bass that repeats for ever
T{  T0 S-MELODY S-BASS 2 PLAY-ON  T-RUN  ->  100  }T

\ PLAY-OFF in the middle; with NOOP back in ISR-XT it gives IM 1 back
\ (the first ISR-OFF is the PLAY-OFF that PLAY-ON begins with)
T{  T0 S-CDEF 1 PLAY-ON  T-FRAME T-FRAME T-FRAME  PLAY-OFF
    PLAYING?  ISR-XT @ ' NOOP =  T-OFF @  1 8 T-AY@  ->  0 -1 2 0  }T

\ PLAY stops the background first
T{  T0 S-CDEF 1 PLAY-ON  T-FRAME  PLAY" c"  PLAYING?  T-MS @  ->  0 500  }T

\ nothing to play: PLAY-ON does not install itself
T{  T0 S-EMPTY 1 PLAY-ON  PLAYING?  T-ON @  ->  0 0  }T
T{  T0 PAD 0 1 PLAY-ON  PLAYING?  ->  0  }T

\ and the blocking PLAY no longer loops for ever on it
T{  T0 S-EMPTY 1 PLAY  T-MS @  ->  0  }T

\ ---------------------------------------------------------------------------
\ the strings are copied
\ ---------------------------------------------------------------------------

CREATE T-BUF  2 ALLOT
T{  T0 [CHAR] c T-BUF C!  [CHAR] d T-BUF 1+ C!
    T-BUF 2 1 PLAY-ON  [CHAR] x T-BUF C!  [CHAR] x T-BUF 1+ C!
    T-RUN  T-TONES @  PLAY-ERROR  ->  50 2 0  }T

\ ---------------------------------------------------------------------------
\ an error found in the interrupt halts the music and is kept
\ ---------------------------------------------------------------------------

T{  T0 S-BAD 1 PLAY-ON  PLAY-ERROR  ->  0  }T
T{  T-RUN  PLAY-ERROR  T-TONES @  ->  25 19 1  }T

\ ---------------------------------------------------------------------------
\ another word in ISR-XT goes on, after the music, and comes back
\ ---------------------------------------------------------------------------

T{  T0 0 T-AFX !  ' T-OTHER ISR-XT !
    S-CDEC 1 PLAY-ON  T-RUN  T-AFX @  ->  100 100  }T
T{  ISR-XT @ ' T-OTHER =  ->  -1  }T
T{  T0 PLAY-OFF  T-OFF @  ISR-XT @ ' T-OTHER =  ->  0 -1  }T
' NOOP ISR-XT !

\ ---------------------------------------------------------------------------
\ Not covered here: the real interrupt (the headless emulator has no IM 2),
\ and the errors that PLAY-ON itself reports through ERROR and QUIT:
\   S" cxd" 1 PLAY-ON plays c, the error comes from the interrupt (above);
\   S" xd" 1 PLAY-ON    -> #19 Syntax error.  (before any note)
\   strings longer than 1024 bytes in all -> -18
\ ---------------------------------------------------------------------------

CR .( PLAY-ON-TESTS done. Type TESTING-TASK to unload. ) CR
