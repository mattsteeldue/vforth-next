( UART Raspberry PI Zero library )
\
\ This source provides semantics to talk with Raspberry PI Zero via UART.
\ RPI0 does the following:
\ 1. Select RPi0's hardware UART and set Baudrate 115.200
\ 2. Send a few EOT just as if we're unsure about RPi0 status
\ 3. Wait for SUP> prompt.
\
\ _________________________________________________________

\ NEEDS ASSEMBLER
NEEDS UART-SYS
NEEDS UART-RX-BURST
NEEDS MS
NEEDS INVV
NEEDS TRUV

MARKER REDO

: BELL 7 EMIT 7 EMIT 7 EMIT 7 EMIT 7 EMIT 7 EMIT ;

\ _________________________________________________________
\
\ map for special Symbol-Shift Keys
\ some keys are encoded by Forth's KEY (e.g. $0C or $06)
CREATE RPI0-TKB1
\ STOP   NOT    STEP   TO     THEN   AND    OR     AT     delete <=     <>     >= 
  $E2 C, $C3 C, $CD C, $CC C, $CB C, $C6 C, $C5 C, $AC C, $0C C, $C7 C, $C9 C, $C8 C,

CREATE RPI0-TKB2
\ ~      |      \      {      }      [      ]      ^[     bs     ^Z     ^X     ^C 
  $7E C, $7C C, $5C C, $7B C, $7D C, $5B C, $5D C, $1B C, $08 C, $1A C, $18 C, $03 C,

\ _________________________________________________________

\ map above listed char-code.
\ should handle Caps-Lock key too.
: MAP-KEYB ( c -- c )
    >R RPI0-TKB2 RPI0-TKB1 #12 R> (MAP)
;

\ _________________________________________________________

\ Table of actual system clock speeds depending on video mode as per 
\ NextREG 17 (11h) - Video Timing (see manual)
\ These are double precision integers you can read with 2@
\ N.B. Using 115200 baud, integer precision is coarse enough to allow
\ values to be divided by 100 to be able to better handle them later
CREATE UART-SYS-CLOCK
DECIMAL 28.0000   , ,   \ Base VGA timing   28 MHz
        28.5714   , ,   \ VGA setting 1     28.571.429 Hz
        29.4643   , ,   \ VGA setting 2     29.464.286 Hz
        30.0000   , ,   \ VGA setting 3     30 MHz
        31.0000   , ,   \ VGA setting 4     31 MHz
        32.0000   , ,   \ VGA setting 5     32 MHz
        33.0000   , ,   \ VGA setting 6     33 MHz
        27.0000   , ,   \ Digital           27 MHz

\ _________________________________________________________

\ compute actual clock speed depending on video mode
\ ask the hardware NextREG 17 (11h) and return a double precision integer
\ expressed in MHz/100
: UART-VIDEO-TIMING  ( -- d )
    $11 REG@ 7 AND              \ Video timing register: 0-7
    2* 2* UART-SYS-CLOCK + 2@    \ fetch from array above
;

\ _________________________________________________________

\ compute prescalar to be used with UART-SET-PRESCALAR
: UART-BAUD-PRESCALAR ( d -- n )
    #100 M/             \ divide BAUD by 100 to able to handle it
    UART-VIDEO-TIMING   \ get actual system clock speed / 100
    ROT M/
;

\ _________________________________________________________

\ send 14-bits-prescalar to UART receive port
\ prescalar = sysclock / baudrate
: UART-SET-PRESCALAR ( n -- )
    DUP
    $7F AND UART-RX-PORT P!     \ send low 7 bits of 14 bits
    7 RSHIFT  
    $80  OR UART-RX-PORT P!     \ send high 7 bits of 14 bits
;

\ _________________________________________________________
\
\ Set UART baud rate.
\ usage is: 115200. UART-SET-BAUDRATE
: UART-SET-BAUDRATE ( d -- )
    UART-BAUD-PRESCALAR
    UART-SET-PRESCALAR
;

\ _________________________________________________________
\
\ Select Raspberry PI Zero UART and set Baudrate d
: RPI0-SELECT  ( d -- )
    UART-CT-PORT P@ 
    $80 AND #24 ?ERROR
    3 7 REG!              \ go max speed (28 MHz)
    $40 UART-CT-PORT P!   \ select PI Zero UART control port
    UART-SET-BAUDRATE     \ uses double integer param
    $30 $A0 REG!          \ PI Peripheal enable
\   $91 $A2 REG!          \ PI I2S Audio control
;

.( .)

\ _________________________________________________________
\
\ Check if UART is busy sending a byte.
\ non-zero when transmitter is busy sending a byte
: ?UART-BUSY-TX ( -- f )
    UART-TX-PORT P@   \ UART TX port
    02 AND            \ bit is set when busy
;

\ _________________________________________________________
\
\ There is no transmit buffer so program must make sure the
\ last transmission is complete before sending another byte
\ Wait until transmission is possible or Break is pressed.
: UART-TX-BYTE ( b -- )
    BEGIN
        ?UART-BUSY-TX NOT  
        ?TERMINAL 
        OR
    UNTIL
    UART-TX-PORT P!         \ Transmit anyway
;

\
\ _________________________________________________________
\
\ End Of Transmission ^D
: UART-SEND-EOT ( -- )      
    04 UART-TX-BYTE
;
\
\ _________________________________________________________
\
\ End of TeXt ^C
: UART-SEND-ETX ( -- )      
    03 UART-TX-BYTE
;
\ _________________________________________________________
\
\ CR
: UART-SEND-CR ( -- )      
    $0D UART-TX-BYTE
;
\ _________________________________________________________
\
\ LF
: UART-SEND-LF ( -- )      
    $0A UART-TX-BYTE
;
\
\ _________________________________________________________
\
\ Send a string of text to RPi0 
: UART-SEND-TEXT ( a n -- ) 
    BOUNDS
    ?DO
        I C@ UART-TX-BYTE
    LOOP
;

\ _________________________________________________________
\
\ Check if UART has received a byte
\ true flag when byte ready, false elsewhere
: ?UART-BYTE-READY  ( -- f )  
    UART-TX-PORT  P@ 
    01 AND
;

\ _________________________________________________________
\
\ accept a byte if available, 0x00 if no byte is available.
: UART-RX-BYTE  ( -- b | 0 )     
    UART-RX-PORT  P@
;

\ _________________________________________________________
\
\ wait for a specific byte or Break key to bailout
\ usually this will quit to Forth prompt also
: UART-WAIT-B  ( b -- )     
    BEGIN                   \ b
        UART-RX-BYTE OVER = \ b f
        ?TERMINAL OR        \ b f
    UNTIL DROP              \
;

\ _________________________________________________________
\
\ wait CR-LF
: UART-WAIT-CR-LF ( -- )      
    $0D UART-WAIT-B
    $0A UART-WAIT-B
;

\ _________________________________________________________
\
\ wait for a specific string given at address a length n
: UART-WAIT-FOR  ( a n -- )
    BOUNDS
    ?DO
        I C@ UART-WAIT-B
    LOOP
;

\ _________________________________________________________
\
\ wait for a specific string "SUP> "

CREATE SUP>-STR ," SUP>"

\ to synchronize things
: UART-WAIT-PROMPT  ( -- )
    SUP>-STR COUNT UART-WAIT-FOR
\   [CHAR] S UART-WAIT-B
\   [CHAR] U UART-WAIT-B
\   [CHAR] P UART-WAIT-B
\   [CHAR] > UART-WAIT-B
\         BL UART-WAIT-B
;

\ _________________________________________________________
\
\ wait for a byte with timeout expressed in ms
: UART-RX-TIMEOUT ( n -- c | 0 )
    0 SWAP                      \ 0 n
    1+ 0                        \ 0 n+1 0
    DO                          \ 0
        ?UART-BYTE-READY IF     \ 0
            UART-RX-BYTE        \ 0 b
            SWAP DROP           \   b
            LEAVE               \   b
        THEN                    \ 0
        1 ms                    \      minimum delay
    LOOP                        \ 0
;

.( .)

\ _________________________________________________________
\
\ based on FRAMES, decides which cursor face is now displayed
: UART-SHOW-CURSOR ( -- )
    UART-FLAGS2 C@ 
    8 AND
    IF 
        $8F5F UART-CURSOR-FACE !
    ELSE
        $8F8C UART-CURSOR-FACE !
    THEN  
    UART-CURSOR-FACE
    UART-FRAMES C@ $10 AND IF 1+ THEN
    C@ EMITC 8 EMITC
;

\ _________________________________________________________

\ this relies on standard interrupt keyboard service
: UART-GET-KEYB ( -- c )
    UART-LASTK C@
    DUP IF 0 UART-LASTK C! THEN
;

\
\ _________________________________________________________

\ type a character from RPi0, using some ansi-escape filtering
: C-EMIT ( c -- )
    UART-ESCAPE-STATUS @ 
    IF  \ within escape sequence
        DUP [CHAR] m = IF 0 UART-ESCAPE-STATUS ! THEN
            [CHAR] K = IF 0 UART-ESCAPE-STATUS ! THEN
    ELSE  
\       0 UART-ESCAPE-STATUS !
        DUP $0A - 
        IF
            DUP $0D = IF SPACE CR THEN
            DUP $08 = IF SPACE 8 EMITC 8 EMITC THEN
            DUP $1B = IF 
                1 UART-ESCAPE-STATUS ! 
            ELSE
                DUP BL < NOT 
                IF
                    DUP EMIT
                THEN
            THEN
        THEN
        DROP    
    THEN \ escape
; 

\ _________________________________________________________
\
\ emit a string previously received from RPi0
: CHUNK-EMIT ( a n -- )
    BOUNDS
    ?DO
        I C@ C-EMIT
    LOOP
;

\ _________________________________________________________
\

VARIABLE UART-FORTH-BUF 
VARIABLE UART-FORTH-PTR 
VARIABLE UART-FORTH-CNT 
VARIABLE UART-FORTH-FLG
VARIABLE UART-META          1 UART-META !

\ _________________________________________________________
\
\ Terminal basic initialization 
: TERM-INIT   ( -- )
    1 BLOCK  UART-FORTH-BUF !
    1 BLOCK  UART-FORTH-PTR !
    0 UART-FORTH-CNT !
    0 UART-FORTH-FLG !
    0 UART-LASTK C! 
    0 UART-FLAGS2 C! 
    $0D UART-TX-BYTE
\   6 $1E EMITC EMITC  \ narrow font 85 char per row.
    7  17 EMITC EMITC   \ paper 7 "white" , 1 "blue"
;

\ _________________________________________________________
\
\ Session is done, set normal font 64 char per font
: TERM-DONE
    8 $1E EMITC EMITC  
;

.( .)

\ _________________________________________________________
\
: FORTH-CMD ( c -- )
    \ collecting chrs for Forth directive ?            
    UART-FORTH-FLG @ 
    IF  
        DUP $0D = 
        IF  \ activate
            drop
            0 UART-FORTH-FLG ! 
            0 >in ! 
            1 blk ! 
            interpret
        ELSE
            DUP 08 = 
            IF
                \ backspace
                UART-FORTH-BUF < UART-FORTH-PTR 
                IF
                    -1   UART-FORTH-PTR +!
                    -1   UART-FORTH-CNT +!
                THEN    
                DROP 
            ELSE
                \ accumulate 
                UART-FORTH-PTR @ C!
                \ next position ?
                UART-FORTH-PTR @ B/BUF < IF
                    1   UART-FORTH-PTR +!
                    1   UART-FORTH-CNT +!
                THEN
            THEN
        THEN
    ELSE
        \ # marks collection start if UART-META is enabled
        [CHAR] # =
        UART-META @ AND
        IF
            1 UART-FORTH-FLG ! 
            0 UART-FORTH-CNT !
            1 BLOCK DUP B/BUF BLANK
              UART-FORTH-PTR !
        THEN                
    THEN
;

\ _________________________________________________________
\
: TERM ( -- )
    TERM-INIT
    0 UART-ESCAPE-STATUS !
    BEGIN
        UART-SHOW-CURSOR 
        UART-GET-KEYB
        MAP-KEYB        \ must decode before
        
        ?DUP IF
            \ Forth processing
            DUP FORTH-CMD
            \ Linux processing
            DUP $0D =  
            IF
                UART-TX-BYTE 1 MMU7! 
                UART-BUFF UART-CHUNK-LEN  UART-RX-BURST 
                UART-BUFF SWAP CHUNK-EMIT 
            ELSE
                UART-TX-BYTE 
            THEN
        THEN
        ?UART-BYTE-READY IF 
            UART-RX-BYTE
          \ DUP $80 > IF INVV THEN 
            HERE C!
            HERE 1  CHUNK-EMIT
          \ TRUV 
        THEN
    ?TERMINAL UNTIL 
    TERM-DONE
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
    UART-SEND-ETX
    UART-SEND-EOT
\   UART-WAIT-PROMPT
    TERM
    
;

RPI0-INIT
