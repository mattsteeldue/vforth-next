\
\ NOT.f
\
.( NOT )
\

BASE @

\ true (-1) if n is zero, false (0) elsewere
CODE NOT ( n -- f )
         
    E1 C,               \ POP     HL|
    7D C,               \ LD      A'|    L|
    B4 C,               \ ORA      H|
    21 C, 0 ,           \ LDX     HL|    0 NN,
    20 C, 01 C,         \ JRF    NZ'|    HOLDPLACE
    2B C,               \     DECX      HL|           \ true
                        \ HERE DISP, \ THEN,
    E5 C,               \ PUSH    HL|
    DD C, E9 C,         \ Next

    FORTH
    SMUDGE

BASE !
