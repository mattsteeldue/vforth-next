\
\ TOUCH.f
\
\ accept the following string as a filename and creates an empty file
\
\ Typical usage:   touch <filename>
\
\
: TOUCH ( -- cccc )
    BL WORD COUNT       \  a  n
    OVER + DUP 1+       \  a  n+a  n+a+1
    0 SWAP !            \  a  n+a
    [ 8 3 + ] LITERAL   \  a  n+a  b
    F_OPEN DROP
    F_CLOSE DROP
;

