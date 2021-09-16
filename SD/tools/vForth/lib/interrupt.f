\
\ interrupt.f
\
.( INTERRUPT Handler ) 
\

VOCABULARY INTERRUPT IMMEDIATE

INTERRUPT DEFINITIONS

\ To use this ISR utility you have to define a suitable word 
\ that can be executed in background in a Interrupt-Driven way



HEX

CODE  INT-EI
    FB C,                       \ ei
    DD C, E9 C, ( NEXT ) SMUDGE \ jp (ix)


CODE  INT-DI
    F3 C,                       \ di
    DD C, E9 C, ( NEXT ) SMUDGE \ jp (ix)


CODE  INT-IM1
    56ED ,                      \ im 1
    DD C, E9 C, ( NEXT ) SMUDGE \ jp (ix)


CODE  INT-IM2
    5EED ,                      \ im 2
    DD C, E9 C, ( NEXT ) SMUDGE \ jp (ix)


CODE INT-SYNC
    76 C,                       \ halt
    DD C, E9 C, ( NEXT ) SMUDGE \ jp (ix)


CODE  SETIREG
    E1 C,                       \ pop hl
    7D C,                       \ ld a,l
    47ED ,                      \ ld i,a
    DD C, E9 C, ( NEXT ) SMUDGE \ jp (ix)


\ address used to save SP register during ISR
6302  CONSTANT INT-SAVE


\ return-from-interrupt low-level definition.
\ this word restores SP, RP, IX and all registers and alternate registers.
\ IY is not considered since, normally we do not alter it.
CODE  INT-RET
    ED C, 7B C, INT-SAVE ,      \ ld sp,(INT-SAVE)
    E1 C,                       \ pop hl
    22 C, 30 +ORIGIN ,          \ ld (RP), hl
    C1 C, D1 C, E1 C,           \ pop bc, de, hl
    D9 C,                       \ exx
    C1 C, D1 C, E1 C,           \ pop bc, de, hl
    F1 C, 08 C, F1 C,           \ pop af  ex af,af'  pop af
    DD C, E1 C,                 \ pop ix
    FB C,                       \ ei
    C9 C,                       \ ret
SMUDGE


' INT-RET                \ return handler

FORTH DEFINITIONS

  VARIABLE  INT-W        \ word of interrupt handler

INTERRUPT DEFINITIONS

' INT-RET ,              \ followed by INT-RET


CODE  INT-SUB
    FF C,                       \ rst 38h
    DD C, E5 C,                 \ push ix
    F5 C, 08 C, F5 C,           \ push af  ex af,af'  push af
    E5 C, D5 C, C5 C,           \ push hl, de, bc
    D9 C,                       \ exx
    E5 C, D5 C, C5 C,           \ push hl, de, bc
    \ RP
    2A C, 30 +ORIGIN ,          \ ld hl,(RP)
    E5 C,                       \ push hl
    \
    21 C, 6330 ,                \ ld hl,6330h
    22 C, 30 +ORIGIN ,          \ ld (RP),hl
    \ SP
    ED C, 73 C, INT-SAVE ,      \ ld (INT-SAVE),sp
    21 C, -04 ,                 \ ld hl,-04
    39 C, ( ADD HL,SP )         \ add hl,sp
    F9 C, ( LD  SP,HL  )        \ ld sp,hl
    \
    01 C, INT-W ,               \ ld bc, INT-W
    \
    DD C, 21 C,  (NEXT) ,       \ ld ix, (NEXT)
    DD C, E9 C, ( NEXT )        \ jp (ix)
    \
SMUDGE


FORTH DEFINITIONS

: INT-ON
    63 6200 C! 6200 6201 100 CMOVE   \ setup vector table
    C3 6363 C!   \ jp to INT-SUB address
    INTERRUPT
    [ ' INT-SUB >BODY ] LITERAL 6364 !
    INT-DI
    62 SETIREG INT-IM2
    INT-EI
;


: INT-OFF
    INTERRUPT
    INT-DI
    0038 6364 !
    3F SETIREG INT-IM1
    INT-EI
;

FORTH

DECIMAL

