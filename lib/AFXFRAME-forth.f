\
\ AFXFRAME.F
\
.( AFXFRAME )

NEEDS BINARY            \ base 2
NEEDS SPLIT             \ split an integer into two bytes, low, high.
NEEDS AY
NEEDS MS


BASE @

MARKER TASK

DECIMAL
        \ (E)=noise, (D)=mixer 
VARIABLE AFX-MIXER

CREATE   AFX-CH-DESC 36 ALLOT
         AFX-CH-DESC 36 ERASE

VARIABLE AFX-PTR

\ +0 current pointer  (channel is frEe if high byte #00
\ +2 effect time
\ 
\ Every frame is encoded with a flags-byte and a number of data bytes 
\ depending from value change flags (from 0 to 3)
\  bit0..3  Volume
\  bit4     Disable T
\  bit5     Change Tone
\  bit6     Change Noise
\  bit7     Disable N
\ 

HEX


: AYPLAY ( b i -- )
    1 AFX-PTR +!            \ b
    
    \ send volume
    DUP 0F AND I 8 + AY!    \ b            ( reg. 8, 9, 10 )
    
    \ tone changes
    DUP 10 AND              \ b   f
    IF
        AFX-PTR @ @         \ b
        0FFF AND I 2* AY!!  \ b            ( reg. 0, 2, 4 )
        2 AFX-PTR +!        \ b   u
    THEN
    
    \ noise changes
    DUP 20 AND              \ b   f
    IF          
        AFX-PTR @ C@        \ b   u2
        1F AND 6 AY!        \ b              
        1 AFX-PTR +!        \ b
    THEN
    
    \ mixer
    4 I - RSHIFT            \ b
    AFX-MIXER @             \ b m
    OVER XOR                \ b m^b
    0FF6F                   
    4 I - RSHIFT            
    AND 
    XOR
    DUP 7 AY!
    AFX-MIXER ! 
;


: AFX>AY ( i -- )
    >R
    AFX-PTR C@              \ b
    .S DUP EMIT 

    \ send volume
    DUP 0F AND              \
    ." data " . CR
\   I 8 + AY!               \ b            ( reg. 8, 9, 10 )
    1 AFX-PTR +!            \ b

\   \ tone changes
\   DUP 10 AND              \ b   f
\   IF
\       AFX-PTR @ @         \ b
\       0FFF AND I 2* AY!!  \ b            ( reg. 0, 2, 4 )
\       2 AFX-PTR +!        \ b   u
\   THEN
\   
\   \ noise changes
\   DUP 20 AND              \ b   f
\   IF          
\       AFX-PTR @ C@        \ b   u2
\       1F AND 6 AY!        \ b              
\       1 AFX-PTR +!        \ b
\   THEN

    AFX-PTR @ AFX-CH-DESC !
    R> DROP
;


: AFXFRAME ( -- )
\   [ DECIMAL ] 36 0 DO
\       ." AY" I 1+ .
\       I                                
        1 0 DO
            AFX-CH-DESC                     \ a
\           +                               \ a     ( desc, +12, +24 )
            I 2 LSHIFT +                    \ a     ( desc, +4, +8
            DUP @                           \ a a1
            \ process only address higher than
            DUP [ HEX ] 00FF U< NOT         \ a a1  f  
            IF                              \ a a1
                DUP AFX-PTR !               \ a a1 
                @                           \ a b
                [ HEX ] 20D0 =              \ a f
                IF                          \ a
                    0 SWAP !                \
                ELSE  
                    \ [CHAR] A I + EMIT SPACE         \ 
                    \ DROP I AFX>AY           \ i
                    .S
                    AFX-PTR C@ .
                    1 SWAP +!
                THEN 
            ELSE
                2DROP
            THEN \ address no good
        LOOP    
\   [ DECIMAL ] 12 +LOOP
;



decimal 
: test
    4430 block c/l + afx-ch-desc ! 
    10 0 do
        afxframe
        10 ms
    loop
;
        

DECIMAL
FORTH DEFINITIONS
BASE !
