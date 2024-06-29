\
\ SEND.f
\
.( SEND )

\ send to RPi0 the text given at a2 for n2 bytes long
\ collecting up to n1 bytes as reply to address a1

NEEDS RPi0

BASE @ DECIMAL

\
: SEND ( a1 n1 a2 n2 -- n3 )
    2DUP
    UART-SEND-TEXT  UART-WAIT-FOR 
    UART-SEND-CR    UART-WAIT-CR-LF 
    UART-RX-BURST 7 - 0 MAX 
;

BASE !
