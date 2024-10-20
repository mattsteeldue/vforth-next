\
\ test/_.f  
\ 
\ since filename  :.f  is illegal.


NEEDS TESTING

( Test Suite - Defining Words )

\ F.6.1.0460     - ;

TESTING F.6.1.0450 - : 

T{ : NOP : POSTPONE ; ; -> }T
T{ NOP NOP1 NOP NOP2 -> }T
T{ NOP1 -> }T
T{ NOP2 -> }T

T{ : GDX   123 ;    : GDX   GDX 234 ; -> CR }T
T{ GDX -> 123 234 }T

\ The following tests the dictionary search order:
TESTING It's correct seeing this message:
TESTING GDX has already been defined.
TESTING It's correct seeing this message.
CR

