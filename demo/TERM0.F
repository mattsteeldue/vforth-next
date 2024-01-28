( UART Raspberry PI Zero raw-terminal )
\
\ This TERM0.F provides a simple terminal to talk with Raspberry PI Zero
\ via UART.
\
\ [BREAK] quits to Basic continuing basic program.
\ [TRUE VIDEO] produces EOT or ^D  (0x04) that normally produces a 
\ 'normal exit' from whatever you where in.
\ [DELETE] produces BS or ^H (0x08) and it is the normal back-space key.
\ [<=] produces ETX or ^Z (0x1A) that helps to emulate CTRL-Z key-press.
\ [<>] produces ETX or ^X (0x18) that helps to emulate CTRL-X key-press.
\ [>=] produces ETX or ^C (0x03) that helps to emulate CTRL-C key-press.
\ remaining ascii  ~ | \ [ ] { }  are produced via SYMBOL-SHIFT 
\
\ The rationale is as follows. The main loop continuosly polls the keyboard 
\ and polls PI0 UART.
\ Any key pressed is immediately transmitted, any byte read from PI0 is 
\ immediately sent to screen, which is notoriously slow.
\ [ENTER] key has a peculiar behavior and, once 0x0D is transmitted to PI0, 
\ up to 8000 bytes are "fast read" from UART and - only then - slowly sent 
\ to screen. This allows collecting long output from PI0, but only after you 
\ hit [ENTER].

\ _________________________________________________________

NEEDS ASSEMBLER
NEEDS PICK
NEEDS LAYERS
NEEDS MS     
NEEDS TRUV    
NEEDS INVV

NEEDS UART-CONST
NEEDS SYS-VIDEO-TIMING  \ reads and interprets NextREG 17 (11h) 

\
MARKER REDO  \ Useful to rollback dictionary memory to this point
\
\ _________________________________________________________


42000 CONSTANT LONG-TIMEOUT
16000 CONSTANT SHORT-TIMEOUT
 8000 CONSTANT CHUNK-TO-READ

HERE  $8F8C ,
      CONSTANT CURSOR-FACE

$E000 CONSTANT BUFF-ADDR
VARIABLE ESCAPE 0 ESCAPE !

.( .)

\ send 14-bits prescalar to UART receive port
\ prescalar = sysclock / baudrate
: UART-SET-PRESCALAR ( n -- )
    DUP
    $7F AND UART-RX-PORT P!     \ send low 7 bits of 14 bits
    7 RSHIFT                    \ presclar
    $80  OR UART-RX-PORT P!     \ send high 7 bits of 14 bits
;

\ _________________________________________________________
\
\ compute prescalar to be used with previous definition
: UART-BAUD-TO-PRESCALAR ( d -- n )
    #100 M/          \ divide BAUD by 100 to able to handle it
    SYS-VIDEO-TIMING \ get actual system clock speed / 100
    ROT M/
;

\ _________________________________________________________
\
\ usage is: 115200. UART-SET-BAUDRATE
: UART-SET-BAUDRATE ( d -- )
    UART-BAUD-TO-PRESCALAR
    UART-SET-PRESCALAR
;

\ _________________________________________________________
\
\ Select Raspberry PI Zero UART and set Baudrate d
\
.( .)
: PI0-SELECT  ( d -- )
    3 7 REG!              \ go max speed (28 MHz)
    $40 UART-CT-PORT P!   \ select PI Zero UART control port
    UART-SET-BAUDRATE     \ uses double integer param
    $30 $A0 REG!          \ PI Pheripeal enable
\   $91 $A2 REG!          \ PI I2S Audio control
;

\ _________________________________________________________
\
\ non-zero when transmitter is busy sending a byte
: ?UART-BUSY-TX ( -- f )
    UART-TX-PORT P@   \ UART TX port
    02 AND            \ bit is set when busy
;

\ _________________________________________________________
\
\ There is no transmit buffer so program must make sure the
\ last transmission is complete before sending another byte
\
: UART-TX ( b -- )
    BEGIN
        ?UART-BUSY-TX  0=  ?TERMINAL OR
    UNTIL
    UART-TX-PORT P!         \ Transmit
;
\ _________________________________________________________
\
\ There is no transmit buffer so program must make sure the
\ last transmission is complete before sending another byte
\
.( .)
CODE UART-TX-BYTE  ( b -- )       \ accept a byte
        exx
        pop     hl|

        ldx     bc|     UART-TX-PORT  NN,

        \ wait if transmitter is busy sending a byte
HERE
        in(c)   a'|
        andn    2   N,  \ bit is set when busy
        jrf    nz'|     BACK,
        \
        out(c)  l'|
        exx

\       RETURN

        next
        C;
\ _________________________________________________________
\
\ Accept from I/O  up to n1 bytes and store them at a.
\ At 115.200 Bauds bit duration is 8.68  micro-seconds
\ a 512 bytes-buffer is filled in about 4.4 ms
\ The 512 bytes burst-read takes 61.952 T-states
\ plus enter-exit time that at 28 MHz is about 3.4 ms
\ so we should drain the buffer faster than it fills up.
\ Timeout (see DE) is set at about 100 ms
\
CODE UART-RX-BURST ( a n1 -- n2 )
        exX
        di
        POP     DE|                   \ n1: length counter
        ld      H'|     D|            \ keep counter to compute final length
        ld      L'|     E|
        Exx
        pop     hl|                   \ a: dest address

        \ save forth status
        push    ix|
        push    de|
        push    bc|

