\
\ dump.f
\
.( DUMP Inspector ) CR
\
DECIMAL
\
: (DUMP)  ( a+4 a -- )
    DO 
        I C@ S->D <# # # #> TYPE SPACE 
    LOOP 
;
\
: DUMP  ( a -- )
    BASE @ SWAP HEX
    DUP 64 + SWAP DO 
        CR
        I S->D <# # # # # #> TYPE 2 SPACES
        I 4 + I     (DUMP) SPACE
        I 8 + I 4 + (DUMP) SPACE
        I 8 + I DO 
            I C@
            127 AND DUP 32 <
            IF  
                SPACE  DROP
            ELSE 
                EMIT 
            THEN 
        LOOP
        ?TERMINAL IF LEAVE THEN
    8 +LOOP 
    BASE ! 
; 
\
DECIMAL
