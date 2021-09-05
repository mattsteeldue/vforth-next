\
\ SM%rem.f
\ SM/REM
\
\ Symmetric Division Example

\ Dividend   Divisor  Remainder   Quotient
\       10	       7	    	 3	   	    1
\      -10	       7	    	-3	       -1
\       10	      -7	         3	       -1
\      -10	      -7	        -3	        1

\

.( SM/REM included ) 6 EMIT 

: SM/REM
  DUP >R ABS                \  d  un        \  ns
  -ROT DUP >R DABS ROT      \  ud un        \  ns  ds
  UM/MOD                    \  ur uq        \  ns  ds
  SWAP R@ +-                \  uq  r        \  ns  ds
  SWAP R> R> XOR +-         \  r   q  
;

