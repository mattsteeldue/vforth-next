\
\ test/2&.f
\
\ since filename 2*.f is illegal.


NEEDS TESTING

( Test Suite - Shifts            )

TESTING F.6.1.0320 - 2*

T{    0S  2*       ->   0S  }T
T{     1  2*       ->    2  }T
T{  4000  2*       -> 8000  }T
T{    1S  2* 1 XOR ->   1S  }T
T{   MSB  2*       ->   0S  }T
