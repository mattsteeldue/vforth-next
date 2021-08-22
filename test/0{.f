\
\ test/0{.f
\
\ since filename 0<.f is illegal.


NEEDS TESTING

( Test Suite - Comparison        )

TESTING F.6.1.0250 - 0<

T{        0 0< -> <FALSE> }T
T{       -1 0< -> <TRUE>  }T   \ Because it gives 1
T{  MIN-INT 0< -> <TRUE>  }T   \ Because it gives 1
T{        1 0< -> <FALSE> }T
T{  MAX-INT 0< -> <FALSE> }T

