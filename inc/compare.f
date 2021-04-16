\
\ compare.f
\
.( COMPARE )
\
\ Compare two strings and return  0 if they're equal
\ or  1 if s1 > s2  or  -1 if s1 < s2
: COMPARE  ( a1 c1 a2 c2 -- -1|0|1 )
    ROT 2DUP SWAP - >R                  \ a1 a2 c2 c1      \ c1-c2
    MIN                                 \ a1 a2 min(c2,c1) \ c1-c2
    (COMPARE)                           \ b                \ c1-c2
    R> SWAP ?DUP                        \ c1-c2 b b<>0
    IF                                  \ c1-c2 b that is not zero
        SWAP DROP                       \ b that is 1 or -1
    ELSE                                \ c1-c2
        1 SWAP *                        \ sign(c1-c2) or zero
    THEN                                \ n
;
\
