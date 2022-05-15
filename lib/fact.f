\
\ FACT.f
\
\ Factorial single to double precision
: FACT ( n -- d! )
  1+ 1 0 ROT 1          \ d  n+1 1
  ?DO                   \ dL'dH
    SWAP I UM*          \ dH aL'aH
    ROT  I UM*          \ aL'aH bL'bH
    ROT  0              \ aL bL'bH aH'0
    D+                  \ aL'(bL'bH+aH'0)
    DROP                \ d
  LOOP
;

