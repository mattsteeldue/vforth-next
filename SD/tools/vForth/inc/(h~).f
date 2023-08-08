\
\ (h~).f
\
\ this is part of the HEAP memory management libary. See also:
\ FAR HP@ POINTER HEAP H" +C +" HEAP-INIT HEAP-DONE
\ See "Heap memory facility" in PDF documentation for details
\
\ (H") is the compiled counterpart of S" for string.
\ 

NEEDS FAR

\
\ retrieve address of an immutable string on heap

: (H")  ( -- a n )
    \ next cell in the caller definitions contains an heap-pointer address
    R@ @            \  ha
    \ so read it and skip to next cell
    R> CELL+ >R     \  ha        
    \ fit the appropriate 8K page at MMU7 and calculate the correct address
    FAR             \  a
    \ return address and lenght of the counted string
    COUNT           \  a+1 n
;

