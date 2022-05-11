\
\ test/traverse.f
\


NEEDS TESTING

( Test Suite - Dictionary  )

TESTING Custom - TRAVERSE

\ see also NFA PFA CFA LFA

T{ ' DUP >BODY NFA  1     TRAVERSE 1+ -> ' DUP >BODY LFA }T
T{ ' DUP >BODY LFA  1- -1 TRAVERSE    -> ' DUP >BODY NFA }T
