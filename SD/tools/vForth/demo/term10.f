( UART Raspberry PI Zero raw-terminal )
\
\ This TERM0.F provides a simple terminal to talk with Raspberry PI Zero
\ via UART.
\

NEEDS LAYERS        \ Graphic Modes
NEEDS MS            \ Wait milli-seconds
NEEDS TRUV          \ True-Video 
NEEDS INVV          \ Inverse-Video
NEEDS FLIP          \ Swap hi and lo bytes of TOS
\
MARKER DONE  \ Useful to rollback dictionary memory to this point
INCLUDE LIB/UART-CONST.F
\

\ Table of actual clock speeds depending on video mode
\ These are double precision integers you can read with 2@
\ See Manual: NextReg 17 (11h) - Video Timing
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

\ Utilities
DECIMAL
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
  UART-TX-PORT  P@
  01 AND
;

: UART-RX  ( -- b | 0 )       \ accept a byte
  UART-RX-PORT  P@
;

: UART-WAIT ( b -- )     \ wait for a specific byte or Break
  BEGIN                       \ b
    UART-RX OVER =            \ b f
    ?TERMINAL OR              \ b f
  UNTIL DROP                  \
;

\ wait for a byte with timeout in ms
: UART-RX-TIMEOUT ( n -- c | 0 )
  0 SWAP                      \ 0 n
  1+ 0                        \ 0 n+1 0
  DO                          \ 0
    ?UART-BYTE-READY IF       \ 0
      UART-RX                 \ 0 b
      SWAP DROP               \   b
      LEAVE                   \   b
    THEN                     \ 0
    1 ms                      \      minimum delay
  LOOP                        \ 0
;

HEX
\ simple wait for a specific string "SUP> "
: UART-WAIT-PROMPT  ( -- )
  [CHAR] S UART-WAIT
  [CHAR] U UART-WAIT
  [CHAR] P UART-WAIT
  [CHAR] > UART-WAIT
        BL UART-WAIT
;

HEX   \ map special Symbol-Shift Keys
HERE  \ stop not step to then and or <= <> >=
E2 C, C3 C, CD C, CC C, CB C, C5 C, C5 C, 0C C, C7 C, C9 C, C8 C,
 CONSTANT TKB1

HERE  \  ~    |   \   {  }    [   ]  ^Z ^X ^C
7E C, 7C C, 5C C, 7B C, 7D C, 5B C, 5D C, 08 C, 1A C, 18 C, 03 C,
 CONSTANT TKB2

\
\ map above listed char-code.
\ should handle Caps-Lock key too.
: MAP-KEYB ( c -- c )
  >R TKB2 TKB1 [ DECIMAL ] 11 R> (MAP)
  DUP 6 = IF [ HEX ] 8 5C6A TOGGLE THEN  \ handle caps-lock
;

HEX
\ Terminal basic initialization
: TERM0-INIT   ( -- )
  LAYER12
  7 1E EMITC EMITC  \ narrow font 85 char per row.
  0 LASTK C! 0 5C6A C!
  HEX
;

: TERM0-DONE
  LAYER12
  8 1E EMITC EMITC  \ normal font 64 char per font
  DECIMAL
;

hex 8f8c constant cursor-face
variable  ESCAPE
: C-EMIT ( c -- )
  ESCAPE @ IF
    dup [CHAR] m = IF 0 ESCAPE ! THEN
        [CHAR] K = IF 0 ESCAPE ! THEN
  ELSE  DUP [ HEX ] 1B = IF 1 ESCAPE ! THEN
    DUP 08 = IF                      \ backspace
      EMITC
    ELSE DUP 0D - IF                      \ ignore CR
        DUP 0A = IF BL EMIT 8 EMITC THEN
        DUP 7F > IF INVV THEN
        7F AND DUP  EMIT TRUV       \ force ascii 7-bits
      \ dup bl < if invv dup . truv then
      THEN \ CR
      DROP
    THEN \ BACKSPACE
  THEN \ ESCAPE
;

: TERM0
  TERM0-INIT
  BEGIN
    cursor-face
    [ hex 5c3a 3e + ] literal c@ 10 and if flip then
    emitc 8 emitc
    LASTK C@ ?DUP IF
      MAP-KEYB  DUP UART-TX  0 LASTK C!
    THEN
    ?UART-BYTE-READY IF UART-RX
      C-EMIT
\     DUP 80 < 0= IF INVV THEN 7F AND  \ force ascii 7-bits
\     DUP 08 = IF emitc      ELSE      \ backspace
\     DUP 0D - IF EMIT THEN THEN TRUV  \ ignore CR
    THEN
  ?TERMINAL UNTIL TERM0-DONE
;

( UART Raspberry PI Zero - testing )

  DECIMAL 115.200 PI0-SELECT
  UART-SEND-ETX
  UART-SEND-EOT
  UART-WAIT-PROMPT

  TERM0
