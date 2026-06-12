\
\ UART-RX-BURST-ASM.f
\

NEEDS PICK
NEEDS ASSEMBLER
NEEDS UART-SYS

\ _________________________________________________________
\
\ Accept from I/O up to  n1  bytes and store them at address  a.
\ This definitions returns  n2  as the actual number of bytes received.
\ At 115.200 Bauds bit duration is 8.68  microseconds, then
\ a 512 bytes-buffer would fill in about 4.4 ms.
\ A 512 bytes burst-read takes 127 T per byte (total 65024 T) 145:74240,
\ plus enter-exit time that at 28 MHz is ABOUT 2.7 ms
\ so we keep draining the buffer faster than it fills up.
\ Byte reading is slowed down to wait for slow transmissions
\ to 20 microseconds of granularity checks.
\ Timeout for the first byte is 200 ms : DE=10000
\ Timeout for the subsequent bytes 20 ms ==  1000.
\
CODE UART-RX-BURST ( a n1 -- n2 )

        $D9 C,                        \ exx

        $D1 C,                        \ n1: length counter
        $62 C,                        \ keep counter to compute final length
        $6B C,                        \ ld l, e
        $D9 C,                        \ exx
        $E1 C,                        \ a: dest address

        \ save forth status
\       push    ix|
        $D5 C,                        \ push de
        $C5 C,                        \ push bc

        ldx() de| uart-1st-timeout aa,  \ WARN: not converted
        $F3 C,                        \ di
        
        \ jump to  a4  to skip first delay and first break check
        jr      HOLDPLACE             \ a0
    \ wait for next ready char until timeout expires   
    HERE \ a1                         \ a0 a1

        $3E C,  $02 C,                \ 7
        $D3 C,  $FE C,                \ 11

        \ unit delay 
        $06 C,  $20 C,                \ 7
        HERE                                    \ 13*33-5=   416
            djnz    BACK,                       \ 13 or 5
    
        $3E C,  $04 C,                \ 7
        $D3 C,  $FE C,                \ 11

        $1B C,                        \ check timeout       \  6
        $7A C,                        \ 4
        $B3 C,                        \ 4
        jrf     z'|  HOLDPLACE        \ a0 a1 a2            \  7  

        \ check for ?BREAK
        $01 C,  $FE C,  $7F C,        \ 10
        $ED C,  $78 C,                \ pressed key ZEROes bit-0      \ 12
        $41 C,                        \ so that BC is $FEFE           \  4
        $ED C,  $48 C,                \ pressed key ZEROes bit-0      \ 12
        $B1 C,                        \ merge the two bit-0           \  4
        $1F C,                        \ CF is reset if both keys are pre  ssed
        jrf    nc'|  HOLDPLACE        \ a0 a1 a2 a3         \  7  
\ -- entry point without first delays
        3 PICK HERE DISP,             
        HERE \ a4                     \ a0 a1 a2 a3 a4
        \ check for byte ready from Uart                         
        ldx bc| uart-tx-port nn,  \ WARN: not converted -- 133Bh             \ 10
        $ED C,  $78 C,                \ bit 0 bc is 133Bh   \ 12
        $1F C,                        \ non-zero when ready \  4
        jrf    nc'|  3 PICK BACK,     \ back to a1          \  7  --> 562   
                                                                 
        $3E C,  $06 C,                \ 7
        $D3 C,  $FE C,                \ 11
                                                                 
        \ accept a char to (hl)                                  
        $04 C,                        \ RX port 143Bh       \  4
        $ED C,  $78 C,                \ 12
        $77 C,                        \ 7
        $23 C,                        \ 6
                                                                 
        \ 0x00 ends loop immediately                             
        $B7 C,                        \ check for 0x00      \  4
        jrf     z'|  HOLDPLACE        \ a0 a1 a2 a3 a4 a5   \  7 
                                                                 
        $D9 C,                        \ 4
        $1B C,                        \ dec length counter  \  6
        $7A C,                        \ 4
        $B3 C,                        \ check for zero      \  4
        $D9 C,                        \ 4
                                                                 
        ldx() de| uart-2nd-timeout aa,  \ WARN: not converted -- 20
        jrf    nz'|  1 PICK BACK,     \ back to a4          \ 12  --> 127 (145)
                                                        \   1399 total
    HERE DISP,    \ holdplace a5 resolved here   
         drop  \ WARN: not converted -- discard   a4 already used just above
    HERE DISP,    \ holdplace a3 resolved here   
    HERE DISP,    \ holdplace a2 bailout resolved
         drop  \ WARN: not converted -- discard   a1 used checking for a byte available
\        DROP     \ discard   a0 used to skip first delay

        $3E C,  $01 C,                \ ld a, 1
        $D3 C,  $FE C,                \ out ($fe), a

        $FB C,                        \ ei
        $D9 C,                        \ exx
        $ED C,  $52 C,                \ sbc hl, de

        \ restore forth status
        $C1 C,                        \ pop bc
        $D1 C,                        \ pop de
\       pop     ix|

        $E5 C,                        \ push hl

        $DD C,  $E9 C,                \ jp (ix)
        SMUDGE

CREATE UART-RX-BURST-ASM
