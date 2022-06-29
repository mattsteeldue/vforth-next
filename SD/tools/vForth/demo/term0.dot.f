\
\ term0.dot.f
\

NEEDS ASSEMBLER
NEEDS VALUE
NEEDS TO
NEEDS PICK
NEEDS SAVE-BYTES
NEEDS UART-CONST

MARKER REDO

DECIMAL
42000 CONSTANT LONG-TIMEOUT
32000 CONSTANT SHORT-TIMEOUT
 3072 CONSTANT CHUNK-TO-READ


\ compile the value as per pre-scalar 14 bits
: COMP-PRE-SCALAR ( clock -- bh bl )
    [ DECIMAL ] 1152
    M/                          \ prescalar = sysclock / baudrate
    DUP [ HEX ] 7F AND C,       \ first byte to be sent to port
    7 RSHIFT  [ HEX ] 80 OR C,  \ second byte to be sent to port
;


HEX
8f8c value CURSOR-FACE
0000 value SYS-CLK-ARY
0000 value TKB1
0000 value TKB2
0000 value ESCAPE


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
    ['] ORG - [ hex ] 2000 +
\   NOOP
;


: BUFF-ADDR
     [ HEX ] 3000
\    ['] ORG   [ hex ] 1000 +
;

here REL to CURSOR-FACE
hex 8F8C ,

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


HEX   \ map special Symbol-Shift Keys
HERE REL TO TKB1
\ stop not step to then and or
E2 C, C3 C, CD C, CC C, CB C, C5 C, C5 C, 0C C, C7 C, C9 C, C8 C,

HERE REL TO TKB2
\  ~    |   \   {  }    [   ]
7E C, 7C C, 5C C, 7B C, 7D C, 5B C, 5D C, 08 C, 1A C, 18 C, 03 C,


\ _________________________________________________________

.( PI0-SELECT ** )
CODE PI0-SELECT ( -- )
        exx
        \ max speed
        nextreg  07 P, 03 N,

        \ select PI-ZERO UART control port
        ldx     bc|     UART-CT-PORT NN,
        ldn     a'|     hex 40 N,
        out(c)  a'|

        \ read reg to get video timings
        ldx     bc|     hex 243B NN,
        ldn     a'|     hex 11 N,
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
        nextreg  hex A0 P, 30 N,
        \
        exx

        RETURN

        next
        c;


\ _________________________________________________________

.( TERM0-INIT ** )
CODE TERM0-INIT   ( -- )
        ldx     hl|     LASTK NN,
        ldn  (hl)'|   0  N,
        ldx     hl|     HEX 5C6A NN,
        ldn  (hl)'|   0  N,

        RETURN

        next
        c;


\ _________________________________________________________

\ does the same in uart wait byte
.( ?BREAK ** )
CODE ?BREAK ( -- f )
        EXX
        LDX     BC|     HEX 7FFE NN,
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

.( CURSOR ** )
CODE CURSOR ( -- )
        ldx     de|     CURSOR-FACE  NN,
        ldx     hl|     hex 5C78   NN,  \ FRAMES
        ldn     a'|   HEX 10 N,
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

.( KEYB ** )
CODE KEYB ( -- c )
        ldx     hl|     LASTK NN,
        ldn     d'|  0  N,
        ld      e'|  (hl)|
        ld      a'|     e|
        ora      a|
        jrf     z'|   HOLDPLACE
            ldn  (hl)'|  0  N,
        HERE DISP,

        RETURN

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
        ldx     bc|     DECIMAL 11   NN,
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
            ldx     hl|    HEX 5C6A    NN,
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

\ Accept from I/O  up to n bytes and store them at a.
\ At 115.200 Bauds bit duration is 8.68  micro-seconds
\ a 512 bytes-buffer is filled in about 4.4 ms
\ The 512 bytes burst-read takes 61.952 T-states
\ plus enter-exit time that at 28 MHz is about 3.4 ms
\ so we drain the buffer faster than it fills up.
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

        ldx     bc|     hex 7FFE NN,                        \ 10
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
    HERE DISP,    \ a4 resolved here
    HERE DISP,    \ a3 resolved here
    HERE DISP,    \ a2 bailout resolved

        DROP      \ a1 discarded

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
                cpn     HEX 0A  N,              \ LF is ignored
                jrf     z'|     HOLDPLACE
                    cpn     HEX 0D  N,          \ CR is interpreted
                    jrf    nz'|     HOLDPLACE
                        ldn     a'|   HEX 20  N,    \ clear cursor
                        rst     10|
                        ldn     a'|   HEX 0D  N,    \ clear cursor
                        rst     10|
                        ld      a'|   (hl)|
                    HERE DISP,
                    cpn     HEX 08  N,          \ CR is interpreted
                    jrf    nz'|     HOLDPLACE
                        ldn     a'|   HEX 20  N,    \ clear cursor
                        rst     10|
                        ldn     a'|   HEX 08  N,    \ clear cursor
                        rst     10|
                        ldn     a'|   HEX 08  N,    \ clear cursor
                        rst     10|
                        ld      a'|   (hl)|
                    HERE DISP,
                    cpn     HEX 1B  N,          \ escape
                    jrf     z'|     HOLDPLACE
                        andn    hex  7F  N,     \ not-escape
                        cpn     HEX 20  N,          \ BL
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

HEX
.( MAIN ** )
CODE MAIN
        CALL    ' PI0-SELECT  REL  AA,     ( -- )
        CALL    ' TERM0-INIT  REL  AA,     ( -- )
        HERE
            CALL    ' CURSOR   REL     AA,     ( -- )
            CALL    ' KEYB     REL     AA,     ( -- c:A )
            ora      a|
            jrf     z'|   HOLDPLACE
                CALL    ' MAP-KEYB  REL    AA,     ( c -- c )
                cpn     HEX 0D  N,
                jrf    nz'|     HOLDPLACE
                    CALL    ' UART-TX-BYTE REL AA,  ( b:A -- )
                    LDX     DE|    CHUNK-TO-READ  NN,
                    CALL    ' UART-RX-BURST REL AA, ( a:HL n1:DE -- n2:DE )
                    LDX     HL|  BUFF-ADDR  NN,
                    CALL    ' CHUNK-EMIT REL AA, ( a:HL n:DE -- )
                jr   HOLDPLACE  SWAP HERE DISP, \ ELSE,
                    CALL    ' UART-TX-BYTE REL AA,  ( b:A -- )
                HERE DISP,
            HERE DISP,
            CALL    ' ?UART-BYTE-READY REL AA,  ( -- f:A )
            ora      a|
            jrf     z'|   HOLDPLACE
                CALL    ' UART-RX-BYTE REL AA,  ( -- b:A )
                LDX     HL|  BUFF-ADDR NN,
                LD   (HL)'|   A|
                LDX     DE|    1  NN,
                CALL    ' CHUNK-EMIT REL AA,   ( a:HL n:DE -- )
            HERE DISP,
            CALL    ' ?BREAK  REL  AA,      ( -- f:CF )
        jrf  cy'|  BACK,
        RETURN
        next
        c;


\ _________________________________________________________


\ patch JP instruction
' MAIN REL ' ORG 1+ !


\ _________________________________________________________
\
  filename" term0"
  ' Org Here over -  \  start-addres & length
  save-bytes
\
\ _________________________________________________________

DECIMAL


