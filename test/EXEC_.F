\
\ EXEC_.f
\
NEEDS TESTING

NEEDS EXEC:

TESTING Zx Next - Custom - EXEC:

: ZERO  0 ;
: ONE   1 ;
: TWO   2 ;
: THREE 3 ;

: EXEC:TEST ( n -- )
  DUP
  EXEC: ZERO ONE TWO THREE FOUR
;

T{ 0 -> 0 0 }T
T{ 1 -> 1 1 }T
T{ 2 -> 2 2 }T
T{ 3 -> 3 3 }T
T{ 4 -> 4   }T

