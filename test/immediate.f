\
\ test/immediate.f
\

NEEDS TESTING

TESTING F.6.1.1710 - IMMEDIATE

T{ 123 CONSTANT iw1 IMMEDIATE iw1 -> 123 }T
T{ : iw2 iw1 LITERAL ; iw2 -> 123 }T
T{ VARIABLE iw3 IMMEDIATE 234 iw3 ! iw3 @ -> 234 }T
T{ : iw4 iw3 [ @ ] LITERAL ; iw4 -> 234 }T

T{ :NONAME [ 345 ] iw3 [ ! ] ; DROP iw3 @ -> 345 }T
T{ CREATE iw5 456 , IMMEDIATE -> }T
T{ :NONAME iw5 [ @ iw3 ! ] ; DROP iw3 @ -> 456 }T

T{ : iw6 CREATE , IMMEDIATE DOES> @ 1+ ; -> }T
T{ 111 iw6 iw7 iw7 -> 112 }T
T{ : iw8 iw7 LITERAL 1+ ; iw8 -> 113 }T

T{ : iw9 CREATE , DOES> @ 2 + IMMEDIATE ; -> }T
: find-iw BL WORD FIND NIP ;
T{ 222 iw9 iw10 find-iw iw10 -> -1 }T    \ iw10 is not immediate
T{ iw10 find-iw iw10 -> 224 1 }T          \ iw10 becomes immediate

\ See F.6.1.2510 ['], F.6.1.2033 POSTPONE, F.6.1.2250 STATE, F.6.1.2165 S".

