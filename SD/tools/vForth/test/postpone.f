\
\ test/postpone.f
\


NEEDS TESTING

NEEDS POSTPONE  

( Test Suite - Dictionary  )

TESTING F.6.1.2033 - POSTPONE

\ GT1 is defined in   test/'.f  F.6.1.0070 - ' test case.

T{ : GT4 POSTPONE GT1 ; IMMEDIATE -> }T
T{ : GT5 GT4 ; -> }T
T{ GT5 -> 123 }T

T{ : GT6 345 ; IMMEDIATE -> }T
T{ : GT7 POSTPONE GT6 ; -> }T
T{ GT7 -> 345 }T

