\
\ scan.f
\
.( SCAN )
\
\ Look for the character c in the string a n. The result begins at the
\ first c found, or is the empty string at a+n when there is none.
\ The match is exact, byte by byte: CASEON/CASEOFF play no part.
\
NEEDS /STRING

: SCAN  ( a n c -- a2 n2 )
    >R
    BEGIN
        DUP IF  OVER C@ R@ -  ELSE  0  THEN   \ not empty, not yet c
    WHILE
        1 /STRING
    REPEAT
    R> DROP
;

