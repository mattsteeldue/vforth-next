\
\ test/depth.f
\
\ since filename ?dup.f is illegal.


NEEDS TESTING

NEEDS DEPTH

( Test Suite - Stack Operators      )

TESTING F.6.1.1200 - DEPTH

\ T{  0 1 DEPTH   START-DEPTH @ -   ->  0 1 2  }T
\ T{  0   DEPTH   START-DEPTH @ -   ->  0 1    }T
\ T{      DEPTH   START-DEPTH @ -   ->  0      }T
\  
\ T{  0 1 DEPTH   ->  0 1 2  START-DEPTH @ +   }T
\ T{  0   DEPTH   ->    0 1  START-DEPTH @ +   }T
\ T{      DEPTH   ->      0  START-DEPTH @ +   }T

\ Mitra Ardron
T{  DEPTH          DEPTH - ->      -1  }T
\ T{  DEPTH  0 SWAP  DEPTH - ->    0 -1  }T
T{  DEPTH   0 SWAP DEPTH - ->  0   -2  }T  
\ T{  DEPTH  0 1 ROT DEPTH - ->  0 1 -2  }T
T{  DEPTH 0 1 ROT  DEPTH - ->  0 1 -3  }T

T{  DEPTH 9 8  ->  9 8 DEPTH 2 - ROT ROT  }T
T{  DEPTH 9    ->  9   DEPTH 1 - SWAP     }T
T{  9 DEPTH    ->  DEPTH 9 SWAP  1 +      }T
T{  9 8 DEPTH  ->  DEPTH 9 8 ROT 2 +      }T

