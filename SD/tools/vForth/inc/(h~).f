\
\ (h~).f
\
\ this is part of the HEAP memory management libary. See also:
\ FAR HP@ POINTER HEAP H" +C +" HEAP-INIT HEAP-DONE
\ See "Heap memory facility" in PDF documentation for details
\
\ (H") 
\

NEEDS FAR

\
\ immutable  string on heap
: (H") 
    R@ @            \  ha
    R> CELL+ >R     \  ha        \ skip next cell
    FAR             \  a
    COUNT           \  a+1 n
;

