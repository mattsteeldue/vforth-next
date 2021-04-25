\
\ hp@.f
\
\ this is part of the HEAP memory management libary. See also:
\ FAR POINTER HEAP H" S" +C +" HEAP-INIT HEAP-DONE
\ See "Heap memory facility" in PDF documentation for details
\
.( HP@ ) 
\
\ Get current Heap Pointer user variable value
\ HP keeps a "heap-pointer" value not a "real-address".
\ to turn it into a real-address you must use FAR definition.
\
: HP@ ( -- ha )
    HP @ ;
