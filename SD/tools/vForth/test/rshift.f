\
\ test/rshift.f
\


NEEDS TESTING

( Test Suite - Shifts            )

TESTING F.6.1.2162 - RSHIFT

T{     1 0 RSHIFT  ->    1  }T
T{     1 1 RSHIFT  ->    0  }T
T{     2 1 RSHIFT  ->    1  }T
T{     4 2 RSHIFT  ->    1  }T
T{  8000 F RSHIFT  ->    1  }T \ biggest
T{   MSB 1 RSHIFT MSB AND ->   0  }T
T{   MSB 1 RSHIFT     2*  -> MSB  }T   
