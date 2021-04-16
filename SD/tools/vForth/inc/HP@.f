\
\ hp@.f
\

.( HP@ ) 

\ Get current Heap Pointer user variable
\ HP holds a "heap-pointer" value not a real-address.
\ to turn it into a real-address you must use FAR definition.
: HP@ ( -- ha )
    HP @ ;
