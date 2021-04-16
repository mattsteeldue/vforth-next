\
\ heap.f
\

.( HEAP )

NEEDS SKIP-PAGE
NEEDS FAR
NEEDS HP@
NEEDS HEAP-DOS
NEEDS HEAP-DONE
NEEDS HEAP-INIT


\ Reserve n bytes of Heap, return heap-pointer address
\ Heap is a linked-list starting from P:0002=$40:$E002
: HEAP ( n -- ha )
    DUP SKIP-PAGE      \ n
    HP@ SWAP          \ ha n
    CELL+             \ ha n+2
    HP +!             \ ha
    HP@ SWAP          \ hp ha
    TUCK              \ ha hp ha
    FAR !             \ ha
    CELL+             \ ha
;
\

