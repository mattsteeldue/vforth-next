\
\ AY.F
\
\ .( AY definitions )

NEEDS BINARY
NEEDS SPLIT

BASE @

\ Latest AY selected minus one.
VARIABLE  AY


\ Select one of the three AY available. AY1, AY2, AY3.
: AYSELECT ( n -- )
    3 AND DUP               \ n n
    0 SWAP -                \ n -n
    ?DUP IF
        [ HEX ] 0FFFD P!    \ Turbo Sound Next Control Register.
    THEN                    \ n
    AY !
;


\ 0FFFD : AY register port
\ 0BFFD : AY data port
\ ayreg must be between 0 and 16
: AY!     ( b ayreg -- )
    [ HEX ]  0FFFD P!  0BFFD P!
;


\ ayreg is 0, 2 or 4 for channel A, B or C
: AY!!     ( n ayreg -- )
    >R SPLIT SWAP       \  hi lo
    R@      AY!         \  hi
    R>  1+  AY!
;


\ silence!
: SHH
    [ HEX ]  0FF 07 AY!
;


\ BINARY 11111101 \ enable left+right audio, select AY1
\ HEX FFFD P!
\ BINARY 00010010 HEX 08 REG! \ Use ABC, enable internal spkr
\ BINARY 11100000 HEX 09 REG! \ Enable mono for AY1-3

: AYSETUP
    \ setup mapping of chip channels to stereo channels
    [ HEX    ] 8 REG@
    [ BINARY ] 00000010 OR  \ enable NextSound
    [ HEX    ] 8 REG!

    [ HEX    ] 9 REG@
    [ BINARY ] 11100000 OR  \ enable Mono for A,B and C
    [ HEX    ] 9 REG!
    3 AYSELECT SHH
    2 AYSELECT SHH
    1 AYSELECT SHH
;

BASE !
