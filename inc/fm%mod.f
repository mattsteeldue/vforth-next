\
\ fm%mod.f
\ FM/MOD
\
\ Floored Division Example

\ Dividend   Divisor  Remainder   Quotient
\       10	       7	    	 3	   	    1
\      -10	       7	    	 4	       -2
\       10	      -7	        -4	       -2
\      -10	      -7	        -3	        1

\

NEEDS SM/REM 

.( FM/MOD ) 

: FM/MOD
  DUP >R SM/REM OVER DUP
  0= 0= SWAP 0<
  R@ 0< XOR AND
  IF 1- SWAP R> + SWAP
  ELSE R> DROP THEN
;

