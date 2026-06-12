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

        $D9 C,                        \ exx
        $D1 C,                        \ n
        $E1 C,                        \ a
        $D9 C,                        \ exx
        $DD C,  $E5 C,                \ push ix
        $D5 C,                        \ push de
        $C5 C,                        \ push bc
        $D9 C,                        \ exx

        \ BEGIN,
        HERE
            $7B C,                    \ ld a, e
            $B2 C,                    \ or d

        \ WHILE,
        jrf     z'|     HOLDPLACE

            lda() uart-escape-status aa,  \ WARN: not converted
            $B7 C,                    \ or a
            jrf     z'|     HOLDPLACE
                \ during escape sequence...
                ldn a'| char m n,  \ WARN: not converted
                $BE C,                \ cp (hl)
                jrf    nz'|     HOLDPLACE
                    $AF C,            \ xor a
                    ld()a uart-escape-status aa,  \ WARN: not converted
                HERE DISP,
                ldn a'| char k n,  \ WARN: not converted
                $BE C,                \ cp (hl)
                jrf    nz'|     HOLDPLACE
                    $AF C,            \ xor a
                    ld()a uart-escape-status aa,  \ WARN: not converted
                HERE DISP,
            jr   HOLDPLACE  SWAP HERE DISP, \ ELSE,
                $7E C,                \ ld a, (hl)
                $FE C,  $0A C,        \ LF is ignored
                jrf     z'|     HOLDPLACE
                    $FE C,  $0D C,    \ CR is interpreted
                    jrf    nz'|     HOLDPLACE
                        $3E C,  $20 C,  \ clear cursor
                        $D7 C,        \ rst 10
                        $3E C,  $0D C,  \ clear cursor
                        $D7 C,        \ rst 10
                        $7E C,        \ ld a, (hl)
                    HERE DISP,
                    $FE C,  $08 C,    \ CR is interpreted
                    jrf    nz'|     HOLDPLACE
                        $3E C,  $20 C,  \ clear cursor
                        $D7 C,        \ rst 10
                        $3E C,  $08 C,  \ clear cursor
                        $D7 C,        \ rst 10
                        $3E C,  $08 C,  \ clear cursor
                        $D7 C,        \ rst 10
                        $7E C,        \ ld a, (hl)
                    HERE DISP,
                    $FE C,  $1B C,    \ escape
                    jrf     z'|     HOLDPLACE
                        $E6 C,  $7F C,  \ not-escape
                        $FE C,  $20 C,  \ BL
                        jrf    cy'|     HOLDPLACE   \ printable
                            $D7 C,    \ rst 10
                        HERE DISP,
                    jr   HOLDPLACE  SWAP HERE DISP, \ ELSE,
                        $3E C,  $01 C,  \ escape-on
                        ld()a uart-escape-status aa,  \ WARN: not converted
                    HERE DISP,
                HERE DISP, \ THEN,
            HERE DISP, \ THEN,
            $1B C,                    \ decx de
            $23 C,                    \ incx hl

        \ REPEAT,
        jr HOLDPLACE ROT DISP, HERE DISP,

\       RETURN
        $C1 C,                        \ pop bc
        $D1 C,                        \ pop de
        $DD C,  $E1 C,                \ pop ix
        $DD C,  $E9 C,                \ jp (ix)
        SMUDGE

CREATE UART-CHUNK-EMIT-ASM
