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

        exX

        pop     DE|                   \ n1: length counter
        ld      H'|     D|            \ keep counter to compute final length
        ld      L'|     E|
        Exx
        pop     hl|                   \ a: dest address

        \ save forth status
\       push    ix|
        push    de|
        push    bc|

        ldx()   de|     UART-1ST-TIMEOUT  AA,
        di
        
        \ jump to  a4  to skip first delay and first break check
        jr      HOLDPLACE             \ a0
    \ wait for next ready char until timeout expires   
    HERE \ a1                         \ a0 a1

        ldn     a'|  2  N,                                  \     7
        outa   $FE   P,                                     \    11

        \ unit delay 
        ldn     B'|  #32  N,                                \  7 
        HERE                                    \ 13*33-5=   416
            djnz    BACK,                       \ 13 or 5
    
        ldn     a'|  4  N,                                  \     7
        outa   $FE   P,                                     \    11

        decx    de|                   \ check timeout       \  6
        ld      a'|     d|                                  \  4
        ora      e|                                         \  4
        jrf     z'|  HOLDPLACE        \ a0 a1 a2            \  7  

        \ check for ?BREAK
        ldx     bc|     $7FFE NN,                           \ 10
        in(c)   a'|         \ pressed key ZEROes bit-0      \ 12
        ld      b'|     c|  \ so that BC is $FEFE           \  4
        in(c)   c'|         \ pressed key ZEROes bit-0      \ 12
        ora      c|         \ merge the two bit-0           \  4
        rra                 \ CF is reset if both keys are pre  ssed
        jrf    nc'|  HOLDPLACE        \ a0 a1 a2 a3         \  7  
\ -- entry point without first delays
        3 PICK HERE DISP,             
        HERE \ a4                     \ a0 a1 a2 a3 a4
        \ check for byte ready from Uart                         
        ldx     bc|  UART-TX-PORT  NN,  \ 133Bh             \ 10  
        in(c)   a'|                   \ bit 0 bc is 133Bh   \ 12 
        rra                           \ non-zero when ready \  4 
        jrf    nc'|  3 PICK BACK,     \ back to a1          \  7  --> 562   
                                                                 
        ldn     a'|  6  N,                                  \     7 
        outa   $FE   P,                                     \    11 
                                                                 
        \ accept a char to (hl)                                  
        inc     b'|                   \ RX port 143Bh       \  4 
        in(c)   a'|                                         \ 12 
        ld   (hl)'|     a|                                  \  7 
        incx    hl|                                         \  6 
                                                                 
        \ 0x00 ends loop immediately                             
        ora      a|                   \ check for 0x00      \  4 
        jrf     z'|  HOLDPLACE        \ a0 a1 a2 a3 a4 a5   \  7 
                                                                 
        exX                                                 \  4 
        DECX    DE|                   \ dec length counter  \  6 
        LD      A'|     D|                                  \  4 
        ORA      E|                   \ check for zero      \  4 
        Exx                                                 \  4 
                                                                 
        ldx()   de|    UART-2ND-TIMEOUT   AA,               \ 20 
        jrf    nz'|  1 PICK BACK,     \ back to a4          \ 12  --> 127 (145)
                                                        \   1399 total
    HERE DISP,    \ holdplace a5 resolved here   
         DROP     \ discard   a4 already used just above
    HERE DISP,    \ holdplace a3 resolved here   
    HERE DISP,    \ holdplace a2 bailout resolved
         DROP     \ discard   a1 used checking for a byte available
\        DROP     \ discard   a0 used to skip first delay

        ldn     a'|  1  N,
        outa   $FE   P,

        ei
        exX
        SBCHL   DE|

        \ restore forth status
        pop     bc|
        pop     de|
\       pop     ix|

        PUSH    HL|

        next
        C;

CREATE UART-RX-BURST-ASM
