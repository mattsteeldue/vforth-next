\
\ words.f  
\
.( WORDS )
\

: WORDS  ( -- )
    [ DECIMAL 128 ] LITERAL OUT !
    CONTEXT @ @
    BEGIN
        DUP C@ [ HEX 1F ] LITERAL AND  
        OUT @ +  
        C/L < 0=
        IF 
            CR 
            0 OUT ! 
        THEN
        DUP ID.
        PFA LFA @ 
        DUP 0= 
        ?TERMINAL OR 
    UNTIL
    DROP
    ;


