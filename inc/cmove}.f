\
\ cmove}.f
\
.( CMOVE> )
\

BASE @

\ If n > 0, moves memory content starting at address a1 for n bytes long
\ storing then starting at address addr2. 
\ The content of a1 is moved last. See CMOVE.
CODE cmove> ( a1 a2 nc -- )

    HEX 

    D9 C,               \ EXX
    C1 C,               \ POP     BC|
    D1 C,               \ POP     DE|
    E1 C,               \ POP     HL|
    78 C,               \ LD      A'|    B|
    B1 C,               \ ORA      C|
    28 C, 08 C,         \ JRF     Z'| HOLDPLACE
    EB C,               \     EXDEHL
    09 C,               \     ADDHL   BC|
    2B C,               \     DECX    HL|
    EB C,               \     EXDEHL 
    09 C,               \     ADDHL   BC|
    2B C;               \     DECX    HL|
    ED C, B8 C,         \     LDDR  
                        \ HERE DISP, \ THEN,
    D9 C,               \ EXX
    DD C, E9 C,         \ Next
                        \ C;
    FORTH
    SMUDGE

BASE !
