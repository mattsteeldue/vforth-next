\
\ FLOATING-TESTS.f
\

NEEDS :NONAME
NEEDS FLOATING
INTEGER

MARKER TESTING-TASK

    NEEDS TESTING

TESTING \ ZX Spectrum Floating-Point interface

FLOATING DECIMAL

T{  3.0   4.0   F-       ->   -1.              }T
T{  3.0   4.0   F*       ->   12.              }T
T{  3.0   4.0   F/       ->    0.75            }T
T{  3.5   4.5   F+       ->    8.    1. F/     }T
T{  3.0         FNEGATE  ->   -3.              }T
T{ -3.0         FSGN     ->   -1.              }T
T{ -3.0         FABS     ->    3.0             }T
T{  3.0   4.0   F/MOD    ->    3.    0.        }T
T{  3.0   4.0   F**      ->   81.    1. F/     }T
T{  5.0   3.0   4.0  F*/ ->    3.75            }T
                                        
T{  1. FLN               ->    0.              }T
T{  PI FEXP  FLN         ->    PI              }T
T{  PI FSQRT 2DUP F*     ->    PI              }T
T{  PI FINT              ->    3.              }T

T{  0. FSIN              ->    0.              }T
T{  0. FCOS              ->    .5 .5 F+        }T
T{  PI 4. F/ FTAN        ->    .5 .5 F+        }T
T{  PI 3. 4. F*/ FTAN    ->   -.5 -.5 F+       }T
T{  1. FASIN             ->    PI 2. F/        }T
T{  1. FACOS             ->    0.              }T 
T{  1. FATAN 2. F*       ->    PI 2. F/ 

                                        
T{  60. DEG>RAD          ->    PI 3. F/        }T
T{  PI  RAD>DEG          ->  360. 2. F/        }T


