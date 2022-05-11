\
\ test/does}.f
\


NEEDS TESTING

\ F.6.1.1000  -  CREATE

TESTING F.6.1.1250 - DOES> 

\ see also <BUILDS 

T{ : DOES1 DOES> @ 1 + ; -> }T
T{ : DOES2 DOES> @ 2 + ; -> }T
T{ CREATE CR1 -> }T
T{ CR1   -> HERE }T
T{ 1 ,   ->   }T
T{ CR1 @ -> 1 }T

T{ 1 ,   ->   }T  \ vForth needs to repeat this because it still uses <BUILDS

T{ DOES1 ->   }T
T{ CR1   -> 2 }T
T{ DOES2 ->   }T
T{ CR1   -> 3 }T

\ T{ : WEIRD: CREATE DOES> 1 + DOES> 2 + ; -> }T
  T{ : WEIRD: <BUILDS DOES> 1 + DOES> 2 + ; -> }T

T{ WEIRD: W1 -> }T

\ T{ ' W1 >BODY -> HERE     }T
  T{ ' W1 >BODY -> HERE 2 - }T   \ vForth allocates a cell more

\ T{ W1 -> HERE 1 + }T           \ This produces incorrect result.
\ T{ W1 -> HERE 2 + }T           \ This produces incorrect result.

