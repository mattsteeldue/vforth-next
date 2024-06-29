\
\ UART-SYS.f
\

\ This file is to be included by RPi0 prviding some
\ constants and variable useful to customize
\ _________________________________________________________
\

CREATE UART-SYS

\ system variables alias
\ 
$5C08 CONSTANT UART-LASTK 
$5C78 CONSTANT UART-FRAMES
$5C6A CONSTANT UART-FLAGS2

\ Uart hardware I/O ports
\
$143B CONSTANT UART-RX-PORT
$133B CONSTANT UART-TX-PORT
$153B CONSTANT UART-CT-PORT

\ Uart burst-read timeout and chunk-length
\ The inner part of burst-read routine takes 112 T-States, this means that
\ to have 1 millisecond timemout you have to specify 250.
\ Timeout for the first byte is set at 200 ms == 50000.
\ Timeouts for the next bytes is set at 20 ms ==  5000.
\ This means we expect RPi0 to reply within 250 ms to any command we issue
\ and any subsequent delay greater than 40 ms ends output collection.
\
VARIABLE UART-1ST-TIMEOUT    50000 UART-1ST-TIMEOUT !
VARIABLE UART-2ND-TIMEOUT     5000 UART-2ND-TIMEOUT !
VARIABLE UART-CHUNK-LEN       8192 UART-CHUNK-LEN !

\ address at MMU7 usually 8k-page #1 is free for use
\
$E000 CONSTANT UART-BUFF

\ keep current escape-sequence status
VARIABLE UART-ESCAPE-STATUS 

\ two bytes representing two characters, i.e. the state of a flashing cursor
VARIABLE UART-CURSOR-FACE    
VARIABLE UART-CURSOR-PHASE   $20 UART-CURSOR-PHASE !
