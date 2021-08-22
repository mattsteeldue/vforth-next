\
\ test/u{.f
\
\ since filename U<.f is illegal.


NEEDS TESTING

( Test Suite - Comparison        )

TESTING F.6.1.2340 -  U<
T{         0        1 U< -> <TRUE>   }T
T{         1        2 U< -> <TRUE>   }T
T{         0 MID-UINT U< -> <TRUE>   }T
T{         0 MAX-UINT U< -> <TRUE>   }T
T{  MID-UINT MAX-UINT U< -> <TRUE>   }T
T{         0        0 U< -> <FALSE>  }T
T{         1        1 U< -> <FALSE>  }T
T{         1        0 U< -> <FALSE>  }T
T{         2        1 U< -> <FALSE>  }T
T{  MID-UINT        0 U< -> <FALSE>  }T
T{  MAX-UINT        0 U< -> <FALSE>  }T
T{  MID-UINT MID-UINT U< -> <FALSE>  }T

