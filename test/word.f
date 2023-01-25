\
\ test/while.f
\


NEEDS TESTING

( Test Suite - Parser Input Source Control  )

TESTING 6.1.2450 - WORD

: GS3 WORD COUNT SWAP C@ ;
T{ BL GS3 HELLO -> 5 CHAR H }T
T{ CHAR " GS3 GOODBYE" -> 7 CHAR G }T

\ T{ BL GS3 
\    DROP -> 0 }T \ Blank lines return zero-length strings

\ vForth WORD uses a 0x00 "null" string to handle the end of input source
T{ BL GS3
   -> 1 0 }T 
