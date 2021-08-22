\
\ .S.f
\
.( .S ) 
\
\ show the stack content without modify it
NEEDS DEPTH
\
: .S ( -- )
    DEPTH IF
        CR 
        SP@  S0 @ CELL-  
        DO
            I @ .
        -2 +LOOP
    ENDIF 
;
