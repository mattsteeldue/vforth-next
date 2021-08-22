\
\ test/s}d.f  
\ 
\ since filename s>d.f is illegal.


NEEDS TESTING

( Test Suite - Multiplication  )

TESTING F.6.1.2170 - S>D

T{       0 S>D ->       0  0 }T
T{       1 S>D ->       1  0 }T
T{       2 S>D ->       2  0 }T
T{      -1 S>D ->      -1 -1 }T
T{      -2 S>D ->      -2 -1 }T
T{ MIN-INT S>D -> MIN-INT -1 }T
T{ MAX-INT S>D -> MAX-INT  0 }T

