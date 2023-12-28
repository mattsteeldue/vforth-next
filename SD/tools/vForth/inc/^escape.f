\
\ ^escape.f
\
.( .)
\
\

BASE @ HEX \ save base status

HEX
CODE ?ESCAPE ( -- )

    3E C, FE C,             \ ldn     a'|  HEX FE N,  
    DB C, FE C,             \ ina     FE P,
    2F C,                   \ cpl
    6F C,                   \ ld      l'|  a|

    3E C, F7 C,             \ ldn     a'|  HEX F7 N,  
    DB C, FE C,             \ ina     FE P,
    2F C,                   \ cpl

    A5 C,                   \ anda     l|
    E6 C, 01 C,             \ andn     1  N,

    26 C, 00 C,             \ ldn     h'|  0  N,
    6F C,                   \ ld      l'|  a|
    E5 C,                   \ push    hl|

    DD C, E9 C,             \ jp (ix)
SMUDGE 

BASE !
