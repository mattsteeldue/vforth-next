\
\ test/rshift.f
\

NEEDS TESTING

( Test Suite - Numeric Notation  )

TESTING Numeric Notation

\ implementation of NUMBER in v-Forth is very simple and it cannot handle 
\ prefix such as those used in the following tests.
\ DECIMAL
\ T{ #1289       -> 1289        }T
\ T{ #12346789.  -> 12346789.   }T
\ T{ #-1289      -> -1289       }T
\ T{ #-12346789. -> -12346789.  }T
\ T{ $12eF       -> 4847        }T
\ T{ $12aBcDeF.  -> 313249263.  }T
\ T{ $-12eF      -> -4847       }T
\ T{ $-12AbCdEf. -> -313249263. }T
\ T{ %10010110   -> 150         }T
\ T{ %10010110.  -> 150.        }T
\ T{ %-10010110  -> -150        }T
\ T{ %-10010110. -> -150.       }T
\ T{ 'z'         -> 122         }T

T{  DECIMAL  1289       ->  DECIMAL  1289       }T
T{  DECIMAL  123456789. ->  DECIMAL 52501  1883 }T
T{  DECIMAL -1289       ->  DECIMAL -1289       }T
T{  DECIMAL -123456789. ->  DECIMAL 13035 63652 }T

T{  HEX      12eF       ->  DECIMAL       4847  }T
T{  HEX      12aBcDeF.  ->  DECIMAL  313249263. }T
T{  HEX     -12eF       ->  DECIMAL      -4847  }T
T{  HEX     -12aBcDeF.  ->  DECIMAL -313249263. }T

NEEDS BINARY 

T{  BINARY   10010110   ->  DECIMAL  150        }T
T{  BINARY   10010110.  ->  DECIMAL  150.       }T
T{  BINARY  -10010110   ->  DECIMAL -150        }T
T{  BINARY  -10010110.  ->  DECIMAL -150.       }T

T{  CHAR    z           ->  DECIMAL  122        }T

HEX

