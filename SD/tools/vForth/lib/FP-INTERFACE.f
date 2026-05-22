\
\ FP-INTERFACE
\
\ _________________
\
\ Floating point interface
\ _________________

.( FP-INTERFACE )

\ ______________________________________________________________________

\ A floating point number is stored in stack in 4 bytes (HLDE) 
\ instead of the usual 5 bytes, so there is a little precision loss
\ Maybe in the future we'll be able to extend and fix this fact.
\
\ Sign is the msb of H, so you can check for sign in the integer-way.
\ Exponent +128 is stored in the following 8 bits of HL
\ Mantissa is stored in L and 16 bits of DE. B is defaulted.
\ 
\ A floating point number is stored in Spectrum's calculator stack as 5 bytes.
\ Exponent in A, sign in msb of E, mantissa in the rest of E and DCB.
\  H   <->  A    # 0   -> a
\  LDE <->  EDC  # 0DE -> eCD
\  x   <->  B    # x 

MARKER FP-INTERFACE

\ the following three words are coded in assembler but without using ASSEMBLER
\ by directly compiling the Hexadecimal values of these routines.

\ FOP    ( n -- )
\ Floating-Point-Operation.
\ it calls the FP calculator which is a small Stack-Machine
CODE FOP 
    $E1 C,          \ POP     HL|     
    $C5 C,          \ PUSH    BC|
    $D5 C,          \ PUSH    DE|
    $7D C,          \ LD      A'|    L|
    $32 C, HERE 0 , \ LD()A   HERE 0 AA,   
    $EF C,          \ RST     28|
    HERE SWAP !     \         HERE SWAP !  *THIS BYTE IS PATCHED*
    $38 C,          \         HEX 38 C, \ this location is patched each time
    $38 C,          \         HEX 38 C, \ end of calculation
    $D1 C,          \ POP     DE|
    $C1 C,          \ POP     BC|
    $DD C, $E9 C,   \ NEXT
    SMUDGE          \ C;


\ 6E11h
\ >W    ( d -- )
\ pop number from calculator stack and push it to floating-pointer stack 
CODE >W
    $D9 C,          \ EXX
    $E1 C,          \ POP     HL|     
    $D1 C,          \ POP     DE|     
    $CB C, $15 C,   \ RL       L|         \ To keep sign as the msb of H,   
    $CB C, $14 C,   \ RL       H|         \ so you can check for sign in the
    $CB C, $1D C,   \ RR       L|         \ integer-way. Sorry.
    $06 C, $A2 C,   \ LDN     B'|    HEX 00 N,  
    $4B C,          \ LD      C'|    E|    
    $5D C,          \ LD      E'|    L|    
    $7C C,          \ LD      A'|    H|    
    $A7 C,          \ ANDA     A|
    $20 C, 03 C,    \ JRF    NZ'|   HOLDPLACE
    $62 C,          \     LD      H'|    D|  \ swap C and D 
    $51 C,          \     LD      D'|    C|
    $4C C,          \     LD      C'|    H|
                    \ HERE DISP, \ THEN,       
    $CD C, $2AB6 ,  \ CALL    HEX 2AB6 AA,
    $D9 C,          \ EXX
    $DD C, $E9 C,   \ NEXT
    SMUDGE          \ C;


\ 6E33h
\ W>    ( -- d )
\ pop a number from floating-pointer stack and push it to top of calculator stack 
CODE W>
    $D9 C,          \ EXX
    $CD C, $2BF1 ,  \ CALL    HEX 2BF1 AA,
    $A7 C,          \ ANDA     A|
    $20 C, $03 C,   \ JRF    NZ'|   HOLDPLACE
    $62 C,          \     LD      H'|    D|  \ swap C and D 
    $51 C,          \     LD      D'|    C|
    $4C C,          \     LD      C'|    H|
                    \ HERE DISP, \ THEN,       
    $67 C,          \ LD      H'|    A|
    $6B C,          \ LD      L'|    E|
    $59 C,          \ LD      E'|    C|   \ B is lost precision
    $CB C, $15 C,   \ RL       L|         \ To keep sign as the msb of H,
    $CB C, $1C C,   \ RR       H|         \ so you can check for sign in the 
    $CB C, $1D C,   \ RR       L|         \ integer-way. Sorry.
    $D5 C,          \ PUSH DE
    $E5 C,          \ PUSH HL
    $D9 C,          \ EXX
    $DD C, $E9 C, 
    SMUDGE          \ C;

