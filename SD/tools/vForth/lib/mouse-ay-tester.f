\
\ mouse-ay-TESTER.f
\
.( Mouse AY Tester )

NEEDS .AT
NEEDS CASE
NEEDS MOUSE
NEEDS AY

decimal 

$5C08 constant LASTK

: MOUSE-SHOW ( n1 n2 -- )
    2dup .at 
    ." rx " mouse-rx @ . mouse-ry @ . mouse-rs @ . 7 spaces cr
    2dup swap 1+ swap .at
    ." dx " mouse-dx @ . mouse-dy @ . mouse-ds @ . 7 spaces cr
    2dup swap 2+ swap .at
    ." -- " mouse-x @ .  mouse-y @ .  mouse-s @ .  7 spaces cr
         swap 3 + swap .at
    ." LASTK " LASTK C@ .
;


: KEY-EMU-MOUSE ( c -- )
    case
    [char] 7 of mouse-x @  2-  mouse-x ! endof
    [char] 8 of mouse-y @  2+  mouse-y ! endof
    [char] 5 of mouse-y @  2-  mouse-y ! endof
    [char] 6 of mouse-x @  2+  mouse-x ! endof
          11 of mouse-x @  2-  mouse-x ! endof
           9 of mouse-y @  2+  mouse-y ! endof
           8 of mouse-y @  2-  mouse-y ! endof
          10 of mouse-x @  2+  mouse-x ! endof
    endcase
;


\ simple 8-bits "12 /MOD" 
HEX
CODE  12/MOD    ( n --  note  octave )
    D9 C,                   \  exx
    
    E1 C,                   \  pop hl    
    AF C,                   \  xor a
    67 C,                   \  ld  h,a     
    5F C,                   \  ld  e,a   ;   quotient
    7D C,                   \  ld  a,l   ;   dividend
    16 C, 0C C,             \  ld  d, 0C ;   divisor

                            \ LABEL:
    1C C,                   \  inc e        
    92 C,                   \  sub d     
    30 C, -4 C,             \  jr  nc, LABEL
    
    82 C,                   \  add a,d
    1D C,                   \  dec e     
    54 C,                   \  ld  d,h   ;   zero on high byte
    6F C,                   \  ld  l,a   ;   remainder
    E5 C,                   \  push hl   ;   note <-- remainder
    D5 C,                   \  push de   ;   octave <-- quotient

    D9 C,                   \ exx
    DD C, E9 C, ( NEXT )    \ jp (ix)
SMUDGE 


\ this table contains periods multiplied by 16
\ Clock / Freq
\ Period 

CREATE PERIOD-TABLE
    DECIMAL 
  \ 31818       \ A   110.000  Hz
    63636 ,     \ A    55.000  Hz  
    60065 ,     \ A#   58.270  Hz  
    56694 ,     \ B    61.735  Hz  
    53512 ,     \ C    65.406  Hz  
    50508 ,     \ C#   69.296  Hz  
    47673 ,     \ D    74.416  Hz  
    44998 ,     \ D#   77.781  Hz  
    42472 ,     \ E    82.407  Hz  
    40088 ,     \ F    87.307  Hz  
    37838 ,     \ F#   92.499  Hz  
    35715 ,     \ G    97.999  Hz  
    33710 ,     \ G#  103.826  Hz  


: PLAY-MOUSE ( -- )

    \ evaluate horizontal
    mouse-y @   
    3 RSHIFT                  \ every 8 pixels
    12/MOD >R                 \ calc note and octave
    2* PERIOD-TABLE + @       \ read table 
    R> 7 + RSHIFT             \ calc period
    2 AY!!                    \ Channel B tone
    
    \ let's start from all bit set.
    %11111111 
    \ evaluate vertical displ
    mouse-x @ 3 rshift  8 -  0 max
    ?dup if 
        6 AY!                 \ Noise period (between 0 and 31)
        %00010000 - 
    then
    %00000010 - 
    7 AY!                     \ Flags 0 0  noise [ CBA ] tone [ CBA ]
    15 9 AY!                  \ Channel B volume/envelope (between 0 and 15)
;

: MOUSE-AY-TESTER 
    cls
    8 0 do ." | | | | | " loop
    aysetup
    BEGIN
        interrupts isr-sync
        1 1 MOUSE-SHOW
        mouse-rs @  13 = 
        if
            PLAY-MOUSE
        else
            shh            
        then
        LASTK C@ 
        if 
        \   interrupts isr-di
            CR LASTK C@ KEY-EMU-MOUSE  
            MOUSE-REDRAW 0 LASTK c!
        \   interrupts isr-ei   
        THEN
        ?TERMINAL 
    UNTIL
    SHH
;

DECIMAL FORTH


