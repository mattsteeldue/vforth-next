\
\ CUSTOM-TESTS.f
\


MARKER TESTING-TASK

WARNING @ 
0 WARNING ! \ reduce messaging #4

    NEEDS TESTING

WARNING !
    
    NEEDS PICK
    NEEDS CHECKSUM
    NEEDS RANDOMIZE
    NEEDS RANDOM
    NEEDS CHOOSE

 \ Save base value
BASE    @ HEX \ all test needs base 16.

CR

TESTING \ Custom

    INCLUDE  test/3dup.f
    INCLUDE  test/checksum.f
    INCLUDE  test/defer.f
    INCLUDE  test/random.f  

TESTING \ ZX Spectrum Next

    INCLUDE  test/speed!.f

\ Restore base and warning values
BASE !
