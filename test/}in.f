\
\ test/}in.f
\


NEEDS TESTING

NEEDS EVALUATE
NEEDS S"

( Test Suite - Parser Input Source Control )

TESTING F.6.1.0560 - >IN 

VARIABLE SCANS
: RESCAN? -1 SCANS +! SCANS @ IF 0 >IN ! THEN ;
T{   2 SCANS ! 
345 RESCAN? 
-> 345 345 }T

\ *** N.B. nested EVALUATE still has bug ***
\ we have to split the GS2 test in two lines

: GS2 5 SCANS ! S" 123 RESCAN?" EVALUATE ; 
T{ GS2 
-> 123 123 123 123 123 }T

\ These tests must start on a new line
DECIMAL

\ T{ 023456 DEPTH OVER 9 < 35 AND + 3 + >IN !
\ -> 023456 23456 3456 456 56 6 }T

T{ 14145 8115 ?DUP 0= 34 AND >IN +! TUCK MOD 14 >IN ! GCD calculation
-> 15 }T

HEX

