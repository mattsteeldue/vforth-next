\
\ heap-done.f
\
\ this is part of the HEAP memory management libary. See also:
\ FAR HP@ POINTER HEAP H" S" +C +" HEAP-INIT HEAP-DONE
\ See "Heap memory facility" in PDF documentation for details
\
.( HEAP-DONE included ) 6 EMIT
\
NEEDS HEAP-DOS 
\
: HEAP-DONE  3 HEAP-DOS ;
