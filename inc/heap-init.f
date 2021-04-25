\
\ heap-init.f
\
\ this is part of the HEAP memory management libary. See also:
\ FAR HP@ POINTER HEAP H" S" +C +" HEAP-INIT HEAP-DONE
\ See "Heap memory facility" in PDF documentation for details
\
.( HEAP-INIT )
\
NEEDS HEAP-DOS 

: HEAP-INIT  2 HEAP-DOS ;
