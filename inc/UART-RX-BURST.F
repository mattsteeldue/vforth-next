\
\ UART-RX-BURST.f
\

NEEDS UART-SYS

\ _________________________________________________________
\
\ Accept from UART up to n1 bytes and store them at address a.
\ At 115.200 Baud, one bit duration is 8.68  microseconds
\ a 512 bytes-buffer is filled in about 4.4 ms
\ A 512 bytes burst-read takes 200 T per byte (102400 T in total)
\ plus enter-exit time that at 28 MHz is about 3.7 ms
\ so we should keep draining the buffer faster than it fills up.
\ Timeout (see DE) is set at about 100 ms
\
CODE UART-RX-BURST ( a n1 -- n2 )
HEX
    F3 C,           \ di
    D9 C,           \ exX
    D1 C,           \ POP     DE|                   \ n1: length counter
    62 C,           \ ld      H'|     D|            \ keep counter to compute final length
    6B C,           \ ld      L'|     E|
    D9 C,           \ Exx
    E1 C,           \ pop     hl|                   \ a: dest address
                    \ 
                    \ save forth status
    DD C, E5 C,     \ push    ix|
    D5 C,           \ push    de|
    C5 C,           \ push    bc|
                    \ 
    ED C, 5B C,     \ ldx()   de|     UART-1ST-TIMEOUT  AA,
    UART-1ST-TIMEOUT ,
                    \ wait for a char ready until timeout expires   
                    \ HERE                              \              a1
  \ 00 C,           \ nop                                                 \  4 
    1B C,           \ decx    de|                   \ check timeout       \  6
    7A C,           \ ld      a'|     d|                                  \  4
    B3 C,           \ ora      e|                                         \  4
    28 C, 27 C,     \ jrf     z'|  HOLDPLACE        \ bailout      a1 a2  \  7  
                    \ 
                    \ check for ?BREAK
    01 C, 7FFE ,    \ ldx     bc|     $7FFE NN,                           \ 10
    ED C, 78 C,     \ in(c)   a'|         \ pressed key ZEROes bit-0      \ 12
    41 C,           \ ld      b'|     c|  \ so that BC is $FEFE           \  4
    ED C, 48 C,     \ in(c)   c'|         \ pressed key ZEROes bit-0      \ 12
    B1 C,           \ ora      c|         \ merge the two bit-0           \  4
    1F C,           \ rra                 \ CF is reset if both keys are pressed
    30 C, 1B C,     \ jrf    nc'|  HOLDPLACE        \           a1 a2 a3  \  7
                    \ 
                    \ check for byte ready from Uart
    01 C,           \ ldx     bc|  UART-TX-PORT  NN,  \ 133Bh             \ 10
    UART-TX-PORT ,
    ED C, 78 C,     \ in(c)   a'|                   \ bit 0 bc is 133Bh   \ 12
    1F C,           \ rra                           \ non-zero when ready \  4
    30 C, E6 C,     \ jrf    nc'|  2 PICK BACK,     \ back to a1          \ 12  
                    \ 
                    \ accept a char to (hl). 0x00 ends loop immediately
    04 C,           \ inc     b'|                   \ RX port 143Bh       \  4
    ED C, 78 C,     \ in(c)   a'|                                         \ 12
    77 C,           \ ld   (hl)'|     a|                                  \  7
    23 C,           \ incx    hl|                                         \  6
    B7 C,           \ ora      a|                   \ check for 0x00      \  4
    28 C, 0B C,     \ jrf     z'|  HOLDPLACE        \         a1 a2 a3 a4 \  7
                    \ 
    D9 C,           \ exX                                                 \  4
    1B C,           \ DECX    DE|                   \ dec length counter  \  6
    7A C,           \ LD      A'|     D|                                  \  4
    B3 C,           \ ORA      E|                   \ check for zero      \  4
    D9 C,           \ Exx                                                 \  4
                    \ 
    ED C, B5 C,     \ ldx()   de|    UART-2ND-TIMEOUT   AA,               \ 20
    UART-2ND-TIMEOUT ,
    20 C, D3 C,     \ jrf    nz'|  3 PICK BACK,     \ back to a1          \ 10
                    \                                            \ total   204 
                    \ HERE DISP,    \ holdplace a4 resolved here   
                    \ HERE DISP,    \ holdplace a3 resolved here   
                    \ HERE DISP,    \ holdplace a2 bailout resolved
                    \ DROP      \ a1 is then discarded         
                    \ 
    D9 C,           \ exX
    ED C, 52 C,     \ SBCHL   DE|
                    \ 
                    \ restore forth status
    C1 C,           \ pop     bc|
    D1 C,           \ pop     de|
    DD C, E1 C,     \ pop     ix|
                    \ 
    E5 C,           \ PUSH    HL|
    FB C,           \ ei
                    \ 
    DD C, E9 C,     \ next
SMUDGE              \ C;

