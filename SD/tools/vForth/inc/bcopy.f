\
\ bcopy.f
\
.( BCOPY )
\
\ move from a to current screen line n
\
\ bcopy
: BCOPY ( n1 n2 -- ) \ copy screen n1 to n2, overvriting it
    DUP SCR !               \  n1  n2
    B/SCR * SWAP            \  b2  n1 
    B/SCR *                 \  b2  b1
    B/SCR 0                 \  b2  b1  2  0
    DO 
        2DUP                \  b2  b1  b2  b1
        BLOCK               \  b2  b1  b2  a1
        UPDATE              \
        SWAP                \  b2  b1  a1  b2
        BLOCK               \  b2  b1  a1  a2
        UPDATE              \
        B/BUF CMOVE         \  b2  b1
        SWAP 1+ SWAP 1+     \  b2  b1
    LOOP 
    2DROP                   \
;
\
