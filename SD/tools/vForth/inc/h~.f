\
\ h~.f
\
\ this is part of the HEAP memory management libary. See also:
\ FAR HP@ POINTER HEAP S" +C +" HEAP-INIT HEAP-DONE
\ See "Heap memory facility" in PDF documentation for details
\
.( H" )
\
NEEDS FAR
NEEDS PARSE
NEEDS HEAP
\
\ Accept a string and store it to Heap, return a
\ heap-address pointer to a counted string.
\ The zero cell HEAP lays down after the data makes it a counted
\ z-string too: FAR 1+ gives a null-terminated string for NextZXOS.
\ The ha is the one HEAP returns: when the string does not fit the
\ current page, HEAP moves on to the next one.
\ PARSE, not WORD: no leading " is skipped, so  H" "  is empty.
\ #-18 Parsed string overflow.  more than 255 characters
\ 
BASE @ DECIMAL
\
: H" ( -- ha )
    [CHAR] "  PARSE     \ a1  n            accept string from input stream
    DUP $FF >           \ a1  n  f
    -18 ?ERROR          \ a1  n
    DUP 1+ HEAP         \ a1  n  ha        allocate
    DUP >R FAR          \ a1  n  a2        R: ha
    2DUP C!             \ a1  n  a2        store length
    1+ SWAP             \ a1  a2+1  n
    CMOVE               \
    R>                  \ ha
;
\
BASE !
\
\ : C" H" DROP ;
\
