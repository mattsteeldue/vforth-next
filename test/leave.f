\
\ test/leave.f
\


NEEDS TESTING

( Test Suite - Dictionary  )

TESTING F.6.1.1760 - LEAVE

T{ : GD5 123 SWAP 0 DO 
     I 4 > IF DROP 234 LEAVE THEN 
   LOOP ; -> }T
T{ 1 GD5 -> 123 }T
T{ 5 GD5 -> 123 }T
T{ 6 GD5 -> 234 }T

