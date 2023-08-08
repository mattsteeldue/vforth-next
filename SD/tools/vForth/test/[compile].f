\
\ test/[compile].f
\


NEEDS TESTING

TESTING F.6.2.2530 - [COMPILE]


\ With default compilation semantics
T{ : [c1] [COMPILE] DUP ; IMMEDIATE -> }T
T{ 123 [c1] -> 123 123 }T

\ With an immediate word
T{ : [c2] [COMPILE] [c1] ; -> }T
T{ 234 [c2] -> 234 234 }T

\ With special compilation semantics
T{ : [cif] [COMPILE] IF ; IMMEDIATE -> }T
T{ : [c3]  [cif] 111 ELSE 222 THEN ; -> }T
T{ -1 [c3] -> 111 }T
T{  0 [c3] -> 222 }T
