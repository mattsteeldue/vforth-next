\
\ test/parse.f
\

NEEDS TESTING
NEEDS PARSE

( Test Suite - Parser Input Source Control  )

TESTING F.6.2.2008 - PARSE

: GP1 ( a n -- n c ) SWAP C@ ;
T{ CHAR ) PARSE abc) NIP -> 3 }T
T{ CHAR ) PARSE abc) GP1 -> 3 CHAR a }T
T{ CHAR ) PARSE ) NIP -> 0 }T
T{ CHAR ) PARSE   ab) GP1 -> 4 BL }T
T{ CHAR " PARSE x" NIP -> 1 }T
T{ CHAR " PARSE x"CHAR y ROT DROP -> 1 CHAR y }T  \ >IN past the "

\ No test without a delimiter: the text runs to the end of the input
\ buffer, and during INCLUDE the line is padded with blanks to 510
\ characters, so its length depends on where the line ends.

