\
\ M&%.f
\
\ double integer (d1 * n1) / n2
\ The intermediate passage through a triple precision integer
\ avoids precision loss.

\
.( M*/ )
\
\     dH dL  x
\        n1  =
\ ----------
\     aH aL
\  bH bL   
\ ----------
\  cH cL aL  :  n2  =  q1  q2
\     r1 aL
\ 

NEEDS PICK

: M*/  ( d  n1  n2 -- d2 )
    \ keep track of final sign
    2dup xor 3 pick xor >R          \ d n1 n2           \ R: s    
    abs >R abs >R dabs              \ dL dH             \ R: s u2 u1
    \ multiply by n1 and get a and b
    swap R@ UM*                     \ dH aL aH 
    rot R> UM*                      \ aL aH bL bH       \ R: s u2
    \ obtain sum c of high parts
    rot 0                           \ aL bL bH aH 0
    D+                              \ aL cL cH
    \ divide n into c giving quotient and reminder
    R@                              \ aL cL cH u2       \ R: s u2
    UM/MOD                          \ aL r1 q1
    \ divide n into the composition r1+aL     
    -rot R>                         \ q1 aL r1 u2       \ R: s
    UM/MOD                          \ q1 r2 q2 
    \ discard reminder r2 and reorder the two partial-quotients
    nip swap                        \ q2 q1
    \ determine final sign.
    R> D+-                          \ d2 
;

