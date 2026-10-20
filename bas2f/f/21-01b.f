\ 21-01b.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/21-01.txt
\ guide: doc/basic-to-vforth/21-optional-features.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 .date
\   20 .time

\ --- the translation

\ 21-optional-features.md:108
\ no-test in the guide: it waits for keys, never ends or
\ needs hardware the emulator lacks
NEEDS RPI0  NEEDS S"
: ESP  ( -- )                       \ the UART to the ESP, 115200 baud
    0 UART-CT-PORT P!  115.200 UART-SET-BAUDRATE ;
: REPLY  ( -- )                     \ print until 200 ms of silence
    BEGIN  200 UART-RX-TIMEOUT ?DUP
    WHILE  DUP 10 = IF DROP ELSE EMIT THEN
    REPEAT ;
: AT?  ( -- )
    ESP  S" AT" UART-SEND-TEXT  UART-SEND-CR UART-SEND-LF  REPLY ;
AT?
