\
\ holds.f
\

\ Adds the string represented by c-addr u to the pictured numeric output string. 
\ An ambiguous condition exists if HOLDS executes outside of a <# #> delimited 
\ number conversion.

: HOLDS ( a u -- )
    BEGIN 
        DUP 
    WHILE
         1- 2DUP + C@ HOLD 
    REPEAT
    2DROP 
;

