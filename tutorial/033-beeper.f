\
\ 033-beeper.f
\ Beeper sound: BLEEP, BLEEP-CALC, BEEP-PITCH, and BEEP.
\
\ The ZX Spectrum beeper is driven by toggling bit 4 of port $FE.
\ vForth provides a high-level word BEEP (ms pitch) that plays a
\ note at the given pitch for the given duration.  BEEP temporarily
\ sets the CPU to 3.5 MHz for correct timing and restores speed
\ afterward.  The lower-level words BLEEP, BLEEP-CALC, and BEEP-PITCH
\ give full control over the raw hardware parameters.
\
\ Reference: sec.3.12
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   033 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 033 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 033: Beeper sound loaded. ) CR
.(     Type NEWTASK to unload.          ) CR

NEEDS BLEEP


\ ===========================================================================
\ 1. Word overview
\ ===========================================================================
\
\ NEEDS BLEEP loads lib/bleep.f, which provides:
\   BLEEP      ( n1 n2 -- )    raw ROM beeper call
\   BLEEP-CALC ( ms 8*Hz -- n1 n2 )  compute BLEEP parameters
\   BEEP-PITCH ( pitch -- 8*freq )   chromatic pitch to frequency
\   BEEP       ( ms pitch -- )       high-level: play note
\
\ NEEDS BLEEP also loads SPEED@ and SPEED! (required by BEEP).

\ ===========================================================================
\ 2. BLEEP -- raw ROM beeper
\ ===========================================================================
\
\   BLEEP ( n1 n2 -- )
\
\   n1 = ( 3.5 MHz / Hz - 241 ) / 8     pitch parameter for ROM
\   n2 = seconds * Hz                    duration parameter for ROM
\
\ The ROM routine at $03B5 is called directly.  Both parameters
\ must be pre-computed.  The ROM requires the CPU to be at 3.5 MHz.
\
\ Example: middle A (440 Hz) for 1 second
\   HEX 07A7 00DC BLEEP
\   ( n1 = (3500000/440 - 241)/8 = 1959 = $07A7 )
\   ( n2 = 1 * 440 = 440 = $01B8  ... typical value )

\ ===========================================================================
\ 3. BLEEP-CALC -- compute BLEEP parameters from friendly values
\ ===========================================================================
\
\   BLEEP-CALC ( ms 8*Hz -- n1 n2 )
\
\   ms    : duration in milliseconds
\   8*Hz  : frequency in Hz multiplied by 8
\
\ Example: 500 ms at 440 Hz:
\   500  3520  BLEEP-CALC   \ 3520 = 440 * 8
\   BLEEP                   \ play it

\ ===========================================================================
\ 4. BEEP-PITCH -- chromatic scale pitch to 8*frequency
\ ===========================================================================
\
\   BEEP-PITCH ( pitch -- 8*freq )
\
\ Pitch values on the chromatic scale, starting from middle C (C4):
\    0  C4  (middle C, ~261.6 Hz)
\    1  C#4
\    2  D4
\    3  D#4
\    4  E4
\    5  F4
\    6  F#4
\    7  G4
\    8  G#4
\    9  A4  (concert pitch, 440 Hz)
\   10  A#4
\   11  B4
\   12  C5  (one octave above middle C)
\  -12  C3  (one octave below middle C)
\
\ Example:
\   9 BEEP-PITCH .   \ => frequency*8 for 440 Hz A4

\ ===========================================================================
\ 5. BEEP -- high-level word
\ ===========================================================================
\
\   BEEP ( ms pitch -- )
\
\   ms    : duration in milliseconds
\   pitch : chromatic pitch (see BEEP-PITCH table above)
\
\ BEEP internally:
\   1. calls BEEP-PITCH to convert pitch to 8*freq
\   2. calls BLEEP-CALC to get BLEEP parameters
\   3. saves current CPU speed with SPEED@
\   4. sets CPU to 3.5 MHz with SPEED! 0
\   5. calls BLEEP
\   6. restores CPU speed with SPEED!
\
\ Example: play middle C for 300 ms
\   300 0 BEEP
\
\ Example: play A4 for 1 second
\   1000 9 BEEP

\ ===========================================================================
\ 6. Demo: chromatic scale
\ ===========================================================================

: PLAY-SCALE  ( -- )
    ." Playing C major scale..." CR
    150 0 BEEP    \ C
    150 2 BEEP    \ D
    150 4 BEEP    \ E
    150 5 BEEP    \ F
    150 7 BEEP    \ G
    150 9 BEEP    \ A
    150 11 BEEP   \ B
    300 12 BEEP   \ C (octave above)
;

\ ===========================================================================
\ 7. Demo: play a note sequence
\ ===========================================================================

: PLAY-NOTES  ( -- )
    ." Twinkle pattern..." CR
    200 0 BEEP   200 0 BEEP   200 7 BEEP   200 7 BEEP
    200 9 BEEP   200 9 BEEP   400 7 BEEP
    200 5 BEEP   200 5 BEEP   200 4 BEEP   200 4 BEEP
    200 2 BEEP   200 2 BEEP   400 0 BEEP
;

\ ===========================================================================
\ 8. Demo: alarm effect
\ ===========================================================================

: ALARM  ( -- )
    ." Alarm..." CR
    10 0 DO
        150 12 BEEP   \ high C
        150  0 BEEP   \ middle C
    LOOP
;

\ ===========================================================================
\ 9. Demo: using BLEEP-CALC directly for a custom tone
\ ===========================================================================

\ Play 200 ms at 880 Hz (A5, one octave above concert pitch).
: PLAY-A5  ( -- )
    SPEED@ >R
    0 SPEED!          \ must be at 3.5 MHz
    200  7040          \ 880 * 8 = 7040
    BLEEP-CALC BLEEP
    R> SPEED!
;


\ ===========================================================================
\ 10. Cumulative demo
\ ===========================================================================

: DEMO
    PLAY-SCALE 
    ALARM      
    PLAY-A5    
;

CR
.( Try: DEMO ) CR



\ ===========================================================================
\ 11. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ BEEP produces audio side-effects; it cannot be verified automatically.
\ BEEP-PITCH is a pure function and can be tested.
\
\ NEEDS TESTING
\ T{  9 BEEP-PITCH  ->  3520  }T   \ 440 Hz * 8
