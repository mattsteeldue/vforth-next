\
\ test/unloop.f
\


NEEDS TESTING
NEEDS J
NEEDS UNLOOP 

( Test Suite - Counted Loops  )

\ F.6.1.1380  -  EXIT

TESTING F.6.1.2380 - UNLOOP

T{ : GD6 ( PAT: {0 0},{0 0}{1 0}{1 1},{0 0}{1 0}{1 1}{2 0}{2 1}{2 2} ) 
      0 SWAP 0 DO 
         I 1+ 0 DO 
           I J + 3 = IF I UNLOOP I UNLOOP EXIT THEN 1+ 
         LOOP 
      LOOP ; -> }T
T{ 1 GD6 -> 1 }T
T{ 2 GD6 -> 3 }T
T{ 3 GD6 -> 4 1 2 }T

