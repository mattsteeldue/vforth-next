\
\ 048-rpi0.f
\ Raspberry Pi Zero bridge: RPI0, TERM, and the # meta-command.
\
\ The ZX Next GPIO header connects to a Raspberry Pi Zero (RPi0)
\ via UART at 115200 baud.  lib/RPi0.f provides a complete terminal
\ emulator that lets you interact with Linux running on the RPi0.
\ The special character # starts a Forth meta-command: text after #
\ is sent back to vForth for interpretation, so you can mix Forth
\ and Linux commands in one session.
\
\ Reference: sec.9
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   048 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 048 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 048: Raspberry Pi Zero bridge loaded. ) CR
.(     Type NEWTASK to unload.                        ) CR

NEEDS RPi0

\ ===========================================================================
\ 1. Hardware setup
\ ===========================================================================
\
\ Connect ZX Next GPIO header to Raspberry Pi Zero:
\   ZX Next pin  ->  RPi0 pin
\   TX (UART TX) ->  RPi0 UART RX (pin 10)
\   RX (UART RX) ->  RPi0 UART TX (pin 8)
\   GND          ->  RPi0 GND     (pin 6 or 14)
\
\ The RPi0 must have serial console enabled on /dev/ttyS0 or
\ /dev/serial0 at 115200 baud, 8N1, with hardware flow control
\ disabled.  Typical /boot/config.txt settings:
\   enable_uart=1
\   core_freq=250
\
\ The RPi0 user must be logged in or auto-login configured so that
\ a shell prompt (usually a "$" or "#" prompt) is available when
\ the UART is opened.

\ ===========================================================================
\ 2. Initialising the RPi0 connection
\ ===========================================================================
\
\   RPI0-SELECT ( d -- )   select RPi0 UART hardware, set baud d
\
\   RPI0-INIT ( -- )       RPI0-SELECT 115.200
\                          sets CPU to 28 MHz, configures UART ports
\
\ RPI0-INIT is called automatically by RPI0 and TERM.
\
\ The initialisation sequence:
\   1. Check bit 7 of UART-CT-PORT; if set, another device is using
\      the UART -> error 24 if busy
\   2. Set CPU to maximum speed (3 SPEED!)
\   3. Write $40 to UART-CT-PORT to select the RPi0 UART
\   4. Write $38 to UART-FW-PORT (8-bit, no parity, 1 stop bit,
\      hardware flow control enabled)
\   5. Write $30 to Next reg $A0 (enable RPi0 peripheral)
\   6. Calculate and set baud prescalar for 115200

\ ===========================================================================
\ 3. RPI0 -- open terminal session
\ ===========================================================================
\
\   RPI0 ( -- )   initialise and open an interactive terminal session
\
\ RPI0 calls:
\   RPI0-INIT          set up hardware
\   UART-SEND-^C       send interrupt to clear any stuck command
\   UART-SEND-^D       send end-of-transmission
\   TERM               start the terminal loop
\
\ Inside TERM:
\   - ZX Next keyboard input is sent to the RPi0 via UART
\   - Data arriving from the RPi0 is displayed on the ZX Next screen
\   - Pressing BREAK (CAPS SHIFT + SPACE) exits the terminal
\
\ Key mappings inside TERM:
\   Most keys map to standard ASCII sent to the RPi0.
\   ENTER   -> CR ($0D) then RPi0 output is displayed
\   DELETE  -> BS ($08)
\   CAPS SHIFT + various keys map via RPI0-TKB1/RPI0-TKB2 tables

\ ===========================================================================
\ 4. The # meta-command
\ ===========================================================================
\
\ Inside a TERM session, typing # at the start of a line puts TERM
\ into "Forth command" mode.  Everything typed until ENTER is
\ collected into block 1 memory and interpreted by vForth when ENTER
\ is pressed.
\
\ This allows mixing Linux and Forth commands:
\   ls -la          (sent to RPi0, output shown on ZX Next)
\   # 3 SPEED!      (interpreted by vForth: set 28 MHz)
\   # PWD           (interpreted by vForth: print directory)
\   cat file.txt    (show file on RPi0)
\
\ UART-META controls whether # is active:
\   1 UART-META !   enable # meta-command (default)
\   0 UART-META !   disable (# sent literally to RPi0)

\ ===========================================================================
\ 5. TERM-INIT and TERM-DONE
\ ===========================================================================
\
\   TERM-INIT ( -- )   initialise terminal state, set font to 73 cols
\   TERM-DONE ( -- )   restore normal font (64 cols)
\
\ TERM-INIT:
\   - sets UART-FORTH-BUF to block 1
\   - clears UART-FORTH-CNT and UART-FORTH-FLG
\   - clears UART-LASTK (last keyboard char variable)
\   - sends CR to RPi0
\   - sets 73-char font for the ZX Next screen
\   - sets blue paper (ctrl-17 ctrl-1)
\
\ TERM-DONE restores the 64-char font.

\ ===========================================================================
\ 6. Demo: send a command to RPi0 and capture output
\ ===========================================================================
\
\ This is only useful with a connected RPi0.
\ The following definition sends "uname -a" to the RPi0, waits for
\ the response, and returns.

: PREPARE-LINUX  ( -- a n )
    RPI0-INIT
    S" uname -a" 
;

: SEND-LINUX  ( a n -- )
    ." Sending 'uname -a' to RPi0..." CR
    UART-SEND-TEXT
    UART-SEND-CR
;

: RECEIVE-LINUX ( -- )
    CR CR ." Press [BREAK] to stop" CR CR
    BEGIN
        ?UART-BYTE-READY IF
            UART-RX-BYTE EMIT
        THEN
        ?TERMINAL
    UNTIL
    CR
;


: DEMO
    PREPARE-LINUX
    SEND-LINUX
    RECEIVE-LINUX
;


\ ===========================================================================
\ 7. UART variables and buffers
\ ===========================================================================
\
\ System variable aliases (from UART-SYS.f):
\   UART-LASTK  $5C08   last key pressed (ZX Spectrum system variable)
\   UART-FRAMES $5C78   frame counter
\   UART-FLAGS2 $5C6A   flag byte 2
\
\ UART-BUFF  $E000   receive buffer at MMU7 (page 1 by default)
\ UART-CHUNK-LEN     variable: max bytes per burst read (8192)
\ UART-1ST-TIMEOUT   variable: first byte timeout (50000 ~= 200ms)
\ UART-2ND-TIMEOUT   variable: subsequent byte timeout (~40ms)
\
\ Adjust timeouts for slow RPi0 responses:
\   100000 UART-1ST-TIMEOUT !   \ 400 ms first byte

\ ===========================================================================
\ 8. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ RPi0 tests require physical hardware.
\
\ NEEDS TESTING
\ T{  UART-META @  ->  1  }T   \ meta-command enabled by default
