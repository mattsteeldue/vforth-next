\
\ UART-RX-PROTO-ASM.f
\

NEEDS PICK
NEEDS ASSEMBLER
NEEDS UART-SYS

\ _________________________________________________________
\
\ Accept from I/O  n  bytes and store them at address  a.
\ The parameter  n  should be less than 512
\ This routine is similar to UART-RX-BURST, 
\ but 0x00 doesn't ends the transmission
\
CODE UART-RX-PROTO ( a n -- )

        di
        exX
        POP     DE|                   \ n1: length counter
\       ld      H'|     D|            \ keep counter to compute final length
\       ld      L'|     E|
        Exx
        pop     hl|                   \ a: dest address

        \ save forth status
\       push    ix|
        push    de|
        push    bc|

        ldx()   de|     UART-1ST-TIMEOUT  AA,

    \ wait for a char ready until timeout expires   
    HERE                              \              a1
    \   nop                                                 \  4
        decx    de|                   \ check timeout       \  6
        ld      a'|     d|                                  \  4
        ora      e|                                         \  4
        jrf     z'|  HOLDPLACE        \ bailout      a1 a2  \  7  

        \ check for ?BREAK
        ldx     bc|     $7FFE NN,                           \ 10
        in(c)   a'|         \ pressed key ZEROes bit-0      \ 12
        ld      b'|     c|  \ so that BC is $FEFE           \  4
        in(c)   c'|         \ pressed key ZEROes bit-0      \ 12
        ora      c|         \ merge the two bit-0           \  4
        rra                 \ CF is reset if both keys are pre  ssed
        jrf    nc'|  HOLDPLACE        \           a1 a2 a3  \  7 

        \ check for byte ready from Uart
        ldx     bc|  UART-TX-PORT  NN,  \ 133Bh             \ 10
        in(c)   a'|                   \ bit 0 bc is 133Bh   \ 12
        rra                           \ non-zero when ready \  4
        jrf    nc'|  2 PICK BACK,     \ back to a1          \ 12 -- 112  

        \ accept a char to (hl). 
        inc     b'|                   \ RX port 143Bh       \  4
        in(c)   a'|                                         \ 12
        ld   (hl)'|     a|                                  \  7
        incx    hl|                                         \  6
        \ 0x00 don't end loop 
      \ ora      a|                   \ check for 0x00      \  4
      \ jrf     z'|  HOLDPLACE        \         a1 a2 a3 a4 \  7

        exX                                                 \  4
        DECX    DE|                   \ dec length counter  \  6
        LD      A'|     D|                                  \  4
        ORA      E|                   \ check for zero      \  4
        Exx                                                 \  4

        ldx()   de|    UART-2ND-TIMEOUT   AA,               \ 20
        jrf    nz'|  3 PICK BACK,     \ back to a1          \ 12
                                                        \    204 total
\   HERE DISP,    \ holdplace a4 resolved here   
    HERE DISP,    \ holdplace a3 resolved here   
    HERE DISP,    \ holdplace a2 bailout resolved
        DROP      \ a1 is then discarded         

\       exX
\       SBCHL   DE|

        \ restore forth status
        pop     bc|
        pop     de|
\       pop     ix|

\       PUSH    HL|
        ei

        next
        C;

CREATE UART-RX-PROTO-ASM
