\
\ open~}.f
\

\ Used only interactively to open a file for write or overvrite
\ in the form:
\
\   OPEN"> filename.ext"

.( OPEN"> )

BASE @

DECIMAL

: OPEN"> ( -- fh )
    [CHAR] " WORD               \  a
    COUNT                       \  a+1  n
    OVER +                      \  a+1  a+n+1
    0 OVER C!                   \  a+1  a+n+1 
    %1110 F_OPEN 
    43 ?ERROR
;

BASE !

