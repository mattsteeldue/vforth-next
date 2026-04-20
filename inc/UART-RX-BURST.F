\
\ UART-RX-BURST.f
\

NEEDS UART-SYS

\ _________________________________________________________
\
\ Accept from I/O up to  n1  bytes and store them at address  a.
\ This definitions returns  n2  as the actual number of bytes received.
\ At 115.200 Bauds bit duration is 8.68  microseconds, then
\ a 512 bytes-buffer would fill in about 4.4 ms.
\ A 512 bytes burst-read takes 127 T per byte (total 65024 T),
\ plus enter-exit time that at 28 MHz is ABOUT 2.4 ms
\ so we keep draining the buffer faster than it fills up.
\ Byte reading is slowed down to wait for slow transmissions
\ to 20 microseconds of granularity checks.
\ Timeout for the first byte is 200 ms : DE=10000
\ Timeout for the subsequent bytes 20 ms ==  1000.
\
CODE UART-RX-BURST ( a n1 -- n2 )
HEX
    D9 C,           \ exX

    D1 C,           \ POP     DE|                   \ n1: length counter
    62 C,           \ ld      H'|     D|            \ keep counter to compute final length
    6B C,           \ ld      L'|     E|
    D9 C,           \ Exx
    E1 C,           \ pop     hl|                   \ a: dest address
                    \ 
                    \ save forth status
\   DD C, E5 C,     \ push    ix|
    D5 C,           \ push    de|
    C5 C,           \ push    bc|
                    \ 
    ED C, 5B C,     \ ldx()   de|     UART-1ST-TIMEOUT  AA,
     UART-1ST-TIMEOUT ,
    F3 C,           \ di
                    \ jump to a4 to skip first delay and first break check
    18 C, 1D C,     \ jr      HOLDPLACE             \ a0

                    \ wait for next ready char until timeout expires   
                    \ HERE                          \ a0 a1
    3E C, 02 C,     \ ldn     A'|   2 N,  
    D3 C, FE C,     \ outa    $FE P,

    06 C, 20 C,     \ ldn     B'|   #32 N,
    10 C, FE C,     \ djnz    BACK,

    3E C, 04 C,     \ ldn     A'|   4 N,  
    D3 C, FE C,     \ outa    $FE P,

    1B C,           \ decx    de|                   \ check timeout       \  6
    7A C,           \ ld      a'|     d|                                  \  4
    B3 C,           \ ora      e|                                         \  4
    28 C, 2B C,     \ jrf     z'|  HOLDPLACE        \ bailout      a1 a2  \  7  
                    \ 
                    \ check for ?BREAK
    01 C, 7FFE ,    \ ldx     bc|     $7FFE NN,                           \ 10
    ED C, 78 C,     \ in(c)   a'|         \ pressed key ZEROes bit-0      \ 12
    41 C,           \ ld      b'|     c|  \ so that BC is $FEFE           \  4
    ED C, 48 C,     \ in(c)   c'|         \ pressed key ZEROes bit-0      \ 12
    B1 C,           \ ora      c|         \ merge the two bit-0           \  4
    1F C,           \ rra                 \ CF is reset if both keys are pressed
    30 C, 1F C,     \ jrf    nc'|  HOLDPLACE        \           a1 a2 a3  \  7
                    \ 
                    \ check for byte ready from Uart
    01 C,           \ ldx     bc|  UART-TX-PORT  NN,  \ 133Bh             \ 10
     UART-TX-PORT ,
    ED C, 78 C,     \ in(c)   a'|                   \ bit 0 bc is 133Bh   \ 12
    1F C,           \ rra                           \ non-zero when ready \  4
    30 C, DB C,     \ jrf    nc'|  2 PICK BACK,     \ back to a1          \ 12  
                    \ 
    3E C, 06 C,     \ ldn     A'|   6 N,                                  \  7
    D3 C, FE C,     \ outa    $FE P,                                      \ 11

                    \ accept a char to (hl). 
    04 C,           \ inc     b'|                   \ RX port 143Bh       \  4
    ED C, 78 C,     \ in(c)   a'|                                         \ 12
    77 C,           \ ld   (hl)'|     a|                                  \  7
    23 C,           \ incx    hl|                                         \  6
                    \ 0x00 ends loop immediately
    B7 C,           \ ora      a|                   \ check for 0x00      \  4
    28 C, 0B C,     \ jrf     z'|  HOLDPLACE        \         a1 a2 a3 a4 \  7
                    \ 
    D9 C,           \ exX                                                 \  4
    1B C,           \ DECX    DE|                   \ dec length counter  \  6
    7A C,           \ LD      A'|     D|                                  \  4
    B3 C,           \ ORA      E|                   \ check for zero      \  4
    D9 C,           \ Exx                                                 \  4
                    \ 
    ED C, 5B C,     \ ldx()   de|    UART-2ND-TIMEOUT   AA,               \ 20
     UART-2ND-TIMEOUT ,
    20 C, E1 C,     \ jrf    nz'|  1 PICK BACK,     \ back to a4          \ 10
                    \                                            \ total   218 
                    \   HERE DISP,    \ holdplace a5 resolved here   
                    \        DROP     \ discard   a4 already used just above
                    \   HERE DISP,    \ holdplace a3 resolved here   
                    \   HERE DISP,    \ holdplace a2 bailout resolved
                    \        DROP     \ discard   a1 used checking for a byte available
                    \        DROP     \ discard   a0 used to skip first delay
                    \ 
    3E C, 01 C,     \ ldn     A'|   1 N,  
    D3 C, FE C,     \ outa    $FE P,

    FB C,           \ ei
    D9 C,           \ exX
    ED C, 52 C,     \ SBCHL   DE|
                    \ 
                    \ restore forth status
    C1 C,           \ pop     bc|
    D1 C,           \ pop     de|
\   DD C, E1 C,     \ pop     ix|
                    \ 
    E5 C,           \ PUSH    HL|
                    \ 
    DD C, E9 C,     \ next

FORTH  
SMUDGE              \ C;
