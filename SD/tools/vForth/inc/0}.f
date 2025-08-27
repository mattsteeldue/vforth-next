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
    28 C, 04 C,         \ JRF     Z'|    HOLDPLACE
    29 C,               \ ADDHL   HL|
    3F C,               \ CCF
    ED C, 62 C,         \ SBCHL   HL|
                        \ HERE DISP, \ THEN, THEN,
    E5 C,               \ PUSH    HL|
    DD C, E9 C,         \ Next

    FORTH
    SMUDGE

BASE !
