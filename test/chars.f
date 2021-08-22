\
\ test/chars.f
\


NEEDS TESTING

NEEDS CHARS

( Test Suite - Memory  )

TESTING F.6.1.0898 - CHARS

( CHARACTERS >= 1 AU, <= SIZE OF CELL, >= 8 BITS )
T{ 1 CHARS 1 <       -> <FALSE> }T
T{ 1 CHARS 1 CELLS > -> <FALSE> }T
( TBD: HOW TO FIND NUMBER OF BITS? )

