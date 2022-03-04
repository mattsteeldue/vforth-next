\
\ test/defer!.f
\


NEEDS TESTING

NEEDS DEFER
NEEDS DEFER!
NEEDS DEFER@
NEEDS IS

TESTING F.6.2.1175 - DEFER!

T{ DEFER defer3 -> }T
T{ ' * ' defer3 DEFER! -> }T
T{ 2 3 defer3 -> 6 }T

T{ ' + ' defer3 DEFER! -> }T
T{ 1 2 defer3 -> 3 }T

