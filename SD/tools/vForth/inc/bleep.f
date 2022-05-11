\
\ bleep.f
\

.( BLEEP ) 

\ BASE @ \ save base status

NEEDS SPEED@
NEEDS SPEED!


\ BLEEP-ROM
\ invokes standard ROM BEEP routine.
\ Input parameters are:
\   n1 = ( 3.5M / Hz - 241 ) / 8 
\   n2 = sec / Hz 
HEX
CODE  BLEEP  ( n1 n2 -- )
    E1 C,                   \ pop hl    ; ms / Hz
    D1 C,                   \ pop de    ; ( 3.5M / Hz - 241 ) / 8 
    C5 C,                   \ push bc
    DD C, E5 C,             \ push ix
    CD C, 03B5 ,            \ call 03B5 ; standard ROM 
    DD C, E1 C,             \ pop ix
    C1 C,                   \ pop bc
    DD C, E9 C, ( NEXT )    \ jp (ix)
SMUDGE 


\ BLEEP-CALC
\ Input parameters are two integers:
\  n1  : duration in millisecond
\  n2  : 8 times sound frequency in Hertz 
\ Output parameters are suitable numbers for BLEEP routine
DECIMAL
: BLEEP-CALC  ( n1 n2 -- n3 n4 )
    >R                      \  ms                   R: 8Hz
    R@ 8000                 \  ms    8Hz   8000     R: 8Hz
    */                      \  s/Hz                 R: 8Hz
\   28000.000               \  s/Hz  28M
\   R> UM/MOD               \  s/Hz  rem   3.5M/Hz  
\   241 -                   \  s/Hz  rem  (3.5M/Hz - 241)
\   3 RSHIFT                \  s/Hz  rem  (3.5M/Hz - 241) / 8
    3500.000                \  s/Hz  3.5M
    R> UM/MOD               \  s/Hz  rem   3.5M/Hz  
    30 -                    \  s/Hz  rem   3.5M/Hz - 30
    NIP                     \  s/Hz  (3.5M/Hz - 241) / 8
;


\ simple 8-bits "12 /MOD" 
HEX
CODE  12/MOD    ( n --  note  octave )
    E1 C,                   \ pop hl    
    AF C,                   \ xor a
    67 C,                   \ ld  h,a     
    5F C,                   \ ld  e,a   ;   quotient
    7D C,                   \ ld  a,l   ;   dividend
    16 C, 0C C,             \ ld  d, 0C ;   divisor
                            \ LABEL:
    1C C,                   \ inc e        
    92 C,                   \ sub d     
    30 C, -4 C,             \ jr  nc, LABEL
    
    82 C,                   \ add a,d
    1D C,                   \ dec e     
    54 C,                   \ ld  d,h   ;   zero on high byte
    6F C,                   \ ld  l,a   ;   remainder
    E5 C,                   \ push hl   ;   note <-- remainder
    D5 C,                   \ push de   ;   octave <-- quotient
    DD C, E9 C, ( NEXT )    \ jp (ix)
SMUDGE 


\ 
VARIABLE OCTAVE


\ this table contains frequencies multiplied by 4.
CREATE FREQ-TABLE
    DECIMAL 
    56320 ,     \ A     14,080.00 Hz  \ 56320
    53159 ,     \ G#    13,289.75 Hz  \ 53159
    50175 ,     \ G     12,543.85 Hz  \ 50175
    47359 ,     \ F#    11,389.82 Hz  \ 47359
    44701 ,     \ F     11,175.30 Hz  \ 44701
    42192 ,     \ E     10,548.08 Hz  \ 42192
    39824 ,     \ D#     9,956.06 Hz  \ 39824
    37589 ,     \ D      9,397.27 Hz  \ 37589
    35479 ,     \ C#     8,869.84 Hz  \ 35479
    33488 ,     \ C      8,372.02 Hz  \ 33488
    31608 ,     \ B      7,902.13 Hz  \ 31608
    29834 ,     \ A#     7,458.62 Hz  \ 29834


\ \ creator for note-frequency of current OCTAVE
\ \ see the following definitions
\ : IS-NOTE   ( n -- cccc )
\     <BUILDS 
\         FREQ-TABLE + @
\     DOES> 
\         C@ 
\         FREQ-TABLE + @ 
\         8 OCTAVE @ - RSHIFT
\ ;


\ DECIMAL         
\     0   IS-NOTE   _A        ( -- freq )    
\     2   IS-NOTE   _Ab       ( -- freq )
\     2   IS-NOTE   _G#       ( -- freq )
\     4   IS-NOTE   _G        ( -- freq )
\     6   IS-NOTE   _Gb       ( -- freq )
\     6   IS-NOTE   _F#       ( -- freq )
\     8   IS-NOTE   _F        ( -- freq )
\    10   IS-NOTE   _E        ( -- freq )
\    12   IS-NOTE   _Eb       ( -- freq )
\    14   IS-NOTE   _D#       ( -- freq )
\    14   IS-NOTE   _D        ( -- freq )
\    16   IS-NOTE   _Db       ( -- freq )
\    16   IS-NOTE   _C#       ( -- freq )
\    18   IS-NOTE   _C        ( -- freq )
\    20   IS-NOTE   _B        ( -- freq )
\    22   IS-NOTE   _Bb       ( -- freq )
\    22   IS-NOTE   _A#       ( -- freq )


\ BEEP-PITCH
\
\ Convert a tone pitch (n1) to 8*freq (n2)
\  0  -->  central C 
\  9  -->  440 Hz  A
\ -3  -->  220 Hz  A  1 octave below
\ 12  -->  C 1 octave above.
: BEEP-PITCH  ( n -- n2 )
    \ pitch is calculated starting from the maximum frequency possible. 
    57 SWAP - ABS       \  57-n 
    12/MOD              \  note  octave
    SWAP CELLS          \  octave note*2
    FREQ-TABLE + @      \  octave freq
    SWAP RSHIFT         \ find the correct octave frequency by halving
;


\
\ standard Basic BEEP emulation
: BEEP ( n1 n2 -- ) 
    BEEP-PITCH 
    BLEEP-CALC 
    SPEED@ >R
    0 SPEED!
    BLEEP
    R> SPEED!
; 

DECIMAL

\ BASE !
