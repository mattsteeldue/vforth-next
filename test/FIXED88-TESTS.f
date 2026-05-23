\
\ FIXED-TESTS.f
\

MARKER TESTING-TASK

NEEDS TESTING

NEEDS FIXED88

TESTING \ ZX Spectrum Floating-Point interface

DECIMAL

T{  3 >FP   4 >FP   F-       ->   -1 >FP  }T
T{  3 >FP   4 >FP   F*       ->   12 >FP  }T
T{  3 >FP   4 >FP   F/       ->    1 >FP  }T
T{  3 >FP   4 >FP   F+       ->    7 >FP  }T
T{  3 >FP   4 >FP   FNEGATE  ->    3 >FP  }T
T{  3 >FP   4 >FP   FSGN     ->    3 >FP  }T
T{  3 >FP   4 >FP   FABS     ->    3 >FP  }T
T{  3 >FP   4 >FP   F/MOD    ->    3 >FP  }T
T{  3 >FP   4 >FP   F**      ->    9 >FP  }T
                                        
T{  1. FLN               ->    0.              }T
T{  PI FEXP  FLN         ->    PI              }T
T{  PI FSQRT 2DUP F*     ->    PI              }T
T{  PI FINT              ->    3.              }T

T{  0. FSIN              ->    0.              }T
T{  0. FCOS              ->    2. 2. F/        }T
T{  PI FTAN              ->    0.              }T
T{  1. FASIN             ->    PI 2. F/        }T
T{  1. FACOS             ->    0.              }T 
T{  1. FATAN 2. F*       ->    PI 2. F/ 

                                        
T{  60. DEG>RAD          ->    PI 3. F/        }T
T{  PI  RAD>DEG          ->  360. 2. F/        }T


