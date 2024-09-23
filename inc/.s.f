\
\ .S.f
\
.( .S )
\
\ show the stack content without modify it
\
: .S ( -- )
    SP@ S0 @ < IF
        CR SP@ S0 @ 2- DO
            I @ U. 
        ?TERMINAL IF LEAVE THEN    
        0 2- +LOOP
    THEN 
;
