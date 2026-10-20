\
\ PLAY-TESTS.f
\
\ Tests for lib/PLAY.f -- NextBASIC's PLAY strings on the AY chips.
\
\ The test is silent and runs the same on the headless emulator and on
\ the machine: before lib/PLAY.f is compiled, the words it uses to reach
\ the chips (AY!, AY!!, SHH, AYSELECT, ENABLE-TURBOSOUND, the P! of the
\ chip select) and MS are replaced by stand-ins that write into shadow
\ registers and add up the milliseconds. PLAY.f is then INCLUDEd, not
\ NEEDed, so that it is compiled against them even if it was loaded
\ before; TESTING-TASK removes it with the stand-ins.
\
\ The expected periods are 1750000 / (16 f), rounded, with A = 440 Hz:
\ middle C (O5 c) 418, the A above it 249.
\
\ Expected warning: "P! has already been defined." (the stand-in).
\ In the headless emulator: python emu/test_core_suite.py
\ test/PLAY-TESTS.f (all passed, 2026-10-17).
\

MARKER TESTING-TASK

DECIMAL

\ ---------------------------------------------------------------------------
\ stand-ins for lib/AY.f, P! and MS
\ ---------------------------------------------------------------------------

VARIABLE AY                     \ as in lib/AY.f
$FFFD CONSTANT AY-register-port

VARIABLE T-CHIP                 \ chip selected, 1 to 3
VARIABLE T-SIDE                 \ last one-sided stereo seen, 0 if none
VARIABLE T-TURBO                \ true after ENABLE-TURBOSOUND
VARIABLE T-TONES                \ writes of a tone period (low byte)
VARIABLE T-MS                   \ milliseconds waited
CREATE T-REGS  48 ALLOT         \ 16 registers for each chip

: P!  ( b port -- )             \ only the chip select of PLAY.f
    $FFFD = IF
        DUP $80 AND IF
            DUP 3 AND 4 SWAP - T-CHIP !
            $60 AND DUP $60 = IF  DROP  ELSE  T-SIDE !  THEN
        ELSE  DROP  THEN
    ELSE  DROP  THEN ;

: T-REG  ( chip reg -- a )  SWAP 1- 16 * + T-REGS + ;

: AY!  ( b reg -- )
    DUP 6 < OVER 1 AND 0= AND IF  1 T-TONES +!  THEN
    T-CHIP @ SWAP T-REG C! ;

: AY!!  ( n reg -- )  >R  DUP 255 AND R@ AY!  8 RSHIFT R> 1+ AY! ;
: SHH  ( -- )  $FF 7 AY! ;
: AYSELECT  ( n -- )  3 AND DUP AY !  ?DUP IF  T-CHIP !  THEN ;
: ENABLE-TURBOSOUND  ( -- )  -1 T-TURBO ! ;
: MS  ( n -- )  T-MS +! ;

\ ---------------------------------------------------------------------------
\ the library, compiled against the stand-ins
\ ---------------------------------------------------------------------------

INCLUDE lib/PLAY.f

    NEEDS TESTING

TESTING \ PLAY, the NextBASIC music strings

DECIMAL

\ helpers

: T0  ( -- )                    \ before each PLAY
    T-REGS 48 ERASE  0 T-MS !  0 T-TONES !  0 T-SIDE !  0 T-TURBO !
    0 AY ! ;

: T-AY@  ( chip reg -- b )  T-REG C@ ;

: T-PERIOD  ( chip voice -- p )     \ the last period written
    2* 2DUP T-AY@ >R  1+ T-AY@ 8 LSHIFT  R> OR ;

\ strings in the dictionary: STR name text"  then  name ( -- a n )
: STR  ( "name" "text<quote>" -- )
    CREATE  [CHAR] " WORD C@ 1+ ALLOT  DOES>  COUNT ;

STR S-MELODY CDEFH"
STR S-BASS O3c))"
STR S-C c"
STR S-E e"
STR S-G g"
STR S-ARP cdefgabC"
STR S-D2 LD"

