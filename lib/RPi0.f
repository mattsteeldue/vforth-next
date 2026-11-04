( UART Raspberry PI Zero library )
\
\ This source provides semantics to talk with Raspberry PI Zero via UART.
\ Definition   RPI0   performs the following:
\ 1. Select RPi0's hardware UART and set Baudrate 115.200
\ 2. Send a few EOT just as if we're unsure about RPi0 status
\ 3. Wait for SUP> prompt.
\
\ _________________________________________________________

\ NEEDS ASSEMBLER \ no more
NEEDS UART          \ import the UART primitives
NEEDS INVV          \ inverse video
NEEDS TRUV          \ true video

\ _________________________________________________________
\
\ wait for a specific string "SUP> "

CREATE SUP>-STR ," SUP>"

\ to synchronize things
: UART-WAIT-PROMPT  ( -- )
    SUP>-STR COUNT UART-WAIT-STR
;

\ _________________________________________________________
\
\ Select Raspberry PI Zero UART and set Baudrate d
: RPI0-SELECT  ( d -- )
    UART-CT-PORT P@ 
    $80 AND #24 ?ERROR
    \ go max speed (28 MHz)
    3 7 REG!              
    \ select PI Zero UART control port
    $40 UART-CT-PORT P!   
    \ Hardware flow-control, 8-bit-frame, no-parity-check, one-stop-bit
    $38 UART-FW-PORT P!   
    \ PI Peripheal enable
    $30 $A0 REG!          
    \ I2S state. I2S is stereo, 
    \ Audio Flow Direction: PCMD_OUT from Pi, PCMD_IN to Pi (pi)
    \ Mute left and right side
    \ Direct I2S audio to EAR on port 0xFE
    \ Slave mode (PCM_CLK, PCM_FS external)
\   $D2 $A2 REG!          \ PI I2S Audio control
\   $91 $A2 REG!          \ PI I2S Audio control
    \ uses double integer param
    UART-SET-BAUDRATE
    2 ms
    UART-SEND-CR
    UART-SEND-^C
    UART-SEND-^C
;

\ _________________________________________________________
\
: RPI0-INIT ( -- )
    #115.200 RPI0-SELECT
;

\ _________________________________________________________
\
: RPI0 ( -- )
    RPI0-INIT
    UART-SEND-^C
    UART-SEND-^D
\   UART-WAIT-PROMPT
    TERM
    
;

RPI0-INIT