\       LDX     HL|     BUFF-ADDR nn,
        ldx     de|     LONG-TIMEOUT  NN,

    HERE                              \              a1

        \ wait for a char ready until timeout expires
        decx    de|                   \ check timeout       \  6
        ld      a'|     d|                                  \  4
        ora      e|                                         \  4
        jrf     z'|  HOLDPLACE        \ bailout      a1 a2  \  7  / 12

        \ ?BREAK
        ldx     bc|     $7FFE NN,                           \ 10
        in(c)   a'|         \ pressed key ZEROes bit-0      \ 12
        ld      b'|     c|  \ so that BC is $FEFE           \  4
        in(c)   c'|         \ pressed key ZEROes bit-0      \ 12
        ora      c|         \ merge the two bit-0           \  4
        rra                 \ so CF is reset if both keys are pressed
        jrf    nc'|  HOLDPLACE        \           a1 a2 a3  \  7

        ldx     bc|  UART-TX-PORT  NN,  \ 133Bh             \ 10
        in(c)   a'|                   \ bit 0 bc is 133Bh   \ 12
        rra                           \ non-zero when ready \  4
        jrf    nc'|  2 PICK BACK,     \ back to a1          \  7

        \ accept a char to (hl). 0x00 ends loop immediately
        inc     b'|                   \ RX port 143Bh       \  4
        in(c)   a'|                                         \ 12
        ld   (hl)'|     a|                                  \  7
        incx    hl|                                         \  6
        ora      a|                   \ check for 0x00      \  4
        jrf     z'|  HOLDPLACE        \         a1 a2 a3 a4 \  7

        exX                                                 \  4
        DECX    DE|                   \ dec length counter  \  6
        LD      A'|     D|                                  \  4
        ORA      E|                   \ check for zero      \  4
        Exx                                                 \  4

        ldx     de|    SHORT-TIMEOUT   NN,                  \ 10
        jrf    nz'|  3 PICK BACK,     \ back to a1          \ 10
                                                        \    185
    HERE DISP,    \ holdplace a4 resolved here   
    HERE DISP,    \ holdplace a3 resolved here   
    HERE DISP,    \ holdplace a2 bailout resolved
        DROP      \ a1 is then discarded         

        exX
        SBCHL   DE|

        \ save forth status
        pop     bc|
        pop     de|
        pop     ix|

        PUSH    HL|
\       EXDEHL
        ei

\       RETURN

        next
        C;
\
\ _________________________________________________________

\ type with filter char from PI0
.( .)
CODE CHUNK-EMIT ( a n -- )

        exX
        pop     de|     \ n
        pop     hl|     \ a
        Exx
        push    ix|
        push    de|
        push    bc|
        exX

        \ BEGIN,
        HERE
            ld      a'|    e|
            ora      d|

        \ WHILE,
        jrf     z'|     HOLDPLACE

            lda()   ESCAPE  AA,
            ora      a|
            jrf     z'|     HOLDPLACE
                \ during escape sequence...
                ldn     a'|   char m  N,
                cpa   (hl)|
                jrf    nz'|     HOLDPLACE
                    xora     a|
                    ld()a   ESCAPE  AA,
                HERE DISP,
                ldn     a'|   char K  N,
                cpa   (hl)|
                jrf    nz'|     HOLDPLACE
                    xora     a|
                    ld()a   ESCAPE  AA,
                HERE DISP,
            jr   HOLDPLACE  SWAP HERE DISP, \ ELSE,
                ld      a'|   (hl)|
                cpn     $0A  N,                  \ LF is ignored
                jrf     z'|     HOLDPLACE
                    cpn     $0D  N,              \ CR is interpreted
                    jrf    nz'|     HOLDPLACE
                        ldn     a'|   $20  N,    \ clear cursor
                        rst     10|
                        ldn     a'|   $0D  N,    \ clear cursor
                        rst     10|
                        ld      a'|   (hl)|
                    HERE DISP,
                    cpn     $08  N,          \ CR is interpreted
                    jrf    nz'|     HOLDPLACE
                        ldn     a'|   $20  N,    \ clear cursor
                        rst     10|
                        ldn     a'|   $08  N,    \ clear cursor
                        rst     10|
                        ldn     a'|   $08  N,    \ clear cursor
                        rst     10|
                        ld      a'|   (hl)|
                    HERE DISP,
                    cpn     $1B  N,          \ escape
                    jrf     z'|     HOLDPLACE
                        andn    $7F  N,     \ not-escape
                        cpn     $20  N,          \ BL
                        jrf    cy'|     HOLDPLACE   \ printable
                            rst     10|
                        HERE DISP,
                    jr   HOLDPLACE  SWAP HERE DISP, \ ELSE,
                        ldn     a'|  1  N,      \ escape-on
                        ld()a   ESCAPE  AA,
                    HERE DISP,
                HERE DISP, \ THEN,
            HERE DISP, \ THEN,
            decx    de|
            incx    hl|

        \ REPEAT,
        jr HOLDPLACE ROT DISP, HERE DISP,

