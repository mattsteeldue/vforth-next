\
\ SH.f
\
.( sh )

\ Accept text from current input stream and send it to RPi0 
\ discarding at most 1K reply

NEEDS RPi0
NEEDS THIS
NEEDS SEND

BASE @ DECIMAL

\ 
\
: sh ( -- cccc )
    HERE 1024 
    THIS SEND DROP 
;

BASE !
