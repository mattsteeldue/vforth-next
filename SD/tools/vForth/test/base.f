\
\ test/base.f  
\ 


NEEDS TESTING

( Test Suite - Number Patterns )

\ F.6.1.1170  -  DECIMAL

TESTING F.6.1.0750  -  BASE

: GN2 \ ( -- 16 10 )
   BASE @ >R HEX BASE @ DECIMAL BASE @ R> BASE ! ;
T{ GN2 -> 10 A }T
