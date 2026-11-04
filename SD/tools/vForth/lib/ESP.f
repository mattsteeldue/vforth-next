( ESP8266 WiFi chip library )
\
\ Talk to the ESP8266 WiFi chip of the Next through its UART, using the
\ text "AT" command set of its firmware. Phase 1 of
\ planners/WIFI-HTTP-PLAN.md: select the chip and talk to it by hand.
\
\   ESP              terminal: type AT commands, see the replies,
\                    BREAK to leave. Use CAPS LOCK: AT is uppercase.
\   ESP" AT+GMR"     send one command line and show the reply
\   ESP-REPLY        show what else arrived (slow replies)
\
\ ESP-INIT (or ESP) must come first: it selects the ESP UART, sets
\ 115200 baud and the CPU at 28 MHz, which is left on afterwards.
\
\ The ESP is assumed to be already joined to a WiFi network (it keeps
\ it in its own flash memory): check with  ESP" AT+CWJAP?"
\ _________________________________________________________

MARKER NO-ESP

NEEDS UART          \ the common UART primitives

\ _________________________________________________________
\
\ Select the ESP UART and set Baudrate d, e.g.  #115.200 ESP-SELECT
\ $153B bit 6 = 0 selects the ESP; a second write with bit 4 set
\ clears bits 16:14 of the 17-bit prescaler, then the 14 lower bits
\ are set by UART-SET-BAUDRATE.
: ESP-SELECT  ( d -- )
    \ go max speed (28 MHz), the UART is faster than Forth at 3.5 MHz
    3 7 REG!
    \ select the ESP UART
    $00 UART-CT-PORT P!
    $10 UART-CT-PORT P!
    \ 8-bit frame, no parity, one stop bit, no hardware flow-control:
    \ the ESP honours flow-control only on issue 4 boards
    $18 UART-FW-PORT P!
    UART-SET-BAUDRATE
    \ AT commands end with CR LF
    1 UART-CRLF !
    2 ms
    UART-FLUSH
;

\ _________________________________________________________
\
: ESP-INIT  ( -- )
    #115.200 ESP-SELECT
;

\ _________________________________________________________
\
\ Read what the ESP sends until it keeps quiet, and show it.
\ The reply lands in UART-BUFF, at $E000 with 8K-page 1 in MMU7,
\ then the page previously in MMU7 is restored.
: ESP-REPLY  ( -- )
    MMU7@ >R  1 MMU7!
    UART-BUFF UART-CHUNK-LEN UART-RX-BURST
    UART-BUFF SWAP CHUNK-EMIT
    R> MMU7!
;

\ _________________________________________________________
\
\ Send one command line, without CR LF, and show the reply
: ESP-CMD  ( a n -- )
    0 UART-ESCAPE-STATUS !
    UART-SEND-TEXT UART-SEND-EOL
    ESP-REPLY
;

\ _________________________________________________________
\
\ Interpret only:  ESP" AT+CIFSR"
: ESP"  ( -- )
    [CHAR] " WORD COUNT ESP-CMD
;

\ _________________________________________________________
\
\ Terminal on the ESP
: ESP  ( -- )
    ESP-INIT
    MMU7@ >R
    TERM
    R> MMU7!
;
