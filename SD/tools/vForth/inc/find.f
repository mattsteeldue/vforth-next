\
\ find.f
\
.( FIND included ) 6 EMIT
\
( c-addr -- c-addr 0 | xt 1 | xt -1 )
\ Find the definition named in the counted string at c-addr. 
\ If the definition is not found, return c-addr and zero. 
\ If the definition is found, return its execution token xt. 
\ If the definition is immediate, also return one (1), 
\ otherwise also return minus-one (-1). 
\ For a given string, the values returned by FIND while compiling 
\ may differ from those returned while not compiling.

: (FOUND) ( a xt b -- xt n)
    ROT DROP
    192 < IF
        -1      \ non-Immediate
    ELSE
        +1      \ Immediate
    THEN
;

: FIND (  a -- a 0  |  xt 1  |  xt -1  )
    DUP CONTEXT @ @         \ a a a1
    (FIND)                  \ a xt b tf  |  a ff
    IF                      \ a xt b
        (FOUND)             \ a xt n
    ELSE                    \ a
        DUP LATEST          \ a a a1
        (FIND)              \ a xt b tf  |  a ff
        IF                  \ a xt b
            (FOUND)         \ a xt n
        ELSE                \ a
            0               \ a 0
        THEN 
    THEN
;
