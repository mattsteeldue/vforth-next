\
\ test/defer@.f
\


NEEDS TESTING

NEEDS DEFER
NEEDS DEFER!
NEEDS DEFER@
NEEDS IS

TESTING F.6.2.1177 - DEFER@

T{ DEFER defer4 -> }T
T{ ' * ' defer4 DEFER! -> }T
T{ 2 3 defer4 -> 6 }T
T{ ' defer4 DEFER@ -> ' * }T

T{ ' + IS defer4 -> }T
T{ 1 2 defer4 -> 3 }T
T{ ' defer4 DEFER@ -> ' + }T
