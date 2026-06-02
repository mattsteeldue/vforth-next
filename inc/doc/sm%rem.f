\
\ SM%rem.f
\ SM/REM
\
\ Symmetric Division Example

\ Dividend   Divisor  Remainder   Quotient
\      10.        7          3          1
\     -10.        7         -3         -1
\      10.       -7          3         -1
\     -10.       -7         -3          1
\

.( SM/REM )

: SM/REM ( d n -- r q )
    OVER >R >R              \ d        R: h n
    DABS R@ ABS UM/MOD      \ r  q
    R>                      \ r  q  n
    R@ XOR +- SWAP          \ +q r
    R>     +- SWAP          \ +r +q
;


\ : SM/REM ( d n -- r q )
\   DUP >R ABS                \  d  un    \ R: ns
\   -ROT DUP >R DABS ROT      \  ud un    \ R: ns  ds
\   UM/MOD                    \  ur uq    \ R: ns  ds
\   SWAP R@ +-                \  uq  r    \ R: ns  ds
\   SWAP R> R> XOR +-         \  r   q  
\ ;

