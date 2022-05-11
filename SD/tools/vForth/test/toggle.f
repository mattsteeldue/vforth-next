\
\ test/toggle.f
\


NEEDS TESTING

( Test Suite - Memory  )

TESTING Custom - TOGGLE

\ Before this test you need test ,  (comma)

T{  0 1ST !        ->   }T
T{  1ST 1 TOGGLE   ->   }T
T{    1ST @        -> 1 }T
T{  1ST 1 TOGGLE   ->   }T
T{    1ST @        -> 0 }T

