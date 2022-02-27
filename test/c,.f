\
\ test/c,.f
\


NEEDS TESTING

NEEDS CHARS
NEEDS CHAR+

( Test Suite - Memory  )

\ F.6.1.0850  -  C!
\ F.6.1.0870  -  C@
\ F.6.1.0897  -  CHAR+

TESTING F.6.1.0860 - C,

HERE 1 C,
HERE 2 C,
CONSTANT 2NDC
CONSTANT 1STC
T{    1STC 2NDC U< -> <TRUE> }T \ HERE MUST GROW WITH ALLOT
T{      1STC CHAR+ ->  2NDC  }T \ ... BY ONE CHAR
T{  1STC 1 CHARS + ->  2NDC  }T
T{ 1STC C@ 2NDC C@ ->   1 2  }T
T{       3 1STC C! ->        }T
T{ 1STC C@ 2NDC C@ ->   3 2  }T
T{       4 2NDC C! ->        }T
T{ 1STC C@ 2NDC C@ ->   3 4  }T

