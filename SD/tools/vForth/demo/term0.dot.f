\
\ term0.dot.f
\

\ This tool starts a bi-directional communication stream with the 
\ Raspberry Pi-Zero accelerator.
\
\ [BREAK] quits to Basic with L BREAK into program.
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


NEEDS ASSEMBLER
NEEDS VALUE
NEEDS TO
NEEDS PICK
NEEDS SAVE-BYTES
NEEDS UART-CONST
NEEDS PAD"

\ marker for fast forget-load
MARKER REDO

DECIMAL
42000 CONSTANT LONG-TIMEOUT
32000 CONSTANT SHORT-TIMEOUT
 3072 CONSTANT CHUNK-TO-READ


\ compile the value as per pre-scalar 14 bits
: COMP-PRE-SCALAR ( clock -- bh bl )
    #1152
    M/                          \ prescalar = sysclock / baudrate
    DUP $7F AND C,              \ first byte to be sent to port
    7 RSHIFT  $80 OR C,         \ second byte to be sent to port
;



$8f8c value CURSOR-FACE
$0000 value SYS-CLK-ARY
$0000 value TKB1
$0000 value TKB2
$0000 value ESCAPE


: RETURN
    ASSEMBLER RET
\   NOOP
;


\ _________________________________________________________
\

code ORG ASSEMBLER
        jp      0    AA,
        c;


