\
\ test/is.f
\


NEEDS TESTING

NEEDS DEFER
NEEDS DEFER!
NEEDS DEFER@
NEEDS IS

TESTING F.6.2.1725 - IS

T{ DEFER defer5 -> }T
T{ : is-defer5 IS defer5 ; -> }T
T{ ' * IS defer5 -> }T
T{ 2 3 defer5 -> 6 }T

T{ ' + is-defer5 -> }T
T{ 1 2 defer5 -> 3 }T
