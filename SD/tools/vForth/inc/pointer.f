\
\ pointer.f
\
\ this is part of the HEAP memory management libary. See also:
\ FAR HP@ HEAP H" S" +C +" HEAP-INIT HEAP-DONE
\ See "Heap memory facility" in PDF documentation for details
\
.( POINTER ) 
\
NEEDS FAR
NEEDS HEAP
\
\ like CONSTANT but returns a Heap-Pointer-Address.
\ When invoked a  FAR  turns it into a real address with the correct page 
\ fitted on MMU7.
\
: POINTER ( ha -- ccc )
    <BUILDS , DOES> @ FAR ;
