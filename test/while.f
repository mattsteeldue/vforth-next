\
\ test/while.f
\


NEEDS TESTING

( Test Suite - Flow Control  )

\ F.6.1.0760  -  BEGIN 
\ F.6.1.2140  -  REPEAT

TESTING F.6.1.2430 - WHILE

T{ : GI3 BEGIN DUP 5 < WHILE DUP 1+ REPEAT ; -> }T
T{ 0 GI3 -> 0 1 2 3 4 5 }T
T{ 4 GI3 -> 4 5 }T
T{ 5 GI3 -> 5 }T
T{ 6 GI3 -> 6 }T

\ T{ : GI5 BEGIN DUP 2 > WHILE 
\      DUP 5 < WHILE DUP 1+ REPEAT 
\      123 ELSE 345 THEN ; -> }T

T{ : GI5 
    BEGIN               ( C: -- dest )
        DUP 2 > 
        WHILE           ( C: dest -- orig1 dest )
        DUP 5 < 
        WHILE           ( C: orig1 dest -- orig1 orig2 dest )
            DUP 1+ 
    REPEAT              ( C: orig1 orig2 dest -- orig1 )
        123 
    ELSE                ( C: orig1 -- orig2 )
        345 
    THEN                ( C: orig2 -- )
    ; -> }T
      
T{ 1 GI5 -> 1     345 }T
T{ 2 GI5 -> 2     345 }T
T{ 3 GI5 -> 3 4 5 123 }T
T{ 4 GI5 ->   4 5 123 }T
T{ 5 GI5 ->     5 123 }T

