\
\ .S.f
\
.( .S included ) 6 EMIT
\
\ show the stack content without modify it
NEEDS DEPTH
\
: .S ( -- )
    DEPTH IF
        CR 
        SP@  CELL-
        S0 @ CELL-  
        DO
            I @ U.
        -2 +LOOP
    ENDIF 
;
