\
\ test/#s.f  
\ 


NEEDS TESTING

( Test Suite - Number Patterns  )

TESTING F6.1.0050 - #s

: GP4 <# 1 0 #S #> S" 1" S= ;
T{ GP4 -> <TRUE> }T
: GP5
   BASE @ <TRUE>
   MAX-BASE 1+ 2 DO      \ FOR EACH POSSIBLE BASE
     I BASE !              \ TBD: ASSUMES BASE WORKS
       I 0 <# #S #> S" 10" S= AND
   LOOP
   SWAP BASE ! ;
T{ GP5 -> <TRUE> }T

: GP6
   BASE @ >R 2 BASE !
   MAX-UINT MAX-UINT <# #S #>    \ MAXIMUM UD TO BINARY
   R> BASE !                        \ S: C-ADDR U
   DUP #BITS-UD = SWAP
   0 DO                              \ S: C-ADDR FLAG
     OVER C@ [CHAR] 1 = AND     \ ALL ONES
     >R CHAR+ R>
   LOOP SWAP DROP ;
T{ GP6 -> <TRUE> }T

: GP7
   BASE @ >R MAX-BASE BASE !
   <TRUE>
   A 0 DO
     I 0 <# #S #>
     1 = SWAP C@ I 30 + = AND AND
   LOOP
   MAX-BASE A DO
     I 0 <# #S #>
     1 = SWAP C@ 41 I A - + = AND AND
   LOOP
   R> BASE ! ;
T{ GP7 -> <TRUE> }T
