\
\ test/['].f
\


NEEDS TESTING

NEEDS [']

( Test Suite - Dictionary  )

\ F.6.1.1370  -  EXECUTE

TESTING F.6.1.2510 - [']

HEX

\ Before this test you need test '  (tick)
\ this also tests EXECUTE 

T{ : GT2 ['] GT1 ; IMMEDIATE -> }T
T{ GT2 EXECUTE -> 123 }T

