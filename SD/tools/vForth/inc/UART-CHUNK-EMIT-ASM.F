\
\ UART-CHUNK-EMIT-ASM.f
\

NEEDS PICK
NEEDS ASSEMBLER
NEEDS UART-SYS

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

            lda()   UART-ESCAPE-STATUS  AA,
            ora      a|
            jrf     z'|     HOLDPLACE
                \ during escape sequence...
                ldn     a'|   char m  N,
                cpa   (hl)|
                jrf    nz'|     HOLDPLACE
                    xora     a|
                    ld()a   UART-ESCAPE-STATUS  AA,
                HERE DISP,
                ldn     a'|   char K  N,
                cpa   (hl)|
                jrf    nz'|     HOLDPLACE
                    xora     a|
                    ld()a   UART-ESCAPE-STATUS  AA,
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
                        ld()a   UART-ESCAPE-STATUS  AA,
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

CREATE UART-CHUNK-EMIT-ASM
