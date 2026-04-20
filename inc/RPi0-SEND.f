\
\ RPi0-SEND.f
\
.( RPi0-SEND )

\ send to RPi0 the text given at a2 for n2 bytes long
\ collecting up to n1 bytes as reply to address a1

NEEDS RPi0

BASE @ DECIMAL

\
: RPi0-SEND ( a1 n1 a2 n2 -- n3 )
    2DUP
    \ send n2 bytes text at a2 and wait for the same echo
    UART-SEND-TEXT  UART-WAIT-STR 
    \ sending CR triggers the execution
    UART-SEND-CR    UART-WAIT-CR-LF 
    \ accept output to addr a1 (max n1 bytes)
    UART-RX-BURST 7 - 0 MAX 
;

BASE !
