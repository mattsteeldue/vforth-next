\
\ test/[char].f
\


NEEDS TESTING

( Test Suite - Characters  )

TESTING F.6.1.2520 - [CHAR]

T{ : GC1 [CHAR] X     ; -> }T
T{ : GC2 [CHAR] HELLO ; -> }T
T{ GC1 -> 58 }T
T{ GC2 -> 48 }T

