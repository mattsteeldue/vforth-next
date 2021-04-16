\
\ bcopy.f
\
.( BCOPY ) CR
\
\ move from a to current screen line n
\
\ bcopy
: BCOPY ( n1 n2 -- ) \ copy screen n1 to n2, overvriting it
    DUP SCR ! B/SCR * SWAP B/SCR *
    B/SCR 0 
    DO 
        2DUP
        BLOCK SWAP BLOCK B/BUF CMOVE 
        UPDATE
        SWAP 1+ SWAP 1+
    LOOP 
    2DROP 
;
\
