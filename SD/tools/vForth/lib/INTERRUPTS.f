\
\ interrupts.f
\
.( INTERRUPTS ) 
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

\ MARKER TASK

BASE @

\ ____________________________________________________________________

\ inspect current Dictionary Pointer (DP) 
\ and align it to page boundary, so that HERE gives $xy00
HERE $00FF AND NEGATE $00FF AND ALLOT

\ allot 257 bytes vector-table and name it with a constant pointer ISR-TABLE 
HERE DECIMAL 257 ALLOT  CONSTANT ISR-TABLE 

\ find the actual vector, we presume HERE is above $6300, or $8100
\ so that the vector is something like $6363 or $8181
HERE $FF00 AND DUP 8 RSHIFT + CONSTANT ISR-VECTOR    

\ advance DP by 3 bytes beyond ISR-VECTOR
\ to make room for a JP AAAA instruction to later jump to ISR-SUB body
ISR-VECTOR HERE - 3 + ALLOT

\ now there are about one hundred bytes between the vector-table and
\ the isr-vector itself that can be used as temporary stack zone.
\ temporary SP
ISR-VECTOR 2- 
    CONSTANT ISR-SP0
\ temporary RP
ISR-VECTOR DUP $00FF AND 3 5 */ -
    CONSTANT ISR-RP0

\ address used to save SP register during ISR
VARIABLE ISR-SAVE-SP   

\ fill the ISR-TABLE with bytes that points to ISR-VECTOR
ISR-TABLE  DECIMAL 257  ISR-VECTOR $00FF AND  FILL

\ put a JP op-code, the address will be set by ISR-SETUP
$C3 ISR-VECTOR C!

\ ____________________________________________________________________

\ Low-level defs
CODE  ISR-EI  ( -- )
    HEX 
    FB C,                       \ ei
    DD C, E9 C, ( NEXT ) SMUDGE \ jp (ix)


CODE  ISR-DI  ( -- )
    HEX 
    F3 C,                       \ di
    DD C, E9 C, ( NEXT ) SMUDGE \ jp (ix)


CODE  ISR-IM1  ( -- )
    HEX 
    56ED ,                      \ im 1
    DD C, E9 C, ( NEXT ) SMUDGE \ jp (ix)


CODE  ISR-IM2  ( -- )
    HEX 
    5EED ,                      \ im 2
    DD C, E9 C, ( NEXT ) SMUDGE \ jp (ix)


CODE ISR-SYNC  ( -- )
    HEX 
    76 C,                       \ halt
    DD C, E9 C, ( NEXT ) SMUDGE \ jp (ix)


CODE  SETIREG  ( n -- )
    HEX 
    E1 C,                       \ pop hl
    7D C,                       \ ld a,l
    47ED ,                      \ ld i,a
    DD C, E9 C, ( NEXT ) SMUDGE \ jp (ix)



\ Very low level definition
\ ____________________________________________________________________
\
\ return-from-interrupt low-level definition.
\ This definition restores SP, RP, IX and all user registers.
\ IY is not considered since, normally we do not alter it.
\
CODE  ISR-RET  ( -- )
    HEX
\   ED C, 91 C, 56 C, 1F C,     \ nextreg $56, $1F         ;   MMU6
\   ED C, 91 C, 57 C, 20 C,     \ nextreg $57, $20         ;   MMU7
    \ SP
    ED C, 7B C, ISR-SAVE-SP ,   \ ld sp,(ISR-SAVE-SP)
    C1 C, D1 C, E1 C,           \ pop bc, de, hl
    D9 C,                       \ exx
    C1 C, D1 C, E1 C,           \ pop bc, de, hl
    F1 C, 08 C, F1 C,           \ pop af  ex af,af'  pop af
    DD C, E1 C,                 \ pop ix
    FB C,                       \ ei
    C9 C,                       \ ret
SMUDGE

\ ____________________________________________________________________

.( ISR-XT ) 

\ return-from-isr xt
CREATE ISR-XT  ' NOOP , ' ISR-RET ,

\ ____________________________________________________________________
\
\ interrupt service routine handler 
\ the >BODY of this definition is called by CPU's interrupt vector
\
CODE  ISR-SUB  ( -- )
    HEX
    FF C,                       \ rst 38h ( first fulfil standard interrupt )
    F3 C,                       \ di      ( then perform our task )
    DD C, E5 C,                 \ push ix
    F5 C, 08 C, F5 C,           \ push af  ex af,af'  push af
    E5 C, D5 C, C5 C,           \ push hl, de, bc
    D9 C,                       \ exx
    E5 C, D5 C, C5 C,           \ push hl, de, bc
    \ SP
    ED C, 73 C, ISR-SAVE-SP ,   \ ld (ISR-SAVE-SP),sp
    31 C, ISR-SP0 ,             \ ld sp, ISR-SP0
    \ RP
    11 C, ISR-RP0 ,             \ ld de, ISR-RP0
    \ IP
    01 C, ISR-XT ,              \ ld bc, ISR-XT
    \ NEXT
    DD C, 21 C,  (NEXT) ,       \ ld ix, (NEXT)  \ this is safer...
    DD C, E9 C, ( NEXT )        \ jp (ix)
SMUDGE

\ ____________________________________________________________________

HEX

.( ISR-SETUP )

\ enable interrupts to execute user's definition kept in ISR-XT 
: ISR-SETUP  ( -- )
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
;

\ ____________________________________________________________________

.( ISR-OFF )

HEX

\ correctly disable interrupts
: ISR-OFF  ( -- )
    ISR-DI
    3F SETIREG 
    ISR-IM1
    ISR-EI
;

\ ____________________________________________________________________


.( ISR-ON )

: ISR-ON
    ISR-DI
    [ ISR-TABLE 8 RSHIFT ] LITERAL SETIREG 
    ISR-SETUP
    ISR-IM2
    ISR-EI
;

\ ____________________________________________________________________

BASE !

: INTERRUPTS ;

