\
\ 047-uart.f
\ UART serial communication with lib/UART-SYS.f.
\
\ The ZX Next includes a hardware UART accessible via I/O ports
\ $133B (TX), $143B (RX), $153B (control), $163B (flow setup).
\ lib/UART-SYS.f defines port constants and variables.  lib/RPi0.f
\ builds on this to communicate with a Raspberry Pi Zero connected
\ via the GPIO header at 115200 baud.  The key user-facing word is
\ TERM, which provides a bidirectional terminal session.
\
\ Reference: sec.9 (communications)
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   047 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 047 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 047: UART communication loaded. ) CR
.(     Type NEWTASK to unload.                  ) CR

NEEDS UART-SYS

\ ===========================================================================
\ 1. UART hardware ports
\ ===========================================================================
\
\ Port constants (defined in UART-SYS):
\   UART-RX-PORT  $143B   read one byte from UART
\   UART-TX-PORT  $133B   write one byte to UART / status
\   UART-CT-PORT  $153B   UART control register
\   UART-FW-PORT  $163B   UART flow setup
\
\ UART-TX-PORT status bits (read):
\   bit 0 : RX byte ready     (1 = byte available in RX buffer)
\   bit 1 : TX busy           (1 = transmitter sending)
\   bit 4 : TX buffer empty   (1 = ready to send)

\ ===========================================================================
\ 2. Setting baud rate
\ ===========================================================================
\
\ The prescalar for the UART is:  sysclock / baudrate
\ UART-SET-BAUDRATE ( d -- ) accepts a double integer baud rate.
\
\ UART-SET-PRESCALAR ( n -- ) sends the 14-bit prescalar value.
\ UART-BAUD-PRESCALAR ( d -- n ) computes the prescalar from baud.
\ UART-VIDEO-TIMING ( -- d ) returns the system clock in MHz*100.
\
\ Common baud rates (double integers):
\   9600      -->  9.600
\   38400     -->  38.400
\   115200    -->  115.200
\
\ Example: set 115200 baud
\   115.200 UART-SET-BAUDRATE
\
\ The system clock depends on the video timing mode (reg $17).
\ UART-VIDEO-TIMING reads this and returns the appropriate clock.

\ ===========================================================================
\ 3. Sending bytes
\ ===========================================================================
\
\   UART-TX-BYTE ( b -- )   wait until TX is free, then send byte b
\   ?UART-BUSY-TX ( -- f )  true if TX is currently sending
\
\ UART-TX-BYTE polls ?UART-BUSY-TX until it is false (or BREAK),
\ then writes to UART-TX-PORT.  There is no TX hardware buffer, so
\ each byte must be sent after the previous one completes.
\
\ Convenience senders:
\   UART-SEND-CR   ( -- )   send $0D (carriage return)
\   UART-SEND-LF   ( -- )   send $0A (line feed)
\   UART-SEND-^D   ( -- )   send $04 (end of transmission)
\   UART-SEND-^C   ( -- )   send $03 (end of text / interrupt)
\   UART-SEND-TEXT ( a n -- ) send n bytes from address a

\ ===========================================================================
\ 4. Receiving bytes
\ ===========================================================================
\
\   UART-RX-BYTE ( -- b | 0 )   read one byte from UART RX port
\                               returns 0 if no byte is ready
\   ?UART-BYTE-READY ( -- f )   true if a byte is available
\   UART-WAIT-B ( b -- )        wait for specific byte or BREAK
\   UART-WAIT-STR ( a n -- )    wait for specific string
\   UART-RX-TIMEOUT ( n -- c|0) wait up to n ms for a byte

\ ===========================================================================
\ 5. Demo: echo received bytes to screen
\ ===========================================================================

NEEDS ms

: UART-ECHO  ( -- )
    ." UART echo (BREAK to stop)..." CR
    BEGIN
        ?UART-BYTE-READY IF
            UART-RX-BYTE EMIT
        THEN
        ?TERMINAL
    UNTIL
    CR ." Done." CR
;

\ ===========================================================================
\ 6. Demo: send a test string
\ ===========================================================================

CREATE TEST-MSG  ," Hello from vForth!"

: UART-HELLO  ( -- )
    ." Sending test string to UART..." CR
    TEST-MSG COUNT UART-SEND-TEXT
    UART-SEND-CR
    ." Sent." CR
;

\ ===========================================================================
\ 7. Demo: simple UART loopback test
\ ===========================================================================
\
\ Connect TX to RX (loopback) and run UART-LOOPBACK.
\ Each sent byte should be received back immediately.

: UART-LOOPBACK  ( -- )
    ." Loopback test (TX->RX, BREAK to stop):" CR
    0                         \ byte counter
    BEGIN
        DUP 255 AND UART-TX-BYTE   \ send byte
        50 UART-RX-TIMEOUT         \ wait 50ms for echo
        ?DUP IF
            EMIT              \ show received byte
        THEN
        1+
        ?TERMINAL
    UNTIL
    DROP CR ." Done." CR
;

\ ===========================================================================
\ 8. Notes on RPi0 integration
\ ===========================================================================
\
\ lib/RPi0.f builds a full terminal emulator on top of UART-SYS.
\ The main entry point is:
\
\   NEEDS RPi0
\   RPi0              \ initialise and open terminal session
\
\ Inside the terminal session, typing commands at the ZX Next
\ keyboard sends them to Linux running on the RPi0.  Responses
\ are displayed on the ZX Next screen.  The special prefix # allows
\ sending Forth commands to the vForth interpreter from the terminal.
\
\ See tutorial 048 for the full RPi0 usage guide.

\ ===========================================================================
\ 9. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ UART tests require hardware connection.
\
\ NEEDS TESTING
\ T{  UART-RX-PORT  ->  5179   }T   \ $143B
\ T{  UART-TX-PORT  ->  4923   }T   \ $133B
