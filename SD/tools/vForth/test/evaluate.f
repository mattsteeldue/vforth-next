\
\ test/evaluate.f
\

NEEDS TESTING

NEEDS EVALUATE
NEEDS S"

TESTING F.6.1.1360 - EVALUATE

: GE1 S" 123" ; IMMEDIATE
: GE2 S" 123 1+" ; IMMEDIATE
: GE3 S" : GE4 345 ;" ;
: GE5 EVALUATE ; IMMEDIATE

( TEST EVALUATE IN INTERP. STATE )
T{ GE1 EVALUATE -> 123 }T 
T{ GE2 EVALUATE -> 124 }T
T{ GE3 EVALUATE ->     }T
T{ GE4          -> 345 }T

( TEST EVALUATE IN COMPILE STATE )
\
\ it's complicated but EVALUATE doesn't work in compilation at the moment.
\ T{ : GE6 GE1 GE5 ; -> }T 
\ T{ GE6 -> 123 }T

\ T{ : GE7 GE2 GE5 ; -> }T
\ T{ GE7 -> 124 }T

\ See F.9.3.6 for additional test.
