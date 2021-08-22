\
\ test/{.f  
\ 
\ since filename <.f is illegal.


NEEDS TESTING

( Test Suite - Comparison        )

( Test Suite - Comparison        )

TESTING F.6.1.0480 -  <

T{        0       1 < -> <TRUE>   }T
T{        1       2 < -> <TRUE>   }T
T{       -1       0 < -> <TRUE>   }T
T{       -1       1 < -> <TRUE>   }T
T{  MIN-INT       0 < -> <TRUE>   }T
T{  MIN-INT MAX-INT < -> <TRUE>   }T
T{        0 MAX-INT < -> <TRUE>   }T
T{        0       0 < -> <FALSE>  }T
T{        1       1 < -> <FALSE>  }T
T{        1       0 < -> <FALSE>  }T
T{        2       1 < -> <FALSE>  }T
T{        0      -1 < -> <FALSE>  }T
T{        1      -1 < -> <FALSE>  }T
T{        0 MIN-INT < -> <FALSE>  }T
T{  MAX-INT MIN-INT < -> <FALSE>  }T
T{  MAX-INT       0 < -> <FALSE>  }T
