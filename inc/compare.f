\
\ compare.f
\
.( COMPARE )
\
\ In the core since build 2026-10-28, where NEEDS COMPARE skips this
\ file. Kept for older cores: it needs their (COMPARE), which the newer
\ core no longer has (see inc/(compare).f).
\
\ Compare two strings and return  0 if they're equal
\ or  1 if s1 > s2  or  -1 if s1 < s2
: COMPARE  ( a1 c1 a2 c2 -- -1|0|1 )
    ROT 2DUP SWAP - >R                  \ a1 a2 c2 c1      \ dist := c1-c2
    MIN                                 \ a1 a2 min(c2,c1) \ dist
    (COMPARE)                           \ b                \ dist
    R> SWAP ?DUP                        \ dist  b  b?
    IF                                  \ dist  b  
        NIP                             \ b  (that is 1 or -1)
    ELSE                                \ 
        DUP                             \ dist dist
        IF 
            0< IF -1 ELSE 1 THEN
        THEN               
    THEN                                
;
\
