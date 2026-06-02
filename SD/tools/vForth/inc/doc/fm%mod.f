\
\ fm%mod.f
\ FM/MOD
\
\ Floored Division Example

\ Dividend   Divisor  Remainder   Quotient
\      10.        7          3          1
\     -10.        7          4         -2
\      10.       -7         -4         -2
\     -10.       -7         -3          1
\

.( FM/MOD )

: FM/MOD ( d n -- r q )
  DUP >R                    \ d n      R: n
  SM/REM                    \ r q
  OVER DUP                  \ r q r r
  0= 0= SWAP 0<             \ r q r=0 r<0
  R@ 0< XOR AND             \ r q r=0&r<0^n
  IF 
    1- SWAP R> + SWAP       
  ELSE 
    R> DROP 
  THEN
;

\ NEEDS I'

\ : FM/MOD ( d n -- r q ) ** BUGGY **
\     2DUP XOR >R >R          \ d        R: x n
\     DABS R@ ABS UM/MOD      \ r  q
\     SWAP                    \ q  r
\     I' 0< 1 AND +           \ r  q     R: x n
\     R> +-                   \ r  q+    R: x
\     SWAP                    \ +q r
\     R@ 0< 1 AND +           \ +q r
\     R> +-                   \ +q +r    
\ ;



