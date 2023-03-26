\
\ find.f
\
.( FIND )
\
( c-addr -- c-addr 0 | xt 1 | xt -1 )
\ Find the definition named in the counted string at c-addr. 
\ If the definition is not found, return c-addr and zero. 
\ If the definition is found, return its execution token xt. 
\ If the definition is immediate, also return one (1), 
\ otherwise also return minus-one (-1). 
\ For a given string, the values returned by FIND while compiling 
\ may differ from those returned while not compiling.


NEEDS FLIP
NEEDS 2FIND

: FIND (  a -- a 0  |  xt 1  |  xt -1  )
    DUP                     \  a  a
    2FIND                   \  a  xt  b  tf |  a  ff
    IF                      \  a  xt  b  
        ROT DROP            \  xt  b
        2* FLIP             \  xt  n
        1 SWAP +- NEGATE    \  xt  1        |  xt -1
    ELSE                    \    
        0                   \  a  ff
    THEN
;
