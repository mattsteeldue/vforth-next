\
\ test/basic-assumptions.f
\

NEEDS TESTING

( Test Suite - Basic assumptions )
\
TESTING Test Suite - Basic Assumptions
\
T{   ->   }T                ( Start with a clean slate )
( Test if any bits are set; Answer in base 1 )
T{   : BITSSET? IF 0 0 ELSE 0 THEN ; ->   }T
T{   0 BITSSET? -> 0    }T   ( Zero is all bits clear )
T{   1 BITSSET? -> 0 0  }T   ( Other numbers have at least one bit )
T{  -1 BITSSET? -> 0 0  }T
\

