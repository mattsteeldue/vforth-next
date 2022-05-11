\
\ test/literal.f
\


NEEDS TESTING

( Test Suite - Dictionary  )

TESTING F.6.1.1780 - LITERAL

\ Before this test you need test ['] 
\ this also tests LIT the primitive compiled by LITERAL

T{ : GT3 GT2 LITERAL ; -> }T
T{ GT3 -> ' GT1 }T

