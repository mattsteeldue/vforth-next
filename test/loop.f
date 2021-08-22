\
\ test/loop.f
\


NEEDS TESTING

( Test Suite - Dictionary  )

TESTING F.6.1.1800 - LOOP

T{ : GD1 DO I LOOP ; -> }T
T{          4        1 GD1 ->  1 2 3   }T
T{          2       -1 GD1 -> -1 0 1   }T
T{ MID-UINT+1 MID-UINT GD1 -> MID-UINT }T

