\
\ AY.F
\
\ .( AY definitions )

NEEDS BINARY            \ base 2
NEEDS SPLIT             \ split an integer into two bytes, low, high.

BASE @

MARKER NO-AY

\
\ Turbo Sound Next Control Register
\
HEX 0FFFD  CONSTANT AY-register-port
\
\ when bit 7 is 1:
\   7   1
\   6   1 to enable left audio
\   5   1 to enable right audio
\ 4-2   must be 1
\ 1-0   selects active chip 01:AY3, 10:AY2, 11:AY1
\
\ when bit 7 is 0
\ 6-0   selects given AY register number for read or write from active sound chip
\  0 - Channel A tone, low byte
\  1 - Channel A tone, high 4 bits    
\  2 - Channel B tone, low byte
\  3 - Channel B tone, high 4 bits    
\  4 - Channel C tone, low byte
\  5 - Channel C tone, high 4 bits    
\  6 - Noise period (between 0 and 31)
\  7 - Flags   0 0  noise [  C B A  ] tone [  C B A  ]
\  8 - Channel A volume/envelope (between 0 and 15)
\  9 - Channel B volume/envelope (between 0 and 15)
\ 10 - Channel C volume/envelope (between 0 and 15)
\ 11 - Envelope period fine
\ 12 - Envelope period coarse
\ 13 - Envelope shape 0 0 0 0 [ C At Al H ]

\
\ Sound Chip Register Write
\
    0BFFD  CONSTANT AY-data-port

\ 
\ Peripheal 2 Register 
\
    06     CONSTANT Peripheal-2-register 
\
\   7   1 to enable F8 key CPU speed mode
\   6   1 to divert BEEP to internal beeper
\   5   1 to enable F3 key (50/60Hz switch)
\   4   1 to enable DivMMC automap
\   3   1 to enable multiface NMI
\   2   1 to set primary device to mouse PS/2, 0 keyboard
\ 1-0   Audio chip mode. 00:YM, 01:AY, 10:Disabled, 11:Hold all AY in reset

\ 
\ Peripheal 3 Register 
\
    08     CONSTANT Peripheal-3-register 
\
\   7   1 unlock / 0 lock  port 7FFD paging
\   6   1 to disable RAM and I/O port contention 
\   5   AY stereo mode (0:ABC, 1:ACB)
\   4   enable internal speaker
\   3   enable 8-bit DACs (A,B,C,D)
\   2   enable port FF Timex video mode
\   1   enable Turbosound 
\   0   implement Issue 2 keyboard

\ 
\ Peripheal 4 Register 
\
    09     CONSTANT Peripheal-4-register 
\
\   7   1 to enable AY2 "mono" output (A+B+C)
\   6   1 to enable AY1 "mono" 
\   5   1 to enable AY0 "mono"
\   4   1 to lockstep Sprite
\   3   1 to reset mapram bit in DivMMC
\   2   1 to silence HDMI audio
\ 1-0   scanline weight


\ Latest AY selected minus 1.
VARIABLE  AY

\ Select one of the three AY available. 0:AY1, 1:AY2, 2:AY3.
: AYSELECT ( n -- )
    3 AND DUP               \ n n
    0 SWAP -                \ n -n
    ?DUP IF                 \ if non zero, then select one chip
        AY-register-port P!
    THEN                    \ n
    AY !
;


\ ayreg must be between 0 and 16
: AY!     ( b ayreg -- )
    AY-register-port P!  
    AY-data-port     P!
;


\ ayreg is 0, 2 or 4 for channel A, B or C
: AY!!     ( n ayreg -- )
    >R SPLIT SWAP       \  hi lo
    R@      AY!         \  hi
    R>  1+  AY!
;


\ silence current AY
: SHH
    [ HEX ]  0FF 07 AY!
;


\ general enabling 
: ENABLE-TURBOSOUND
    \ setup mapping of chip channels to stereo channels
    [ HEX    ] 8 REG@
    [ BINARY ] 00000010 OR  \ enable Turbosound
    [ HEX    ] 8 REG!
;


: ENABLE-MONO
    [ HEX    ] 9 REG@
    [ BINARY ] 11100000 OR  \ enable Mono for A,B and C
    [ HEX    ] 9 REG!
;


: DISABLE-MONO
    [ HEX    ] 9 REG@
    [ BINARY ] 00011111 AND \ disable Mono for A,B and C
    [ HEX    ] 9 REG!
;


: AYSETUP
    3 AYSELECT  SHH  ENABLE-MONO
    2 AYSELECT  SHH  ENABLE-MONO
    1 AYSELECT  SHH  ENABLE-MONO
;


\ BINARY 11111101 \ enable left+right audio, select AY1
\ HEX FFFD P!
\ BINARY 00010010 HEX 08 REG! \ Use ABC, enable internal spkr
\ BINARY 11100000 HEX 09 REG! \ Enable mono for AY1-3


BASE !
