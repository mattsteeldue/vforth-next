\
\ test/abs.f
\


NEEDS TESTING

NEEDS CHARS

( Test Suite - Input  )

TESTING F.6.1.0695    -   ACCEPT

CREATE ABUF 80 CHARS ALLOT
: ACCEPT-TEST
     CR ." PLEASE TYPE UP TO 80 CHARACTERS:" CR
     ABUF 80 ACCEPT
     CR ." RECEIVED: " [CHAR] " EMIT
     ABUF SWAP TYPE [CHAR] " EMIT CR
;

T{ ACCEPT-TEST -> }T

