\
\ CUSTOM-TESTS.f
\


MARKER TESTING-TASK

WARNING @ 
0 WARNING ! \ reduce messaging #4

    NEEDS TESTING

WARNING !
    
    NEEDS >FAR      NEEDS <FAR
    NEEDS EXEC:
    NEEDS RND
    NEEDS 3DUP
    NEEDS CHECKSUM
    NEEDS RANDOMIZE
    NEEDS CHOOSE    
    NEEDS SPEED!    NEEDS SPEED@
    NEEDS DEFER!    NEEDS DEFER@    NEEDS DEFER
    NEEDS IS        NEEDS [']

 \ Save base value
BASE    @ HEX \ all test needs base 16.

CR

TESTING \ Custom

    INCLUDE  test/}far.f
    INCLUDE  test/{far.f
    INCLUDE  test/exec_.f

    INCLUDE  test/3dup.f
    INCLUDE  test/checksum.f
    INCLUDE  test/defer.f
    INCLUDE  test/random.f  
    
    INCLUDE  test/upper.f
    INCLUDE  test/D+.f
    INCLUDE  test/2+.f
    INCLUDE  test/cell+.f
    INCLUDE  test/2-.f
    INCLUDE  test/cell-.f
    INCLUDE  test/dnegate.f
    INCLUDE  test/traverse.f
    

TESTING \ ZX Spectrum Next

    INCLUDE  test/speed!.f

\ Restore base 
BASE !
