\
\ test/until.f
\


NEEDS TESTING

( Test Suite - Dictionary  )

TESTING F.6.1.2390 - UNTIL

T{ : GI4 BEGIN DUP 1+ DUP 5 > UNTIL ; -> }T
T{ 3 GI4 -> 3 4 5 6 }T
T{ 5 GI4 -> 5 6 }T
T{ 6 GI4 -> 6 7 }T

