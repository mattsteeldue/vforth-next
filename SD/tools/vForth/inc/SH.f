\
\ SH.f
\
.( sh )

\ Accept text from current input stream and send it to RPi0 
\ discarding at most 1K reply

NEEDS ASK

\ 
\
: sh ( -- cccc )
    ASK DROP
;

