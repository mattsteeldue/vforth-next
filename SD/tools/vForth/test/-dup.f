\
\ test/-dup.f
\
\ since filename ?dup.f is illegal.


NEEDS TESTING

( Test Suite - Stack Operators      )

TESTING F.6.1.0630 - -DUP   ?DUP equivalent

NEEDS -DUP

T{ -1 -DUP -> -1 -1 }T
T{  0 -DUP ->  0    }T
T{  1 -DUP ->  1  1 }T

