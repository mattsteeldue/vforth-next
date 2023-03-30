\
\ bmove.f
\
.( BMOVE )
\

NEEDS BCOPY
NEEDS J

\ move a group of n1 screens from n2 to n3
\
\ bcopy
: BMOVE ( n orig dest -- ) 
    OVER -                  \ n   orig  delta:=dest-orig        
    >R                      \ n   orig            R: delta
    SWAP                    \ orig   n
    OVER +                  \ orig   n+orig
    R@ 0<                   \ orig   n+orig  dest<orig
    IF                      \ orig   n+orig  
        SWAP                \ orig+n   orig  if dest<orig
    ELSE
        1-
    THEN                    \ orig   n+orig  |  orig+n  orig  
    DO
        ?TERMINAL IF QUIT THEN 
        CR I  . ."  --> " I J + . 
        I I J + BCOPY FLUSH
        -1 J +-              \ 1 with the sign of dest-orig
    +LOOP
    R> 
    DROP
;
\