\ ---------------------------------------------------------------------------
\ pitch
\ ---------------------------------------------------------------------------

T{  T0 PLAY" c"     1 0 T-PERIOD  ->  418   }T
T{  T0 PLAY" a"     1 0 T-PERIOD  ->  249   }T
T{  T0 PLAY" C"     1 0 T-PERIOD  ->  209   }T
T{  T0 PLAY" O4c"   1 0 T-PERIOD  ->  836   }T
T{  T0 PLAY" O3c"   1 0 T-PERIOD  ->  1672  }T
T{  T0 PLAY" #c"    1 0 T-PERIOD  ->  395   }T
T{  T0 PLAY" $d"    1 0 T-PERIOD  ->  395   }T
T{  T0 PLAY" O0c"   1 0 T-PERIOD  ->  4095  }T
T{  T0 PLAY" O8B"   1 0 T-PERIOD  ->  14    }T

\ the octave stays, the sharp does not
T{  T0 PLAY" O4#cc" 1 0 T-PERIOD  ->  836   }T

\ ---------------------------------------------------------------------------
\ time: a crotchet lasts 500 ms at the default T120
\ ---------------------------------------------------------------------------

T{  T0 PLAY" cdeC"      T-MS @  T-TONES @  ->  2000 4  }T
T{  T0 PLAY" 1c"        T-MS @             ->  125     }T
T{  T0 PLAY" 9c"        T-MS @             ->  2000    }T
T{  T0 PLAY" 5c6c"      T-MS @             ->  1250    }T
T{  T0 PLAY" 7cc"       T-MS @             ->  2000    }T

\ triplets: three notes, then the duration before them comes back
T{  T0 PLAY" 11ACE"     T-MS @             ->  500     }T
T{  T0 PLAY" 10cde5c"   T-MS @             ->  750     }T
T{  T0 PLAY" 12cdec"    T-MS @             ->  1500    }T

\ a tie adds the first duration to the next note only
T{  T0 PLAY" 3_5A"      T-MS @  T-TONES @  ->  750 1   }T
T{  T0 PLAY" 3_5AA"     T-MS @             ->  1250    }T

\ tempo, and N between two numbers
T{  T0 PLAY" T60c"      T-MS @             ->  1000    }T
T{  T0 PLAY" T240N1c"   T-MS @             ->  62      }T

\ a rest lasts like a note and plays none
T{  T0 PLAY" c&c"       T-MS @  T-TONES @  ->  1500 2  }T

\ spaces and comments
T{  T0 PLAY" c d"       T-TONES @          ->  2       }T
T{  T0 PLAY" c!dd!e"    T-TONES @          ->  2       }T

\ ---------------------------------------------------------------------------
\ repeats
\ ---------------------------------------------------------------------------

T{  T0 PLAY" (c)"       T-TONES @          ->  2       }T
T{  T0 PLAY" (((c)))"   T-TONES @  T-MS @  ->  8 4000  }T
T{  T0 PLAY" abC(DE)"   T-TONES @          ->  7       }T
T{  T0 PLAY" (a(b)c)"   T-TONES @          ->  8       }T
T{  T0 PLAY" ab)"       T-TONES @          ->  4       }T

\ )) repeats for ever: H in the other string stops both
T{  T0 S-MELODY S-BASS 2 PLAY   T-MS @     ->  2000    }T
T{  T0 S-MELODY S-BASS 2 PLAY   1 1 T-PERIOD  ->  1672 }T

\ ---------------------------------------------------------------------------
\ channels and chips
\ ---------------------------------------------------------------------------

T{  T0 S-C S-E S-G 3 PLAY
    1 0 T-PERIOD  1 1 T-PERIOD  1 2 T-PERIOD  ->  418 332 279  }T
T{  T0 S-C S-E S-G 3 PLAY   T-MS @  T-TURBO @  ->  500 0   }T

