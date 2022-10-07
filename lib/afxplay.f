\
\ AFXPLAY.F
\
\ .( AFX PLAYER - Music using AY )

NEEDS INTERRUPTS
NEEDS BINARY
NEEDS SPLIT



\ Latest AY selected minus one.
VARIABLE  AY-N

VARIABLE  afxMixPointer \ pointer to one of the following address

VARIABLE  afxNoiseMix  \ valore noise-mixer
          6 ALLOT

\ channel descriptors, 4 byte per canale:
\ +0 (2) current address (il canale è libero se high byte = #00)
\ +2 (2) tempo di effetto
\ ...

variable  afxChDesc  34 allot  \ 36 bytes table 3x4 x3 AY's
          afxChDesc  36 ERASE

variable  afxBnkAdr  \ pointer indirizzo bank


\ Select one of the three AY available. AY1, AY2, AY3.
: AYSELECT ( n -- )
    3 AND DUP               \ n n
    0 SWAP -                \ n -n
    ?DUP IF
        [ HEX ] 0FFFD P!    \ Turbo Sound Next Control Register.
    THEN                    \ n
    DUP AY-N !
    1- CELLS afxNoiseMix + afxMixPointer !
;


\ 0FFFD : AY register port
\ 0BFFD : AY data port
\ ayreg must be between 0 and 16
: AY!     ( b ayreg -- )
    [ HEX ]  0FFFD P!  0BFFD P!
;

\ ayreg is 0, 2 or 4 for channel A, B or C
: AY!!     ( n ayreg -- )
    >R SPLIT            \  hi lo
    R@      AY!         \  hi
    R>  1+  AY!
;


\ silence!
: SHH
    [ HEX ]  0FF 07 AY!
    [ HEX ]  0FF afxMixPointer @ !
;


\ BINARY 11111101 \ enable left+right audio, select AY1
\ HEX FFFD P!
\ BINARY 00010010 HEX 08 REG! \ Use ABC, enable internal spkr
\ BINARY 11100000 HEX 09 REG! \ Enable mono for AY1-3

DECIMAL

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
    afxNoiseMix 3 [ HEX ] 0FF FILL
;

DECIMAL
 

\ Single effect, file extension .afx
\ Every frame encoded with a flag byte and a number of bytes, 
\ which is vary depending from value change flags.
\   bit0..3  Volume
\   bit4     Disable T
\   bit5     Change Tone
\   bit6     Change Noise
\   bit7     Disable N
\   When the bit5 set, two bytes with tone period will follow; 
\   when the bit6 set, a single byte with noise period will follow; 
\   when both bits are set, first two bytes of tone period, 
\   then single byte with noise period will follow. 
\   When none of the bits are set, next flags byte will follow.
\ End of the effect is marked with byte sequence #D0, #20. 
\ Player should detect it before outputting it to the AY registers, 
\ by checking noise period value to be equal #20. 
\ The editor considers last non-zero volume value as the last frame 
\ of an effect, other parameters aren't matter.

\ emit to channel n current frame pointed by a
\ 1 --> A
\ 2 --> B
\ 3 --> C

: AFXFRAME ( a n -- a )
    3 AND >R                            \ a         R: n

    DUP C@                              \ a b

    \ volume
    DUP                                 \ a b b   
    [ HEX ] 0F AND  7 R@ +  AY!         \ a b
    
    \ disable flag T
    DUP                                 \ a b b
    [ BINARY ] 00010000 [ HEX ] AND     \ a b f
    IF                                  \ a b
        afxMixPointer @ C@              \ a b c
        [ BINARY ] 11111110 [ HEX ]     \ a b c m
        R@ 1- LSHIFT AND                \ a b c
        afxMixPointer @ C!              \ a b
    THEN
    
    \ disable flag N
    DUP                                 \ a b b
    [ BINARY ] 10000000 [ HEX ] AND     \ a b f
    IF                                  \ a b
        afxMixPointer @ C@              \ a b c
        [ BINARY ] 11111011 [ HEX ]     \ a b c m
        R@ LSHIFT AND                   \ a b c
        afxMixPointer @ C!              \ a b
    THEN
     
    \ change tone
    DUP                                 \ a b b 
    [ BINARY ] 00100000 [ HEX ] AND     \ a b f
    IF                                  \ a b 
        SWAP 1+                         \ b a+1
        DUP @                           \ b a+1 n
        R@ 1- AY!!                      \ b a+1
        1+                              \ b a+2
        SWAP                            \ a+3 b
    THEN                                \ a b
    
    \ change noise
    [ BINARY ] 01000000 [ HEX ] AND     \ a f
    IF                                  \ a
        1+                              \ a+1
        DUP C@                          \ a+1 b
        6 AY!                           \ a+1
    THEN

    R> DROP 1+                          \ a+1
    
    afxMixPointer @ C@ 
    7 AY!
;


\ interrupt definition
: AFXWORKER ( -- )
    afxChDesc 
    1+ C@       
    IF
        afxChDesc 
        @
        2 AFXFRAME
        DUP @ [ HEX ] 20D0 =    \ a f
        IF
            DROP 0
        THEN
        afxChDesc 
        !
    THEN    
;


DECIMAL


: AFXPLAY
    4400 BLOCK 
    afxChDesc !
    0 afxMixPointer @ C!
    BEGIN
        ?TERMINAL IF SHH QUIT THEN
        afxChDesc 1+ C@       
    WHILE
        afxworker
        INTERRUPTS ISR-SYNC
    REPEAT
;


FORTH 

