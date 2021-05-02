\
\ far.f
\ 
\ this is part of the HEAP memory management libary. See also:
\ HP@ POINTER HEAP H" S" +C +" HEAP-INIT HEAP-DONE
\ See "Heap memory facility" in PDF documentation for details
\
.( FAR ) 
\
NEEDS >FAR
\
\ Convert an "heap-pointer address" (ha) into a real address (a)
\ between E000h and FFFFh and fit the correct 8K page on MMU7
\ An "ha" uses the 3 msb as page-number and the lower bits as offset at E000.
\
: FAR  ( ha -- a )
    >FAR MMU7! ;
