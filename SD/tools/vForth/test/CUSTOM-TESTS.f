\
\ CUSTOM-TESTS.f
\


MARKER TESTING-TASK

NEEDS TESTING


NEEDS PICK

NEEDS CHECKSUM

NEEDS DEFER
NEEDS DEFER!
NEEDS DEFER@
NEEDS IS 

NEEDS RANDOMIZE
NEEDS RANDOM
NEEDS CHOOSE

 

\ Save base and warning values
BASE    @ HEX \ all test needs base 16.
WARNING @ 0 WARNING !

CR

INCLUDE  test/3dup.f
INCLUDE  test/checksum.f
INCLUDE  test/defer.f
INCLUDE  test/random.f  

\ Restore base and warning values
WARNING !
BASE !
