\
\ }ZPAD.f
\
\ runtime portion of PAD". See PAD~.f
\ this definition ports a string+length into a z-string to PAD
: >ZPAD  ( a n -- )
    PAD 255 BLANK           \ a    n
    >R                      \ a             R: n
    PAD R@                  \ a  pad  n
    CMOVE                   \
    0 PAD R>                \ 0  pad  n
    + C!                    \
;  

