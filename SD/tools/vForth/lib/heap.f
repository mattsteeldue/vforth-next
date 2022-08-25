\
\ heap.f
\
\ This is part of the "HEAP memory management libary". 
\ It allows using 8K-page between 32 and 39 (20h-27h) as a memory zone
\ used for multi-purpose short memory chunks.
\ 
\ See also:
\ FAR HP@ POINTER H" S" +C +" HEAP-INIT HEAP-DONE
\
\ See "Heap memory facility" in PDF documentation for details
\
\
.( HEAP memory management ) 
\
NEEDS SKIP-PAGE
NEEDS FAR
NEEDS HP@
\
\ these are not real dependencies, but useful having them here
NEEDS HEAP-DOS          
NEEDS HEAP-DONE
NEEDS HEAP-INIT
\
\ Reserve n bytes of Heap, return heap-pointer address
\ Heap is a linked-list starting from P:0002=$40:$E002
: HEAP ( n -- ha )
    DUP SKIP-PAGE       \ n             check 8k boundary
    HP@ SWAP            \ ha n  
    CELL+               \ ha n+2        room for link to previous HP
    HP +!               \ ha            advance HP by n+2
    HP@ SWAP            \ hp ha
    TUCK                \ ha hp ha
    FAR !               \ ha            store link to previous HP
    CELL+               \ ha            final HP address
;
\

HEAP-DONE               \ free 8K-pages without error
HEAP-INIT               \ require 8K-pages $40 to $47

WARNING @ 0 WARNING !

\ modify COLD to free them
: COLD 
    HEAP-DONE 
    COLD 
;

WARNING !
