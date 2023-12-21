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
NEEDS SKIP-HP-PAGE
\

BASE @


\ keep allocated 8K-pages number $20 to $27.
\ This is 64K of ram avalable for Heap Management
\ passed parameter must be 2 for alloc, or 3 for free
\  n1 = hl register parameter value
\  n2 = de register parameter value
\  n3 = bc register parameter value
\  n4 =  a register parameter value
\  addr = routine address in ROM 3

\   hl de bc  a  addr           f     a  bc  de hl

HEX  2 20  0  0  01BD  M_P3DOS  DROP  2DROP  2DROP 
HEX  2 21  0  0  01BD  M_P3DOS  DROP  2DROP  2DROP 
HEX  2 22  0  0  01BD  M_P3DOS  DROP  2DROP  2DROP 
HEX  2 23  0  0  01BD  M_P3DOS  DROP  2DROP  2DROP 
HEX  2 24  0  0  01BD  M_P3DOS  DROP  2DROP  2DROP 
HEX  2 25  0  0  01BD  M_P3DOS  DROP  2DROP  2DROP 
HEX  2 26  0  0  01BD  M_P3DOS  DROP  2DROP  2DROP 
HEX  2 27  0  0  01BD  M_P3DOS  DROP  2DROP  2DROP 


\
\ Reserve n bytes of Heap, return heap-pointer address
\ Heap is a linked-list starting from P:0002=$40:$E002
: HEAP ( n -- ha )
    HP@ >R              \ n         R: h0   ( save current HP )
    DUP SKIP-HP-PAGE    \ n                 ( check for room in current page )
    HP@ CELL+ TUCK      \ ha n ha           ( prepare resulting hp )
    OVER + FAR          \ ha n a1
    >R                  \ ha n      R: h0 a1 
    0 R@ !              \ ha n              ( zero pad )
    R>                  \ ha n a1
    CELL+               \ ha n a2  
    R@                  \ ha n a2 h0
    SWAP !              \ ha n              ( set back pointer )   
    6 + HP +!           \ ha                ( set HP to next area )
    HP@                 \ ha hp
    R>                  \ hp hp h0
    FAR !               \ ha                ( set forward pointer )
;
\

BASE !

