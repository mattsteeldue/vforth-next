\
\ test/min.f
\


NEEDS TESTING

( Test Suite - Comparison        )

TESTING F.6.1.1880 - MIN

T{        0       1 MIN ->       0  }T
T{        1       2 MIN ->       1  }T
T{       -1       0 MIN ->      -1  }T
T{       -1       1 MIN ->      -1  }T
T{  MIN-INT       0 MIN -> MIN-INT  }T
T{  MIN-INT MAX-INT MIN -> MIN-INT  }T
T{        0 MAX-INT MIN ->       0  }T
T{        0       0 MIN ->       0  }T
T{        1       1 MIN ->       1  }T
T{        2       1 MIN ->       1  }T
T{        0      -1 MIN ->      -1  }T
T{        1      -1 MIN ->      -1  }T
T{        0 MIN-INT MIN -> MIN-INT  }T
T{  MAX-INT MIN-INT MIN -> MIN-INT  }T
T{  MAX-INT       0 MIN ->       0  }T
