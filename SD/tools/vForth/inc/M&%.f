\
\ M&%.f
\
\ (d1 * n1) / n2
\ The intermediate passage through a triple precision integer
\ avoids any loss of precision

\
.( M*/ included ) 6 EMIT
\
\     dH dL  x
\         m  =
\ ----------
\     aH aL
\  bH bL   
\ ----------
\  cH cL aL  :  n  =  q1  q2
\     r1 aL
\ 

: M*/  ( d  n1  n2 -- d2 )
  2dup xor 3 pick xor >R     \ keep track of final sign
  abs >R abs >R 
  swap R@ UM* rot R> UM*     \ 1. multiply by m and get a and b
  rot 0 D+                   \ 2. obtain c
  R@ UM/MOD                  \ 3. divide n into c giving quotient and reminder
  rot rot R> UM/MOD          \ 4. divide n into the composition r1+aL 
  nip swap                   \ discard reminder r2 and reorder the two partial-quotients
  R> D+-                     \ determine final sign.
;

