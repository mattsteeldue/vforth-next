\
\ FLOATING-TESTS.f
\

NEEDS FLOATING
NEEDS :NONAME

MARKER TESTING-TASK

    NEEDS TESTING

TESTING \ ZX Spectrum Floating-Point interface

FLOATING DECIMAL

T{  3.0   4.0   F-       ->   -1.              }T
T{  3.0   4.0   F*       ->   12.              }T
T{  3.0   4.0   F/       ->    1. 4. 3. F/ F/  }T
T{  3.0   4.0   F+       ->    7.              }T
T{  3.0   4.0   FNEGATE  ->    3.   -4.        }T
T{  3.0   4.0   FSGN     ->    3.    1.        }T
T{  3.0   4.0   FABS     ->    3.    4.        }T
T{  3.0   4.0   F/MOD    ->    3.    0.        }T
T{  3.0   4.0   F**      ->    9.    2. F**    }T
                                        
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


