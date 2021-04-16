\
\ pointer.f
\

.( POINTER ) 

NEEDS FAR
NEEDS HEAP

\ like CONSTANT but return a Heap-Pointer-Address
: POINTER ( ha -- ccc )
    <BUILDS , DOES> @ FAR ;
