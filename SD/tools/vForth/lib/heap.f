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
.( HEAP ) 
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
    HP@ >R              \ n        R: h0    ( save current HP )
    DUP SKIP-PAGE       \ n                 ( check for room in current page )
    HP@ CELL+ TUCK      \ ha n ha           ( prepare resulting hp )
    OVER + FAR >R       \ ha n     R: h0 a1 
    0 R@ !              \ ha n              ( zero pad )
    R> CELL+            \ ha n a2  R: h0
    R@ CELL- SWAP !     \ ha n              ( set back pointer )   
    6 + HP +!           \ ha       R: h0    ( set HP to next area )
    HP@ R> FAR !        \ ha                ( set forward pointer )
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
