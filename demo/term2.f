
( UART Raspberry PI Zero )
\
NEEDS LAYERS                   NEEDS BCOPY
NEEDS TRUV    NEEDS INVV

\
MARKER DONE
\
HEX 5C08 CONSTANT LASTK          \ system variable
    143B CONSTANT UART-RX-PORT
    133B CONSTANT UART-TX-PORT
    153B CONSTANT UART-CT-PORT

\ Table of actual clock speeds depending on video mode
\ These are double precision integers you can read with 2@
HERE
DECIMAL \ values are divided by 100 to better handle them
  28.0000   , ,   \ Base VGA timing   28 MHz
  28.5714   , ,   \ VGA setting 1     28.571.429 Hz
  29.4643   , ,   \ VGA setting 2     29.464.286 Hz
  30.0000   , ,   \ VGA setting 3     30 MHz
  31.0000   , ,   \ VGA setting 4     31 MHz
  32.0000   , ,   \ VGA setting 5     32 MHz
  33.0000   , ,   \ VGA setting 6     33 MHz
  27.0000   , ,   \ Digital           27 MHz
CONSTANT SYS-CLK-ARY

HEX
\ compute actual clock speed depending on video mode
: SYS-CLOCK ( -- d )
  11 REG@ 7 AND          \ Video timing register: 0-7
  4 * SYS-CLK-ARY + 2@   \ fetch from array created before
;
\ send 14-bits prescalar to UART receive port
\ prescalar = sysclock / baudrate
: UART-SET-PRESCALAR ( n -- )
  DUP
  7F AND UART-RX-PORT P!      \ send low 7 bits of 14 bits
  7 RSHIFT                    \ presclar
  80  OR UART-RX-PORT P!      \ send high 7 bits of 14 bits
;

DECIMAL
\ compute prescalar to be used with previous definition
: UART-BAUD-TO-PRESCALAR ( d -- n )
  100 M/          \ divide BAUD by 100 to able to handle it
  SYS-CLOCK       \ obtain actual system clock speed / 100
  ROT M/
;
\ usage is: 115200. UART-SET-BAUDRATE
: UART-SET-BAUDRATE ( d -- )
  UART-BAUD-TO-PRESCALAR
  UART-SET-PRESCALAR
;

HEX
\ Select Raspberry PI Zero UART and set Baudrate
\
: PI0-SELECT  ( d -- )
  40 UART-CT-PORT P!    \ select PI Zero UART control port
  UART-SET-BAUDRATE     \ uses double integer param
  30 A0 REG!            \ PI Pheripeal enable
\ 91 A2 REG!            \ PI I2S Audio control
;

HEX
\ non-zero when transmitter is busy sending a byte
: ?UART-BUSY-TX ( -- f )
  UART-TX-PORT P@   \ UART TX port
  02 AND            \ bit is set when busy
;
\ There is no transmit buffer so program must make sure the
\ last transmission is complete before sending another byte
: UART-TX ( b -- )
  BEGIN
    ?UART-BUSY-TX  0=  ?TERMINAL OR
  UNTIL
  UART-TX-PORT P!         \ Transmit
;

DECIMAL
\ Utilities
\
: UART-SEND-EOT ( -- )   \ End Of Transmission
  04 UART-TX
;
\
: UART-SEND-ETX ( -- )   \ End of TeXt
  03 UART-TX
;

HEX
: ?UART-BYTE-READY  ( -- f )  \ non zero when byte ready
  UART-TX-PORT  P@  1 AND
;
: UART-RX  ( -- b | 0 )       \ accept a byte
  UART-RX-PORT  P@
;
: UART-WAIT ( b -- )     \ wait for a specific byte or [Break]
  BEGIN                       \ b
    UART-RX OVER =            \ b f
    ?TERMINAL OR              \ b f
  UNTIL DROP                  \
;

\ simple wait for a specific string "SUP> " prompt
: UART-WAIT-PROMPT  ( -- )
  [CHAR] S UART-WAIT
  [CHAR] U UART-WAIT
  [CHAR] P UART-WAIT
  [CHAR] > UART-WAIT
        BL UART-WAIT
;

HEX
\
CODE  DIS-INT       \ Disable interrupt
  F3 C,             \ di
  DD C, E9 C,       \ jp (ix)
SMUDGE

CODE  ENA-INT       \ Enable interrupt
  FB C,             \ di
  DD C, E9 C,       \ jp (ix)
SMUDGE
\

DECIMAL
: UART-RX-CHUNK ( t a n -- )
  DIS-INT                          \ t a n
  ROT 0 DO                         \ a n
    UART-TX-PORT P@ 1 AND IF       \ a n f   wait ready
      SWAP UART-RX-PORT P@         \ n a b   accept byte
      ?DUP 0= IF LEAVE THEN        \ n a b   0x00 quits
      OVER C! 1+ SWAP 1-           \ a n     store & incr
      DUP 0= IF LEAVE THEN         \ a n     decr counter
    THEN
  LOOP                             \ a n
  2DROP                            \
  ENA-INT
;

DECIMAL

\ send a string
HEX
: UART-SEND ( a n -- )
  BOUNDS DO
    I C@ UART-TX
  LOOP
  0D UART-TX
;
\
HERE
," perl --help"
CONSTANT CMD


HEX   \ map special Symbol-Shift Keys
HERE  \ stop not step to then and or
E2 C, C3 C, CD C, CC C, CB C, C5 C, C5 C, 0C C,
 CONSTANT TKB1
HERE  \  ~    |   \   {  }    [   ]
7E C, 7C C, 5C C, 7B C, 7D C, 5B C, 5D C, 08 C,
 CONSTANT TKB2
\
: MAP-KEYB ( c -- )
  >R TKB2 TKB1 8 R> (MAP)
  DUP 6 = IF 8 5C6A TOGGLE THEN  \ handle caps-lock
;

HEX
: TERM0-INIT   ( -- )
  0 LASTK C! 0 5C6A C! 0D UART-TX
  6 1E EMITC EMITC  \ narrow font
  HEX
;
: TERM0-DONE
  8 01E EMITC EMITC \ normal font
  DECIMAL
;
HEX

: TERM0
  TERM0-INIT
  BEGIN
    LASTK C@ ?DUP IF
      MAP-KEYB  DUP UART-TX  0 LASTK C!
    THEN
    ?UART-BYTE-READY IF UART-RX
      DUP 80 < 0= IF INVV THEN 7F AND  \ force ascii 7-bits
      DUP 20 < IF INVV DUP . THEN      \ non-printable
      DUP 0D - IF EMIT THEN TRUV       \ ignore CR
    THEN
  ?TERMINAL UNTIL TERM0-DONE
;

( UART Raspberry PI Zero - testing )
DECIMAL
: TEST0
  DECIMAL 115.200 PI0-SELECT
  UART-SEND-ETX
  UART-SEND-EOT
  UART-WAIT-PROMPT
  TERM0
;


DECIMAL 10000 CONSTANT T
: TEST2
  2 BLOCK B/BUF BLANKS 3 BLOCK B/BUF BLANKS
  4 BLOCK B/BUF BLANKS 5 BLOCK B/BUF BLANKS
  13 UART-TX 10 UART-WAIT
  CMD COUNT UART-SEND
  10 UART-WAIT        \ ignore line echo
  T 2 BLOCK B/BUF   UART-RX-CHUNK
  T 3 BLOCK B/BUF   UART-RX-CHUNK
  T 4 BLOCK B/BUF   UART-RX-CHUNK
  T 5 BLOCK B/BUF   UART-RX-CHUNK
  2 list
;

DECIMAL

TEST0
TEST2
