\
\ +~.f
\
.( +" ) 
\
\
NEEDS HP@
NEEDS FAR
\
\ accept a string and store it to the being created on Heap
\ appending to the existing string at "ha"
\ return the same Heap-Pointer to the counted string on Heap
: +" ( ha -- ha )
    DUP FAR C@
    [CHAR] " WORD
    DUP C@ >R 1+
    HP@ FAR R CMOVE
    R HP +!
    R> +
    OVER FAR C!
    DUP FAR HP@ SWAP !
;


