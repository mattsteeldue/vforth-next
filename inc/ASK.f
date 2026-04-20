\
\ ASK.f
\
.( ASK )

\ Accept text from current input stream and send it to RPi0 collecting 
\ any reply to PAD returning n as the length of such a reply 
\ up to 1024 bytes. PAD is always 68 bytes above HERE.

NEEDS RPi0
NEEDS THIS
NEEDS RPi0-SEND

BASE @ DECIMAL

\ 
\
: ASK ( -- n )
    PAD 1024 THIS RPi0-SEND
;

BASE !
