\
\ test/sign.f  
\ 


NEEDS TESTING

( Test Suite - Number Patterns )

TESTING F.6.1.2210 - SIGN

: GP2 <# -1 SIGN 0 SIGN -1 SIGN 0 0 #> S" --" S= ;
T{ GP2 -> <TRUE> }T
