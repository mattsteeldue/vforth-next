\
\ skip-page.f
\
\ this is part of the HEAP memory management libary. See also:
\ FAR HP@ POINTER HEAP H" S" +C +" HEAP-INIT HEAP-DONE
\ See "Heap memory facility" in PDF documentation for details
\
.( SKIP-PAGE )
\
NEEDS HP@

BASE @

\ never completely fill a page, leave alone some byte to avoid page spillover
\ this constant is 80 byte 

HEX 1F80 CONSTANT PAGE-WATERMARK

\
\ check if  n  more bytes are available in the current 8K-page in Heap
\ otherwise skip  HP  to the beginning of next 8K-page
\
: SKIP-PAGE ( n -- )
    HP@    
    1FFF  AND                   \ take only offset part of HP heap-address
    + 
    PAGE-WATERMARK
    >                           \ check if it is greater than watermark
    IF
        HP@  1FFF OR 1+ 2+ HP ! \ HP goes to the next page
    THEN
    \ HP@  0=  [ DECIMAL 12 ] LITERAL  ?ERROR  \ out of memory check
;

BASE !
