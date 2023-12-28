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
    OVER +              \  a  a+n  
    0 OVER C! 1+        \  a  a+n+1
    [ 8 3 + ] LITERAL   \  a  a+n+1  b  (open r/w existing or create file)
    F_OPEN DROP
    F_CLOSE DROP
;

