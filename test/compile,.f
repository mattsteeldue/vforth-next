\
\ test/compile,.f
\


NEEDS TESTING

NEEDS COMPILE,
NEEDS :NONAME

( Test Suite - Dictionary )

TESTING F.6.2.0945 - COMPILE,

:NONAME DUP + ; CONSTANT dup+
T{ : q dup+ COMPILE, ; -> }T
T{ : as [ q ] ; -> }T
T{ 123 as -> 246 }T

