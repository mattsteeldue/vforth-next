\
\ skip.f
\
.( SKIP )
\
\ Skip the leading characters c of the string a n. The result begins
\ at the first character other than c; BL SKIP drops leading spaces.
\ The match is exact, byte by byte: CASEON/CASEOFF play no part.
\
NEEDS /STRING

: SKIP  ( a n c -- a2 n2 )
    >R
    BEGIN
        DUP IF  OVER C@ R@ =  ELSE  0  THEN   \ not empty, still c
    WHILE
        1 /STRING
    REPEAT
    R> DROP
;

