\
\ PAD~.f
\
\ accept string to PAD, zero padded, useful for volatile string usage
\ typical usage:   PAD" sometext". String is stored in HEAP.
\
.( PAD" )
\

NEEDS S"
NEEDS >ZPAD

\
: PAD" ( -- )  \
    STATE @
    IF
        \ ." compiler " CR
        [COMPILE] S"        \ a+1 n
        COMPILE   >ZPAD     
    ELSE
        \ ." interpreter " CR
        [CHAR] " WORD       \ a (counted-string)
        COUNT               \ a+1   n
        >ZPAD
    THEN
;    
IMMEDIATE

\
