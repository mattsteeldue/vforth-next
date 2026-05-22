\
\ UD%.f
\
\ double-integer division by integer
\ Given an unsigned-double dividend and an integer divisor
\ returns an unsigned-double quotient

\ assuming ud1 is represented in four bytes "hlde"
\ here's a sketch of computation:
\ 1. compute hl/n giving q1 as partial quotient and r as partial remainder
\ 2. compute rde/n giving q2 to complete quotient and r2 as final remainder which is discarded.
\
\ hl de : u = q1 q2
\  r    
\    r2 

: UD/ ( ud1 u  -- ud2 )
    >R              \ de hl        R: u
    0 R@            \ de hl 0  u
    UM/MOD          \ de  r q1
    -ROT            \ q1 de r       
    R>              \ q1 de r  u
    UM/MOD          \ q1 r2 q2
    NIP SWAP        \ q2 q1 
;

