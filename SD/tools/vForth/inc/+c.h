\
\ +c.f
\
.( +C ) 
\
NEEDS FAR
NEEDS H"

\
\
\ consume  c  and append to the string being created in Heap at ha
\ returns the same Heap-Pointer to the counted string in Heap
: +C ( ha c -- ha )
    OVER FAR                 \ ha c  a
    1 OVER CELL- +!          \ fix linked list pointer
    DUP C@ 1+ SWAP 2DUP      \ ha c  n  a  n  a
    C!                       \ ha c  n  a   :  fix length
    + C!                     \ ha           : store c
    1 HP +!                  \ ha
;

