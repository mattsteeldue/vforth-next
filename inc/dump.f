\
\ dump.f
\
.( DUMP )
\
BASE @

DECIMAL
\
: (DMP)  ( a+4 a -- )
    DO 
        I C@ S>D <# # # #> TYPE SPACE 
    LOOP 
;

\
: DUMP  ( a u -- )
    BASE @ >R 
    HEX
    OVER + SWAP DO 
        CR
        I S>D <# # # # # #> TYPE 2 SPACES
        I 4 + I     (DMP) SPACE
        I 8 + I 4 + (DMP) SPACE
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
    R> BASE ! 
; 
\
BASE !
