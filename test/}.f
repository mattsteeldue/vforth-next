\
\ test/}.f
\
\ since filename >.f is illegal.


NEEDS TESTING

( Test Suite - Comparison        )

TESTING F.6.1.0540 -  >

T{        0       1 > -> <FALSE>  }T
T{        1       2 > -> <FALSE>  }T
T{       -1       0 > -> <FALSE>  }T
T{       -1       1 > -> <FALSE>  }T
T{  MIN-INT       0 > -> <FALSE>  }T
T{  MIN-INT MAX-INT > -> <FALSE>  }T
T{        0 MAX-INT > -> <FALSE>  }T
T{        0       0 > -> <FALSE>  }T
T{        1       1 > -> <FALSE>  }T
T{        1       0 > -> <TRUE>   }T
T{        2       1 > -> <TRUE>   }T
T{        0      -1 > -> <TRUE>   }T
T{        1      -1 > -> <TRUE>   }T
T{        1 MIN-INT > -> <TRUE>   }T
T{  MAX-INT MIN-INT > -> <TRUE>   }T
T{  MAX-INT       0 > -> <TRUE>   }T
