\
\ bleep.f
\

.( BLEEP ) 

BASE @ \ save base status

NEEDS SPEED@
NEEDS SPEED!

\ BLEEP 
\ invokes standard ROM BEEP routine.
\ Input parameters are:
\  n1 = sec * Hz              --> de  ( number of cycles )
\  n2 = ( 3.5M/Hz - 241 ) / 8 --> hl  ( timing, i.e. pitch )
\ One second of A (220Hz) is : de=00DC (220), hl=07A7 (1959)
\ i.e.  $00DC $07A7 BLEEP

HEX
CODE  BLEEP  ( n1 n2 -- )
    D9 C,                   \  exx
    E1 C,                   \  pop hl    ; ( 3.5M / Hz - 241 ) / 8 
    D1 C,                   \  pop de    ; s*Hz
    D9 C,                   \ exx
    DD C, E5 C,             \ push ix
    D5 C,                   \ push de
    C5 C,                   \ push bc
    D9 C,                   \  exx

    \ this is some kind of conditional compile.    
    \ we're lucky dot-command ROM call can be done in one single op-code.
    0 +ORIGIN 2000 - NOT 1 AND DF *   \ compile RST $18 if dot-command
    0 +ORIGIN 2000 = NOT 1 AND CD * + \ compile CALL  if not dot-command
       C, 03B5 ,            \  call 03B5 ; standard ROM 

    C1 C,                   \ pop bc
    D1 C,                   \ pop de
    DD C, E1 C,             \ pop ix
    DD C, E9 C, ( NEXT )    \ jp (ix)
SMUDGE 


\ BLEEP-CALC
\ Input parameters are two integers:
\  n1  : duration in milliseconds
\  n2  : sound frequency in Hertz x 8
\ Output parameters are suitable numbers for BLEEP routine
\  n3  : number of cycles = ms * Hz / 1000, unsigned
\  n4  : timing = 437500 / Hz - 30.125, rounded as the ROM's BEEP does
\ Errors:
\  -24 Invalid numeric argument : n2 below 54 (6.75 Hz), timing overflows
\  -11 Result out of range      : more than 65535 cycles, i.e. about
\                                 9 seconds at 7040 Hz, more below
DECIMAL
: BLEEP-CALC  ( n1 n2 -- n3 n4 )
    DUP 54 U< -24 ?ERROR    \  ms  hz8
    >R                      \  ms                  R: hz8
    R@ UM*                  \  ms*hz8 as a double
    DUP 8000 U< 0= -11 ?ERROR
    8000 UM/MOD NIP         \  s*Hz
    R@ 3 UM* 8 UM/MOD NIP   \  s*Hz  3*hz8/8
    3500000. ROT 0 D+       \  s*Hz  3.5M+3*hz8/8
    R> UM/MOD NIP           \  s*Hz  3.5M/hz8+0.375
    30 -                    \  s*Hz  (3.5M/Hz - 241) / 8 , rounded
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


\ this table contains frequencies multiplied by 8.
CREATE FREQ-TABLE 
DECIMAL 
    56320 ,     \ A     7.040,00 Hz  \ 56320 
    53159 ,     \ G#    6.644,88 Hz  \ 53159
    50175 ,     \ G     6.271,93 Hz  \ 50175
    47359 ,     \ F#    5.919,91 Hz  \ 47359
    44701 ,     \ F     5.587,65 Hz  \ 44701
    42192 ,     \ E     5.274,04 Hz  \ 42192
    39824 ,     \ D#    4.978,03 Hz  \ 39824
    37589 ,     \ D     4.698,64 Hz  \ 37589
    35479 ,     \ C#    4.434,92 Hz  \ 35479
    33488 ,     \ C     4.186,01 Hz  \ 33488
    31609 ,     \ B     3.951,07 Hz  \ 31608
    29834 ,     \ A#    3.729,31 Hz  \ 29834
        


\ \ creator for note-frequency of current OCTAVE
\ \ see the following definitions
\ 
\ VARIABLE OCTAVE
\
\ : IS-NOTE   ( n -- cccc )
\     <BUILDS 
\         FREQ-TABLE + @
\     DOES> 
\         C@ 
\         FREQ-TABLE + @ 
\         8 OCTAVE @ - RSHIFT
\ ;


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
DECIMAL         
\ Convert a tone pitch (n1) to 8*freq (n2)
\  0  -->  central C 
\  9  -->  440 Hz  A
\ -3  -->  220 Hz  A  1 octave below
\ 12  -->  C 1 octave above.
\ Valid range is -60 (C, 8.2 Hz) to 57 (A, 7040 Hz), else error -24.
\ BASIC goes up to 69, but 8*freq would not fit in a cell above 57.
: BEEP-PITCH  ( n -- n2 )
    DUP 57 > OVER -60 < OR -24 ?ERROR
    \ pitch is calculated starting from the maximum frequency possible. 
    57 SWAP -           \  57-n 
    12/MOD              \  note  octave
    SWAP CELLS          \  octave note*2
    FREQ-TABLE + @      \  octave freq
    SWAP RSHIFT         \  find the correct octave frequency by n halving
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

BASE !
