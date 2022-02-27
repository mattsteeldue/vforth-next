\
\ test/}r.f  
\ 
\ since filename >r.f is illegal.


NEEDS TESTING

( Test Suite - Return Stack Operators )

\ F.6.1.2060 - R>
\ F.6.1.2070 - R@

TESTING F.6.1.0580 - >R - R@ R>

T{ : GR1 >R R> ; -> }T
T{ : GR2 >R R@ R> DROP ; -> }T
T{ 123 GR1 -> 123 }T
T{ 123 GR2 -> 123 }T
T{  1S GR1 ->  1S }T      ( Return stack holds cells )

