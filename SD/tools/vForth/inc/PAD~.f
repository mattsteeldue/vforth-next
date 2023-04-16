\
\ PAD~.f
\
\ accept string to PAD, zero padded, useful for volatile string usage
\
\ typical usage:   PAD" sometext"
\
.( PAD" )
\

: >PAD  ( a -- )
    COUNT                   \ a+1   n
    2DUP + 0                \ a+1   n  a+n+1  0
    SWAP !                  \ a+1   n
    PAD SWAP 1+             \ a+1 pad  n+1
    CMOVE 
;  


\
: PAD" ( -- )  \
    STATE @
    IF
        HERE ,"
        COMPILE >PAD
    ELSE
        [CHAR] " WORD       \ a
        >PAD
    THEN
;    

\
