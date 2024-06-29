\
\ ASK.f
\
.( ASK )

\ Accept text from current input stream and send it to RPi0 
\ collecting any reply to PAD returning n the length of reply. 

NEEDS RPi0
NEEDS THIS
NEEDS SEND

BASE @ DECIMAL

\ 
\
: ASK ( -- n )
    PAD 1024 THIS SEND
;

BASE !
