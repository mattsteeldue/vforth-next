\
\ test/loop.f
\


NEEDS TESTING

( Test Suite - Counted Loops  )

\ F.6.1.1240  -  DO

TESTING F.6.1.1800 - LOOP

\ this tests (LOOP) primitive compiled by LOOP
\ I and (DO) the primitive compiled by DO

T{ : GD1 DO I LOOP ; -> }T
T{          4        1 GD1 ->  1 2 3   }T
T{          2       -1 GD1 -> -1 0 1   }T
T{ MID-UINT+1 MID-UINT GD1 -> MID-UINT }T

TESTING Custom - I'

T{ : GDI' DO I' LOOP ; -> }T
T{          4        1 GDI' ->  4 4 4   }T
