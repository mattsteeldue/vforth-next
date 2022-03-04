\
\ test/defer.f
\


NEEDS TESTING

NEEDS DEFER
NEEDS DEFER!
NEEDS DEFER@
NEEDS IS

TESTING F.6.2.1173 - DEFER

T{ DEFER defer2 ->   }T
T{ ' * ' defer2 DEFER! -> }T
T{   2 3 defer2 -> 6 }T
T{ ' + IS defer2 ->   }T
T{    1 2 defer2 -> 3 }T