: REL   ( a1 -- a2 )
    ['] ORG - $2000 +
\   NOOP
;


: BUFF-ADDR
     $3000
\    ['] ORG   $1000 +
;

here REL to CURSOR-FACE
$8F8C ,

here REL to ESCAPE
0 ,

\ Table pre-scalar based on speeds of video mode
HERE REL TO SYS-CLK-ARY
DECIMAL \ values are divided by 100 to better handle them
  28.0000  COMP-PRE-SCALAR   \ Base VGA timing   28 MHz
  28.5714  COMP-PRE-SCALAR   \ VGA setting 1     28.571.429 Hz
  29.4643  COMP-PRE-SCALAR   \ VGA setting 2     29.464.286 Hz
  30.0000  COMP-PRE-SCALAR   \ VGA setting 3     30 MHz
  31.0000  COMP-PRE-SCALAR   \ VGA setting 4     31 MHz
  32.0000  COMP-PRE-SCALAR   \ VGA setting 5     32 MHz
  33.0000  COMP-PRE-SCALAR   \ VGA setting 6     33 MHz
  27.0000  COMP-PRE-SCALAR   \ Digital           27 MHz


\ map special Symbol-Shift Keys
HERE REL TO TKB1
\ STOP   NOT    STEP   TO     THEN   AND    OR     delete <=     <>     >= 
  $E2 C, $C3 C, $CD C, $CC C, $CB C, $C6 C, $C5 C, $0C C, $C7 C, $C9 C, $C8 C,
HERE REL TO TKB2
\ ~      |      \      {      }      [      ]      bs     ^Z     ^X     ^C 
  $7E C, $7C C, $5C C, $7B C, $7D C, $5B C, $5D C, $08 C, $1A C, $18 C, $03 C,


\ _________________________________________________________


.( PI0-SELECT ** )
CODE PI0-SELECT ( -- )
        exx
        \ max speed
        nextreg  07 P, 03 N,

        \ select PI-ZERO UART control port
        ldx     bc|     UART-CT-PORT NN,
        ldn     a'|     $40 N,
        out(c)  a'|

        \ read reg to get video timings
        ldx     bc|     $3243B NN,
        ldn     a'|     $11 N,
        out(c)  a'|
        inc     b'|
        in(c)   l'|
        ldn     h'|     0 N,

        \ uses double integer param
        addhl   hl|
        ldx     de|     SYS-CLK-ARY NN,
        addhl   de|

        \ send 14-bits prescalar to UART receive port
        \ prescalar = sysclock / baudrate
        ldx     bc|     UART-RX-PORT NN,
        ld      a'|  (hl)|
        out(c)  a'|
        incx    hl|
        ld      a'|  (hl)|
        out(c)  a'|

        \ PI Pheripeal enable
        nextreg  $A0 P, $30 N,
        \
        exx

        RETURN

        next
        c;


\ _________________________________________________________

.( TERM0-INIT ** )
CODE TERM0-INIT   ( -- )
        \ set zero to LASTK system variable (5C08)
        ldx     hl|     LASTK NN,
        ldn  (hl)'|   0  N,
        \ unshift caps-lock
        ldx     hl|     $5C6A NN,
        ldn  (hl)'|   0  N,

        RETURN

        next
        c;


\ _________________________________________________________

\ does the same in uart wait byte
.( ?BREAK ** )
\ check for BREAK key --> then CF is reset
CODE ?BREAK ( -- f )
        EXX
        LDX     BC|     $7FFE NN,
        IN(C)   A'|
        LD      B'|     C|  \ FEFE
        IN(C)   C'|
        ORA      C|
        RRA

        RETURN     \ CF

        CCF
        SBCHL   HL|
        PUSH    HL|
        EXX
        Next
        C;


\ _________________________________________________________

.( SHOW-CURSOR ** )
\ based on FRAMES, decides which cursor face is now displayed
CODE SHOW-CURSOR ( -- )
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

        RETURN

        next
        c;


\ _________________________________________________________

.( GET-KEYB ** )
\ this relies on standard interrupt keyboard service
CODE GET-KEYB ( -- c )
        ldx     hl|     LASTK NN,
        ldn     d'|  0  N,
        ld      e'|  (hl)|
        ld      a'|     e|
        ora      a|
        jrf     z'|   HOLDPLACE
            ldn  (hl)'|  0  N,
        HERE DISP,

        RETURN      \ c is retured in A

        push    de|
        next
        c;


\ _________________________________________________________

.( MAP-KEYB ** )
CODE MAP-KEYB ( c -- c )
        exx

\ \     pop     hl|
\ \     ld      a'|     l|

        ldx     hl|     TKB1 NN,
        ldx     bc|     11   NN,
        ld      d'|     b|
        ld      e'|     c|
        cpir
        ldx     hl|     TKB2 NN,
        jrf    nz'|     HOLDPLACE
            addhl   de|
            decx    hl|
            sbchl   bc|
            ld      a'|  (hl)|
        HERE DISP,
        ld      l'|    a|
        ldn     h'|    0  N,
\ \     push    hl|
        exx

        \ handle caps-lock
        cpn    6   N,
        jrf    nz'|     HOLDPLACE
            ldx     hl|    $5C6A    NN,
            ld      a'|  (hl)|
            xorn     8  N,
            ld    (hl)|    a'|
            LDN     A'|  00 N,   \ NUL will be ignored
        HERE DISP,

        RETURN

        next
        c;


\ _________________________________________________________

\ There is no transmit buffer so program must make sure the
\ last transmission is complete before sending another byte
.( UART-TX-BYTE ** )
CODE UART-TX-BYTE  ( b -- )       \ accept a byte
        exx
\ \     pop     hl|

        ldx     bc|     UART-TX-PORT  NN,

        \ wait if transmitter is busy sending a byte
HERE
        in(c)   a'|
        andn    2   N,  \ bit is set when busy
        jrf    nz'|     BACK,
        \
        out(c)  l'|
        exx

        RETURN

        next
        C;


\ _________________________________________________________

\ Accept from I/O  up to n1 bytes and store them at a.
\ At 115.200 Bauds bit duration is 8.68  micro-seconds
\ a 512 bytes-buffer is filled in about 4.4 ms
\ The 512 bytes burst-read takes 61.952 T-states
\ plus enter-exit time that at 28 MHz is about 3.4 ms
\ so we should drain the buffer faster than it fills up.
\ Timeout (see DE) is set at about 100 ms
\
.( UART-RX-BURST ** )
CODE UART-RX-BURST ( a n1 -- n2 )

        di
\ \     POP     DE|                   \ n1: length counter
        ld      H'|     D|            \ keep counter to compute final length
        ld      L'|     E|
        Exx
\ \     pop     hl|                   \ a: dest address
        LDX     HL|     BUFF-ADDR nn,
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
\ \     PUSH    HL|
        EXDEHL
        ei

        RETURN

        next
        C;


\ _________________________________________________________

.( UART-RX-BYTE ** )
CODE UART-RX-BYTE  ( -- b | 0 )       \ accept a byte
        exx
        ldx     bc|     UART-RX-PORT  NN,
        in(c)   l'|
        ldn     h'|     0 N,
\ \     push    hl|

        LD      A'|  L|

        exx

        RETURN

        next
        C;


\ _________________________________________________________

.( ?UART-BYTE-READY ** )
CODE ?UART-BYTE-READY  ( -- f )  \ non zero when byte ready
        exx
        ldx     bc|     UART-TX-PORT  NN,
        in(c)   a'|
        andn    1       N,
        ld      l'|     a|
        ldn     h'|     0 N,
\ \     push    hl|
        exx

        RETURN

        next
        c;


\ _________________________________________________________

\ type with filter char from PI0
.( CHUNK-EMIT ** )
CODE CHUNK-EMIT ( a n -- )

\ \     pop     de|     \ n
\ \     pop     hl|     \ a
\ \     push    ix|
\ \     push    bc|

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

        RETURN

\ \     pop     bc|
\ \     pop     ix|
        next
        c;


\ _________________________________________________________

.( ACCEPT-PARAM ** )
\ must be the first call
CODE ACCEPT-PARAM   ( -- )

        \ Accepts one parameter from Basic as the filename to load
        ld      a'|     h|
        ora      l|
        jrf     z'|     HOLDPLACE \ Skip_Parameter

            ldx     de| BUFF-ADDR NN, \ Param
            ldx     bc| 0 NN,
    
            HERE \ Parameter_Loop:
                ld      a'|  (hl)|
                cpn     char : N,
                jrf     z'|  HOLDPLACE \ End_Parameter
                cpn     $0D    N,
                jrF     z'|  HOLDPLACE \ End_Parameter

                ldi

            jr    BACK, \ Parameter_Loop
            \ End_Parameter:  
            HERE DISP,
            HERE DISP,
            
            \ // append 0x00
            xora     a|
            ld(x)a  de|

            exdehl
            ldx     de|  BUFF-ADDR  NN, 
            sbchl   de|
            ldx     de|  BUFF-ADDR  NN, 
            exdehl
            CALL    ' CHUNK-EMIT REL AA,   ( a:HL n:DE -- )
    
        \ Skip_Parameter:
        HERE DISP,

        RETURN

        next
        c;

\ _________________________________________________________

.( MAIN ** )
CODE MAIN
      \ CALL    ' ACCEPT-PARAM REL  AA,     ( -- )
        CALL    ' PI0-SELECT   REL  AA,     ( -- )
        CALL    ' TERM0-INIT   REL  AA,     ( -- )

        HERE
            CALL    ' SHOW-CURSOR   REL     AA,     ( -- )
            CALL    ' GET-KEYB REL     AA,     ( -- c:A )
            ora      a|
            \ manage key when non zero
            jrf     z'|   HOLDPLACE
                \ manage ENTER key
                CALL    ' MAP-KEYB  REL    AA,     ( c -- c )
                cpn     $0D  N,
                jrf    nz'|     HOLDPLACE
                    CALL    ' UART-TX-BYTE REL AA,  ( b:A -- )
                    LDX     DE|    CHUNK-TO-READ  NN,
                    \ collect reply as fast as possible
                    CALL    ' UART-RX-BURST REL AA, ( a:HL n1:DE -- n2:DE )
                    LDX     HL|  BUFF-ADDR  NN,
                    CALL    ' CHUNK-EMIT REL AA, ( a:HL n:DE -- )
                jr   HOLDPLACE  SWAP HERE DISP, \ ELSE,
                \ manage any other key
                    CALL    ' UART-TX-BYTE REL AA,  ( b:A -- )
                HERE DISP,
            HERE DISP,
            \ check if a byte is ready from Pi0
            CALL    ' ?UART-BYTE-READY REL AA,  ( -- f:A )
            ora      a|
            jrf     z'|   HOLDPLACE
                CALL    ' UART-RX-BYTE REL AA,  ( -- b:A )
                LDX     HL|  BUFF-ADDR NN,
                LD   (HL)'|   A|
                LDX     DE|    1  NN,
                CALL    ' CHUNK-EMIT REL AA,   ( a:HL n:DE -- )
            HERE DISP,
            \ check for BREAK to quit to basic
            CALL    ' ?BREAK  REL  AA,      ( -- f:CF )
        jrf  cy'|  BACK,

        \ wait for BREAK to be released before quitting to basic.
        \ to avoid an "L BREAK into program" error
        HERE
            CALL    ' ?BREAK  REL  AA,          ( -- f:CF )
            jrf  nc'|  BACK,

        xora     a|
        
        RETURN
        next
        c;


\ _________________________________________________________


\ patch JP instruction
' MAIN REL ' ORG 1+ !


\ _________________________________________________________
\
\ UNLINK /dot/term0
  PAD" /dot/term0"
  ' Org Here over -  \  start-addres & length
  SAVE-BYTES
\
\ _________________________________________________________
