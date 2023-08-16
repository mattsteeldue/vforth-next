\
\ interrupts.f
\
.( ISR Handler ) 
\
\ Used in the form:
\
\   ISR-OFF
\   ' cccc ISR-XT !
\   ISR-ON
\
\ set up an interrupt-vector to the  cccc  definition.
\ To use this ISR utility you have to define a suitable word  cccc
\ that can be executed in background in a Interrupt-Driven way
\

BASE @

MARKER FORGET-INTERRUPTS

\ ____________________________________________________________________

VOCABULARY INTERRUPTS IMMEDIATE

INTERRUPTS DEFINITIONS 

\ ____________________________________________________________________

HEX 

CODE  ISR-EI  ( -- )
    FB C,                       \ ei
    DD C, E9 C, ( NEXT ) SMUDGE \ jp (ix)


CODE  ISR-DI  ( -- )
    F3 C,                       \ di
    DD C, E9 C, ( NEXT ) SMUDGE \ jp (ix)


CODE  ISR-IM1  ( -- )
    56ED ,                      \ im 1
    DD C, E9 C, ( NEXT ) SMUDGE \ jp (ix)


CODE  ISR-IM2  ( -- )
    5EED ,                      \ im 2
    DD C, E9 C, ( NEXT ) SMUDGE \ jp (ix)


CODE ISR-SYNC  ( -- )
    76 C,                       \ halt
    DD C, E9 C, ( NEXT ) SMUDGE \ jp (ix)


CODE  SETIREG  ( n -- )
    E1 C,                       \ pop hl
    7D C,                       \ ld a,l
    47ED ,                      \ ld i,a
    DD C, E9 C, ( NEXT ) SMUDGE \ jp (ix)

\ very low level definition

\ ____________________________________________________________________


HEX 6302 CONSTANT ISR-SAVE      \ address used to save SP register during ISR
HEX 6200 CONSTANT ISR-TABLE     \ 257 bytes IM2 vector table 
HEX 6363 CONSTANT ISR-VECTOR    \ new ISR address
HEX 0038 CONSTANT ISR-HANDLER   \ standard ISR handler


\ ____________________________________________________________________
\
\ return-from-interrupt low-level definition.
\ This definition restores SP, RP, IX and all user registers.
\ IY is not considered since, normally we do not alter it.
\
CODE  ISR-RET  ( -- )
    \ SP
    ED C, 7B C, ISR-SAVE ,      \ ld sp,(ISR-SAVE)
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

\ ____________________________________________________________________

FORTH DEFINITIONS 

.( ISR-XT ) 

\ return-from-isr xt
CREATE ISR-XT  INTERRUPTS  ' ISR-RET  DUP , ,

INTERRUPTS DEFINITIONS 

\ ____________________________________________________________________
\
\ interrupt service routine handler 
\ the >BODY of this definition is called by CPU's interrupt vector
\
CODE  ISR-SUB  ( -- )
    FF C,                       \ rst 38h ( first fulfil standard interrupt )
    F3 C,                       \ di      ( then perform our task )
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
    \ RP
    EB C,                       \ ex de,hl
    \ SP
    ED C, 73 C, ISR-SAVE ,      \ ld (ISR-SAVE),sp
    21 C, -04 ,                 \ ld hl,-04
    39 C, ( ADD HL,SP )         \ add hl,sp
    F9 C, ( LD  SP,HL  )        \ ld sp,hl
    \
    01 C, ISR-XT ,              \ ld bc, ISR-XT
    \
    DD C, 21 C,  (NEXT) ,       \ ld ix, (NEXT)  \ this is safer...
    DD C, E9 C, ( NEXT )        \ jp (ix)
    \
SMUDGE

\ ____________________________________________________________________

FORTH DEFINITIONS

HEX

.( ISR-ON )

\ enable interrupts to execute user's definition kept in ISR-XT 
: ISR-ON  ( -- )
    INTERRUPTS
    ISR-DI
    \ ISR-HANDLER ISR-TABLE ! 
    
    \ setup vector table
    ISR-VECTOR ISR-TABLE ! 
    ISR-TABLE  DUP 2+ 00FF CMOVE   
    
    \ put jp op-code at ISR-VECTOR address, to jump to ISR-SUB address
    C3 ISR-VECTOR C!   
    
    \ The start-address code of ISR-SUB depends on which version
    \ we have between Direct vs Indirect threaded core.
    \ The following calculation determines if the address the ISR jumps to
    \ is the CFA or CFA >BODY
    [   ' ISR-SUB >BODY DUP 
        ' ISR-SUB - 1- 2/ 3 * -
    ] LITERAL ISR-VECTOR 1+ !
    
    \ New Hardware Next's interrupt facility
    \ ISR-VECTOR ISR-TABLE 11 CELLS + !
    \ ISR-TABLE  %11100000 AND %00000001 OR  C0  REG!
    \ %10000001 C4 REG! \ enable expansion bus INT and ULA interrupts
    \ %00000000 C5 REG! \ disable all CTC channel interrupts
    \ %00000000 C6 REG! \ disable UART interrupts
    
    ISR-TABLE 8 RSHIFT SETIREG 
    ISR-IM2
    ISR-EI
;

\ ____________________________________________________________________

.( ISR-OFF )

\ correctly disable interrupts
: ISR-OFF  ( -- )
    INTERRUPTS
    ISR-DI
    ISR-HANDLER ISR-VECTOR 1+ !
    3F SETIREG 
    ISR-IM1
    ISR-EI
;

\ ____________________________________________________________________

FORTH DEFINITIONS


: NO-INTERRUPTS
  ISR-OFF
  FORGET-INTERRUPTS
;


BASE !
