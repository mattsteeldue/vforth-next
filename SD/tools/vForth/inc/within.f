\
\ within.f
\
.( WITHIN )
\
\ Comapre test value n1 against a low n2 and high n3 limit
\ When n2 < n3, return a true-flag if  n2 <= n1 < n3, a false-flag otherwise. 
\ When n2 > n3, return a true-flag if  n2 <= n1 OR n1 < n3, a false-flag otherwise. 

\ returning true if either 
\ (u2 < u3 and (u2 <= u1 and u1 < u3) )  or 
\ (u2 > u3 and (u2 <= u1 or  u1 < u3) ) is true,

: WITHIN ( n1 n2 n3 -- f )
    OVER -      \  n1      n2     n3-n2
    -ROT -      \  n3-n2   n1-n2
    SWAP U<     \  n1-n2 < n3-n2
; 

