\
\ test/fm%mod.f  
\ 
\ since filename fm/mod.f is illegal.


NEEDS TESTING

NEEDS FM/MOD

( Test Suite - Division  )

TESTING F.6.1.1561 - FM/MOD

T{       0 S>D              1 FM/MOD ->  0       0 }T
T{       1 S>D              1 FM/MOD ->  0       1 }T
T{       2 S>D              1 FM/MOD ->  0       2 }T
T{      -1 S>D              1 FM/MOD ->  0      -1 }T
T{      -2 S>D              1 FM/MOD ->  0      -2 }T
T{       0 S>D             -1 FM/MOD ->  0       0 }T
T{       1 S>D             -1 FM/MOD ->  0      -1 }T
T{       2 S>D             -1 FM/MOD ->  0      -2 }T
T{      -1 S>D             -1 FM/MOD ->  0       1 }T
T{      -2 S>D             -1 FM/MOD ->  0       2 }T
T{       2 S>D              2 FM/MOD ->  0       1 }T
T{      -1 S>D             -1 FM/MOD ->  0       1 }T
T{      -2 S>D             -2 FM/MOD ->  0       1 }T
T{       7 S>D              3 FM/MOD ->  1       2 }T
T{       7 S>D             -3 FM/MOD -> -2      -3 }T
T{      -7 S>D              3 FM/MOD ->  2      -3 }T
T{      -7 S>D             -3 FM/MOD -> -1       2 }T
T{ MAX-INT S>D              1 FM/MOD ->  0 MAX-INT }T
T{ MIN-INT S>D              1 FM/MOD ->  0 MIN-INT }T
T{ MAX-INT S>D        MAX-INT FM/MOD ->  0       1 }T
T{ MIN-INT S>D        MIN-INT FM/MOD ->  0       1 }T
T{    1S 1                  4 FM/MOD ->  3 MAX-INT }T
T{       1 MIN-INT M*       1 FM/MOD ->  0 MIN-INT }T
T{       1 MIN-INT M* MIN-INT FM/MOD ->  0       1 }T
T{       2 MIN-INT M*       2 FM/MOD ->  0 MIN-INT }T
T{       2 MIN-INT M* MIN-INT FM/MOD ->  0       2 }T
T{       1 MAX-INT M*       1 FM/MOD ->  0 MAX-INT }T
T{       1 MAX-INT M* MAX-INT FM/MOD ->  0       1 }T
T{       2 MAX-INT M*       2 FM/MOD ->  0 MAX-INT }T
T{       2 MAX-INT M* MAX-INT FM/MOD ->  0       2 }T
T{ MIN-INT MIN-INT M* MIN-INT FM/MOD ->  0 MIN-INT }T
T{ MIN-INT MAX-INT M* MIN-INT FM/MOD ->  0 MAX-INT }T
T{ MIN-INT MAX-INT M* MAX-INT FM/MOD ->  0 MIN-INT }T
T{ MAX-INT MAX-INT M* MAX-INT FM/MOD ->  0 MAX-INT }T

