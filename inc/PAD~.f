\
\ PAD~.f
\
\ accept string to PAD, zero padded, useful for volatile string usage
\ typical usage:   PAD" sometext". String is stored in HEAP.
\
.( PAD" )
\

NEEDS S"

\ runtime portion of PAD"
\ this definition ports a string+length into a z-string to PAD
: >ZPAD  ( a n -- )
    PAD 256 BLANK           \ a     n
    2DUP + 0                \ a+1   n  a+n+1  0
    SWAP !                  \ a+1   n
    PAD SWAP 1+             \ a+1 pad  n+1
    CMOVE 
;  

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
