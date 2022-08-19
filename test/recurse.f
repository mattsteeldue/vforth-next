\
\ test/recurse.f
\


NEEDS TESTING
NEEDS RECURSE
NEEDS :NONAME
NEEDS CASE 

( Test Suite - Dictionary  )

TESTING F.6.1.2120 - RECURSE

T{ : GI6 ( N -- 0,1,..N ) 
     DUP IF DUP >R 1- RECURSE R> THEN ; -> }T
T{ 0 GI6 -> 0 }T
T{ 1 GI6 -> 0 1 }T
T{ 2 GI6 -> 0 1 2 }T
T{ 3 GI6 -> 0 1 2 3 }T
T{ 4 GI6 -> 0 1 2 3 4 }T

T{ :NONAME ( n -- 0, 1, .., n ) 
     DUP IF DUP >R 1- RECURSE R> THEN 
   ; 
   CONSTANT rn1 -> }T
T{ 0 rn1 EXECUTE -> 0 }T
T{ 4 rn1 EXECUTE -> 0 1 2 3 4 }T

:NONAME ( n -- n1 )
   1- DUP
   CASE 0 OF EXIT ENDOF
     1 OF 11 SWAP RECURSE ENDOF
     2 OF 22 SWAP RECURSE ENDOF
     3 OF 33 SWAP RECURSE ENDOF
     DROP ABS RECURSE EXIT
   ENDCASE
; CONSTANT rn2

T{  1 rn2 EXECUTE -> 0 }T
T{  2 rn2 EXECUTE -> 11 0 }T
T{  4 rn2 EXECUTE -> 33 22 11 0 }T
T{ 25 rn2 EXECUTE -> 33 22 11 0 }T

