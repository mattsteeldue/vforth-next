\
\ test/basic-assumptions.f
\


NEEDS TESTING

( Test Suite - Basic assumptions )
\
TESTING Test Suite - Basic Assumptions
\
T{   ->   }T
T{   : BITSSET? IF 0 0 ELSE 0 THEN ; ->   }T
T{   0 BITSSET? -> 0    }T
T{   1 BITSSET? -> 0 0  }T
T{  -1 BITSSET? -> 0 0  }T
\

