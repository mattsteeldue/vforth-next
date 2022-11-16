\
\ 0>.f
\
.( 0> )
\

BASE @

\ true (-1) if n is greater than zero, false (0) elsewere
CODE 0> ( n -- f )
         
    HEX 

    E1 C,               \ POP     HL|
    7D C,               \ LD      A'|    L|
    B4 C,               \ ORA      H|
    29 C,               \ ADDHL   HL|
    21 C, 0 ,           \ LDX     HL|    0 NN,
    38 C, 04 C,         \ JRF    CY'|    HOLDPLACE    
    A7 C,               \ ANDA     A|
    28 C, 01 C,         \ JRF     Z'|    HOLDPLACE
    2B C,               \     DECX      HL|           \ true
                        \ HERE DISP, HERE DISP, \ THEN, THEN,
    E5 C,               \ PUSH    HL|
    DD C, E9 C,         \ Next

    FORTH
    SMUDGE

BASE !
