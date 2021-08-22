\
\ test/rshift.f
\


NEEDS TESTING

( Test Suite - Numeric Notation  )

TESTING Numeric Notation

DECIMAL 

T{  #1289        -> 1289        }T
T{  #123456789.  -> 123456789.  }T
T{  #-1289       -> -1289       }T
T{  #-123456789. -> 123456789.  }T
T{  $12eF        -> 4847        }T
T{  $12aBcDeF    -> 313249263.  }T
T{  $-12eF       -> 4847        }T
T{  $-12aBcDeF   -> 313249263.  }T
T{  %10010110    -> 150         }T
T{  %10010110.   -> 150.        }T
T{  %-10010110   -> 150         }T
T{  %-10010110.  -> 150.        }T
T{  'z'          -> 122         }T

HEX
