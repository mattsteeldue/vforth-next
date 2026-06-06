\
\ 034-ay-sound.f
\ AY-3-8910 sound chip: registers, chip selection, and tone output.
\
\ The ZX Spectrum Next has three AY-3-8910 (Turbosound Next) chips,
\ each with three tone channels (A, B, C) plus noise and a shared
\ envelope generator.  lib/AY.f provides words to select a chip and
\ write its registers using the standard I/O ports $FFFD (register
\ select) and $BFFD (data write).
\
\ Reference: sec.3.13
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   034 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 034 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 034: AY-3-8910 sound chip loaded. ) CR
.(     Type NEWTASK to unload.                ) CR

NEEDS AY
NEEDS ms


\ ===========================================================================
\ 1. Hardware overview
\ ===========================================================================
\
\ AY-3-8910 register map (per chip):
\   Reg  0 : Channel A tone, low byte  (12-bit tone period = reg0 + reg1*256)
\   Reg  1 : Channel A tone, high 4 bits
\   Reg  2 : Channel B tone, low byte
\   Reg  3 : Channel B tone, high 4 bits
\   Reg  4 : Channel C tone, low byte
\   Reg  5 : Channel C tone, high 4 bits
\   Reg  6 : Noise period 0-31
\   Reg  7 : Mixer flags  %xxxxxxxx
\            bits 5-3 : noise enable C B A  (0=enabled)
\            bits 2-0 : tone  enable C B A  (0=enabled)
\   Reg  8 : Channel A volume 0-15 (bit4=1 use envelope)
\   Reg  9 : Channel B volume 0-15
\   Reg 10 : Channel C volume 0-15
\   Reg 11 : Envelope period, fine
\   Reg 12 : Envelope period, coarse
\   Reg 13 : Envelope shape  %0000CAAH
\
\ Tone period formula (for 1.75 MHz chip clock):
\   period = 1750000 / ( 16 * freq_Hz )
\   e.g. 440 Hz  ->  period = 1750000 / 7040 ~ 248

\ ===========================================================================
\ 2. Port constants (from lib/AY.f)
\ ===========================================================================
\
\   AY-register-port  $FFFD   write=chip/register select, read=data
\   AY-data-port      $BFFD   write=data to selected register
\
\ Chip select: write %11xxxxcc to AY-register-port
\   bit 7 = 1 selects chip mode
\   bit 6 = left audio enable
\   bit 5 = right audio enable
\   bits 1-0 : chip: %01=AY3, %10=AY2, %11=AY1

\ ===========================================================================
\ 3. Key words from lib/AY.f
\ ===========================================================================
\
\   AYSELECT ( n -- )   select chip n: 1=AY1, 2=AY2, 3=AY3
\                       (1-based; 0 is a no-op, see lib/AY.f)
\                       stores selection in variable AY
\
\   AY!  ( b ayreg -- )  write byte b to AY register ayreg
\                        for the currently selected chip
\
\   AY!! ( n ayreg -- )  write 16-bit value n to register pair
\                        ayreg (low) and ayreg+1 (high 4 bits)
\                        used for tone period: ayreg = 0, 2, or 4
\
\   SHH  ( -- )          silence: write $FF to register 7
\                        (disables all tones and noise)
\
\   AYSETUP ( -- )       initialise all 3 chips: silence + enable mono

\ ===========================================================================
\ 4. Playing a tone: step by step
\ ===========================================================================
\
\ To play a tone on channel A of AY1:
\
\   1. Select chip:       1 AYSELECT     \ AY1
\   2. Set volume:        15 8 AY!        \ ch A max volume
\   3. Set tone period:   248 0 AY!!      \ ~440 Hz tone period
\   4. Enable tone only:  %00111110 7 AY! \ enable ch A tone only
\
\ To silence the chip:  SHH
\
\ Tone period for a given frequency f (Hz):
\   period = 1750000 / ( f * 16 )
\
\ Common note periods (approximate):
\   Note C4  (~262 Hz)  period ~ 418
\   Note A4  ( 440 Hz)  period ~ 248
\   Note C5  (~523 Hz)  period ~ 209

\ Tone period formula:
\   period = 1750000 / ( freq_hz * 16 )
\ In 16-bit arithmetic, use double-number division:
\   freq_hz 16 * ( n1 -- d )
\   1750000 OVER UM/MOD NIP
\ Common values (pre-computed):
\   262 Hz (C4) -> period 418
\   440 Hz (A4) -> period 248
\   523 Hz (C5) -> period 209

\ ===========================================================================
\ 5. Enable Turbosound and mono output
\ ===========================================================================
\
\ The ZX Next Turbosound must be enabled via Next registers before
\ any AY chips beyond AY1 will work.
\
\   ENABLE-TURBOSOUND ( -- )  set bit 1 of Next register 8
\   ENABLE-MONO       ( -- )  set bits 7-5 of Next register 9
\                             to route all channels to mono output
\
\ AYSETUP calls both automatically for all three chips.

\ ===========================================================================
\ 6. Demo: play tone on channel A
\ ===========================================================================

: AY-BEEP  ( period -- )
    AYSETUP                   \ silence and setup all chips
    1 AYSELECT                \ select AY1
    15 8 AY!                  \ channel A: max volume
    0 AY!!                    \ write tone period (TOS=period)
    %00111110 7 AY!           \ mixer: only channel A tone active
;

: AY-SILENCE  ( -- )
    1 AYSELECT  SHH
;

: DEMO-AY-TONE  ( -- )
    ." Playing A4 (440 Hz) on AY channel A..." CR
    248 AY-BEEP               \ 440 Hz
    1000 ms
    AY-SILENCE
    ." Done." CR
;

\ ===========================================================================
\ 7. Demo: three-note chord
\ ===========================================================================

: AY-CHORD  ( -- )
    AYSETUP
    1 AYSELECT
    \ channel A: C4 (~262 Hz, period ~418)
    12 8 AY!      418 0 AY!!
    \ channel B: E4 (~330 Hz, period ~331)
    12 9 AY!      331 2 AY!!
    \ channel C: G4 (~392 Hz, period ~279)
    12 10 AY!     279 4 AY!!
    \ mixer: enable all three tone channels, no noise
    %00111000 7 AY!
    1500 ms
    SHH
;

\ ===========================================================================
\ 8. Demo: simple noise burst
\ ===========================================================================

: AY-NOISE  ( -- )
    AYSETUP
    1 AYSELECT
    12 8 AY!           \ channel A: volume 12
    16 6 AY!           \ noise period 16
    %00110111 7 AY!    \ mixer: enable ch A noise, disable tones
    500 ms
    SHH
;

\ ===========================================================================
\ 9. Cumulative demo
\ ===========================================================================

: DEMO
    DEMO-AY-TONE
    AY-CHORD
    AY-NOISE
    AY-SILENCE
;

CR
.( Try: DEMO ) CR


\ ===========================================================================
\ 10. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ AY words have hardware side effects.  Only the period calculation
\ can be tested as a pure function.
\
\ NEEDS TESTING
\ T{  0 0  ->  0  }T   \ placeholder: AY tests require hardware
