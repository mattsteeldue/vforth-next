\
\ PAD~.f
\
\ accept string to PAD from current input.
\
\ Typical usage:   PAD" sometext". 
\
\ At compile-time string is stored in HEAP.
\ Then at run-time, the string is retrieved from HEAP and put to PAD.
\ While not compiling, the string is directly put to PAD without storing
\ it in HEAP, so the string is volatile.
\ The string on PAD is zero padded.
\
.( PAD" )
\

NEEDS S"
NEEDS >ZPAD

\
: PAD" ( -- )  \
    STATE @
    PAD C/L BLANK
    IF                      \ ." compiler " CR
        [COMPILE] S"        \ a+1 n
        COMPILE   >ZPAD     
    ELSE                    \ ." interpreter " CR
        [CHAR] " WORD       \ a (counted-string)
        COUNT               \ a+1   n
        >ZPAD
    THEN
;    
IMMEDIATE

\