\       RETURN
        pop     bc|
        pop     de|
        pop     ix|
        next
        c;
\
\ _________________________________________________________
\
.( .)
\ Utilities
\
: UART-SEND-EOT ( -- )      \ End Of Transmission ^D
    04 UART-TX
;
\
: UART-SEND-ETX ( -- )      \ End of TeXt ^C
    03 UART-TX
;

: ?UART-BYTE-READY  ( -- f )  \ non zero when byte ready
    UART-TX-PORT  P@ 
    01 AND
;

: UART-RX-BYTE  ( -- b | 0 )     \ accept a byte
    UART-RX-PORT  P@
;

: UART-WAIT ( b -- )        \ wait for a specific byte or Break
    BEGIN                   \ b
        UART-RX-BYTE OVER = \ b f
        ?TERMINAL OR        \ b f
    UNTIL DROP              \
;

\ wait for a byte with timeout in ms
: UART-RX-TIMEOUT ( n -- c | 0 )
  0 SWAP                      \ 0 n
  1+ 0                        \ 0 n+1 0
  DO                          \ 0
    ?UART-BYTE-READY IF       \ 0
      UART-RX-BYTE            \ 0 b
      SWAP DROP               \   b
      LEAVE                   \   b
    THEN                     \ 0
    1 ms                      \      minimum delay
  LOOP                        \ 0
;

\ simple wait for a specific string "SUP> "
: UART-WAIT-PROMPT  ( -- )
  [CHAR] S UART-WAIT
  [CHAR] U UART-WAIT
  [CHAR] P UART-WAIT
  [CHAR] > UART-WAIT
        BL UART-WAIT
;

\ _________________________________________________________
\
\ map special Symbol-Shift Keys
HERE  \ stop not step to then and or
\ STOP   NOT    STEP   TO     THEN   AND    OR     delete <=     <>     >= 
  $E2 C, $C3 C, $CD C, $CC C, $CB C, $C6 C, $C5 C, $0C C, $C7 C, $C9 C, $C8 C,
 CONSTANT TKB1

HERE  \  ~    |   \   {  }    [   ]
\ ~      |      \      {      }      [      ]      bs     ^Z     ^X     ^C 
  $7E C, $7C C, $5C C, $7B C, $7D C, $5B C, $5D C, $08 C, $1A C, $18 C, $03 C,
 CONSTANT TKB2

\ _________________________________________________________

\ map above listed char-code.
\ should handle Caps-Lock key too.
: MAP-KEYB ( c -- c )
    >R TKB2 TKB1 8 R> (MAP)
    DUP 6 = IF 8 $5C6A TOGGLE THEN  \ handle caps-lock
;

\ _________________________________________________________

\ based on FRAMES, decides which cursor face is now displayed
.( .)
CODE SHOW-CURSOR ( -- )

        PUSH    BC|
        PUSH    DE|
        PUSH    IX|

        ldx     de|     CURSOR-FACE  NN,
        ldx     hl|     $5C78   NN,  \ FRAMES
        ldn     a'|   $10 N,
        anda  (hl)|
        jrf     z'|   HOLDPLACE
            incx    de|
        HERE DISP,
        lda(x)  de|
        rst     10|
        ldn     a'|    8   N,
        rst     10|

        POP     IX|
        POP     DE|
        POP     BC|

        next
        c;

\ _________________________________________________________

\ this relies on standard interrupt keyboard service
CODE GET-KEYB ( -- c )
        exx
        ldx     hl|     LASTK NN,
        ldn     d'|  0  N,
        ld      e'|  (hl)|
        ld      a'|     e|
        ora      a|
        jrf     z'|   HOLDPLACE
            ldn  (hl)'|  0  N,
        HERE DISP,
        push    de|
        exx
        next
        c;

\ _________________________________________________________
\
\ Terminal basic initialization 
.( .)
: TERM0-INIT   ( -- )
    0 LASTK C! 0 $5C6A C! $0D UART-TX
    LAYER12
    6 $1E EMITC EMITC  \ narrow font 85 char per row.
    HEX
;

\ _________________________________________________________
\
: TERM0-DONE
    8 $1E EMITC EMITC  \ normal font 64 char per font
    DECIMAL
;
\ _________________________________________________________
\
: TERM
    BEGIN
        SHOW-CURSOR 
        GET-KEYB
        ?DUP IF
            MAP-KEYB 
            DUP $0D =  
            IF
                UART-TX-BYTE 1 MMU7! 
                BUFF-ADDR CHUNK-TO-READ  UART-RX-BURST 
                BUFF-ADDR SWAP CHUNK-EMIT 
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
; 

\ _________________________________________________________
\
DECIMAL
: TERM0
    115.200 PI0-SELECT
    UART-SEND-ETX
    UART-SEND-EOT
    UART-WAIT-PROMPT
    TERM0-INIT
    TERM
    TERM0-DONE
;
