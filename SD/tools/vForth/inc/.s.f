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
        DEPTH 1+ 1 DO
            S0 @ I CELLS - @ U.
        LOOP
    ENDIF 
;
