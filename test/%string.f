\
\ test/%string.f
\

NEEDS TESTING

TESTING String - /STRING

T{ S1 0 /STRING -> S1 }T
T{ S1 2 /STRING -> S1 DROP 2 + 11 }T
T{ S1 13 /STRING -> S1 + 0 }T
T{ S1 2 /STRING -2 /STRING -> S1 }T

