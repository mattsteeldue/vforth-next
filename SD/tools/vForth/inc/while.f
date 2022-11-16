\
\ while.f
\
.( WHILE )
\
NEEDS IF
\
: WHILE     ( a1 1 -- a1 1 a2 4 ) \ compile-time
            (    f -- ) \ run-time
    [COMPILE] IF \ 2+
    2SWAP
    ; 
    IMMEDIATE

