\
\ test/max.f
\


NEEDS TESTING

( Test Suite - Comparison        )

TESTING F.6.1.1880 - MAX

T{        0       1 MAX ->       1  }T
T{        1       2 MAX ->       2  }T
T{       -1       0 MAX ->       0  }T
T{       -1       1 MAX ->       1  }T
T{  MIN-INT       0 MAX ->       0  }T
T{  MIN-INT MAX-INT MAX -> MAX-INT  }T
T{        0 MAX-INT MAX -> MAX-INT  }T
T{        0       0 MAX ->       0  }T
T{        1       1 MAX ->       1  }T
T{        2       1 MAX ->       2  }T
T{        0      -1 MAX ->       0  }T
T{        1      -1 MAX ->       1  }T
T{        0 MIN-INT MAX ->       0  }T
T{  MAX-INT MIN-INT MAX -> MAX-INT  }T
T{  MAX-INT       0 MAX -> MAX-INT  }T
