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
NEEDS FAR
NEEDS HP@
\

BASE @

\ never completely fill a page, leave alone some byte to avoid page spillover
\ this constant is 80 byte 

HEX 1F80 CONSTANT PAGE-WATERMARK

\
\ check if  n  more bytes are available in the current 8K-page in Heap
\ otherwise skip  HP  to the beginning of next 8K-page
\
: SKIP-PAGE ( n -- )
    HP@    
    1FFF  AND                   \ take only offset part of HP heap-address
    + 
    PAGE-WATERMARK
    >                           \ check if it is greater than watermark
    IF
        HP@  1FFF OR 1+ 2+ HP ! \ HP goes to the next page
    THEN
    \ HP@  0=  [ DECIMAL 12 ] LITERAL  ?ERROR  \ out of memory check
;


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

\ allocate or free 8K-pages number $20 to $27.
\ This is 64K of ram avalable for Heap Management
\ passed parameter must be 2 for alloc, or 3 for free
HEX

: HEAP-DOS ( n -- )
    28 20          \ decimal 32-39
    DO
        DUP        \  n1 = hl register parameter value
        I          \  n2 = de register parameter value
        0          \  n3 = bc register parameter value
        0          \  n4 =  a register parameter value
        01BD       \   a = routine address in ROM 3
        M_P3DOS
        2C ?ERROR       \ error #44 NextZXOS DOS call error
        2DROP 2DROP
    LOOP DROP           \ consume n.
;
: HEAP-DONE  3 HEAP-DOS ;
: HEAP-INIT  2 HEAP-DOS ;


HEAP-DONE               \ free 8K-pages without error
HEAP-INIT               \ require 8K-pages $40 to $47

WARNING @ 0 WARNING !

\ modify COLD to free them
: COLD 
    HEAP-DONE 
    COLD 
;

WARNING !
BASE !

