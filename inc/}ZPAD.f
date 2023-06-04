\
\ }ZPAD.f
\
\ runtime portion of PAD". See PAD~.f
\ this definition ports a string+length into a z-string to PAD
: >ZPAD  ( a n -- )
    PAD 256 BLANK           \ a     n
    2DUP + 0                \ a+1   n  a+n+1  0
    SWAP !                  \ a+1   n
    PAD SWAP 1+             \ a+1 pad  n+1
    CMOVE 
;  

