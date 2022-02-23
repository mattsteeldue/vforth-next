\
\ DEFER.f
\

NEEDS TESTING

NEEDS DEFER
NEEDS DEFER!
NEEDS DEFER@
NEEDS IS


T{ DEFER defer1 -> }T
T{ : action-defer1 ACTION-OF defer1 ; -> }T
T{ ' * ' defer1 DEFER! ->   }T
T{          2 3 defer1 -> 6 }T
T{ ACTION-OF defer1 -> ' * }T
T{    action-defer1 -> ' * }T

T{ ' + IS defer1 ->   }T
T{    1 2 defer1 -> 3 }T
T{ ACTION-OF defer1 -> ' + }T
T{    action-defer1 -> ' + }T

T{ DEFER defer2 ->   }T
T{ ' * ' defer2 DEFER! -> }T
T{   2 3 defer2 -> 6 }T
T{ ' + IS defer2 ->   }T
T{    1 2 defer2 -> 3 }T


T{ DEFER defer3 -> }T
T{ ' * ' defer3 DEFER! -> }T
T{ 2 3 defer3 -> 6 }T

T{ ' + ' defer3 DEFER! -> }T
T{ 1 2 defer3 -> 3 }T

T{ DEFER defer4 -> }T
T{ ' * ' defer4 DEFER! -> }T
T{ 2 3 defer4 -> 6 }T
T{ ' defer4 DEFER@ -> ' * }T

T{ ' + IS defer4 -> }T
T{ 1 2 defer4 -> 3 }T
T{ ' defer4 DEFER@ -> ' + }T

T{ DEFER defer5 -> }T
T{ : is-defer5 IS defer5 ; -> }T
T{ ' * IS defer5 -> }T
T{ 2 3 defer5 -> 6 }T

T{ ' + is-defer5 -> }T
T{ 1 2 defer5 -> 3 }T