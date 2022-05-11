\
\ test/find.f
\


NEEDS TESTING
NEEDS FIND

( Test Suite - Dictionary  )

TESTING F.6.1.1550 - FIND

\ Before this test you need test '  (tick) and [']
\ this also tests (FIND) the primitive used by FIND and -FIND

HERE 3 C, CHAR G C, CHAR T C, CHAR 1 C, CONSTANT GT1STRING
HERE 3 C, CHAR G C, CHAR T C, CHAR 2 C, CONSTANT GT2STRING
T{ GT1STRING FIND -> ' GT1 -1 }T
T{ GT2STRING FIND -> ' GT2 1  }T
( HOW TO SEARCH FOR NON-EXISTENT WORD? )

TESTING Custom - -FIND

T{ -FIND GT1 -> ' GT1 DUP >BODY NFA C@ 1 }T 
T{ -FIND GT2 -> ' GT2 DUP >BODY NFA C@ 1 }T 
T{ -FIND ~~~ -> 0 }T 
