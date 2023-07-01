\
\ }ZPAD.f
\
\ runtime portion of PAD". See PAD~.f
\ this definition ports a string+length into a z-string to PAD
: >ZPAD  ( a n -- )
    PAD 255 BLANK           \ a    n
    2DUP + 0                \ a    n  a+n   0
    SWAP !                  \ a    n
    PAD SWAP                \ a  pad  n
    1+ CMOVE 
;  