\ an empty string leaves its channel silent
T{  T0 S-C PAD 0 S-G 3 PLAY   1 1 T-PERIOD  T-TONES @  ->  0 2  }T

\ four strings and more: the second chip, with Turbosound
T{  T0 S-C PAD 0 PAD 0 S-E 4 PLAY
    2 0 T-PERIOD  T-TURBO @  ->  332 -1  }T

\ nine strings, the last on channel C of AY3
T{  T0 S-C S-C S-C S-C S-C S-C S-C S-C S-ARP 9 PLAY
    3 2 T-PERIOD  T-MS @  ->  209 4000  }T

\ after PLAY the chips are quiet: mixer off, volumes 0
T{  T0 S-C S-E S-G 3 PLAY
    1 7 T-AY@  1 8 T-AY@  1 9 T-AY@  1 10 T-AY@  ->  255 0 0 0  }T

\ and the chip of AY (or AY1) is selected again
T{  T0 S-C PAD 0 PAD 0 S-E 4 PLAY  T-CHIP @  ->  1  }T

\ ---------------------------------------------------------------------------
\ volume, envelope, mixer, stereo
\ ---------------------------------------------------------------------------

\ U W X: shape 4 for W1, period 5000, written for the note
T{  T0 PLAY" UX5000W1c"
    1 13 T-AY@  1 11 T-AY@  1 12 T-AY@  ->  4 136 19  }T
T{  T0 PLAY" UW7c"   1 13 T-AY@  ->  10  }T

\ without X the envelope period is the longest
T{  T0 PLAY" Uc"   1 11 T-AY@  1 12 T-AY@  ->  255 255  }T

\ noise on A: the note sets the noise period too, at most 31
T{  T0 PLAY" M8c"      1 6 T-AY@  ->  31  }T
T{  T0 PLAY" M8O8B"    1 6 T-AY@  ->  14  }T
T{  T0 PLAY" M1c"      1 6 T-AY@  ->  0   }T

\ L and R: one side only, for the chip of the string
T{  T0 PLAY" Lc"          T-SIDE @  ->  $40  }T
T{  T0 PLAY" Rc"          T-SIDE @  ->  $20  }T
T{  T0 PLAY" LSc"         T-SIDE @  ->  $40  }T
T{  T0 PLAY" c"           T-SIDE @  ->  0    }T
T{  T0 S-C S-D2 2 PLAY    T-SIDE @  ->  $40  }T

\ ---------------------------------------------------------------------------
\ PLAY" inside a definition, and the stack
\ ---------------------------------------------------------------------------

: T-TUNE  ( -- )  PLAY" O4ceg" ;

T{  T0 T-TUNE  T-TONES @  1 0 T-PERIOD  ->  3 558  }T
T{  T0 1 2 PLAY" c" ->  1 2  }T

\ ---------------------------------------------------------------------------
\ Not covered here: an error goes through ERROR and QUIT, not THROW, so
\ CATCH cannot see it and T{ ... }T cannot express it. Verified by hand
\ on the emulator; each prints the string, ? , and the message, after
\ the chips are silenced:
\
\   PLAY" cxd"          -> #19 Syntax error.  (the c is played first)
\   PLAY" ((((((c"      -> #19 Syntax error.  (six ( open)
\   PLAY" V16c"         -> -24 Invalid numeric argument.
\   PLAY" O9c"          -> -24 Invalid numeric argument.
\   PLAY" 13c"  "0c"    -> -24 Invalid numeric argument.
\   PLAY" T300c"        -> -24 Invalid numeric argument.
\   PLAY" M64c"         -> -24 Invalid numeric argument.
\   PAD 0 10 PLAY       -> -24 Invalid numeric argument.  (ten strings)
\   BREAK while playing -> #15 [ BREAK ] was pressed.
\ ---------------------------------------------------------------------------

CR .( PLAY-TESTS done. Type TESTING-TASK to unload. ) CR
