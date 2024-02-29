\
\ ask.f
\
.( ASK )
\
BASE @ \ save base status

NEEDS RPI0

\ uses Screen # n1 as a source script to be send and executed by RPi0
\ and collect final reply to Screen # n2 (first half only)
\ returns n as the number of bytes received.
: ASK ( u1 u2 -- n2 )
    \ prepare zero reply
    0 -ROT                              \ 0 u1 u2
    \ compute address in buffer for line #1 of screen n2.
    1 SWAP                              \ 0 u1  1 u2
    (LINE)                              \ 0 u1 a2 b2
    DROP SWAP                           \ 0 a2 u1
    L/SCR 1 DO                          \ 0 a2 u2
        I OVER                          \ 0 a2 u1  i u1
        (LINE) -TRAILING                \ 0 a2 u1 a1 b1
        \ if line is not empty
        ?DUP IF                         \ 0 a2 u1 a1 b1
            \ first send CR followed by text of line i.
            UART-SEND-CR                \ 0 a2 u1 a1 b1
            UART-SEND-TEXT              \ 0 a2 u1
            \ discard any echo
            OVER C/L                    \ 0 a2 u1 a2 b2
            UART-RX-BURST               \ 0 a2 u1 n2
            DROP                        \ 0 a2 u1
        ELSE                            \ 0 a2 u1 a1 
            2DROP                       \ 0 a2
            NIP                         \ a2  
            B/BUF C/L -                 \ a2 n
            2DUP BLANK                  \ a2 n
            UART-SEND-CR                \ a2 n
            UART-RX-BURST               \ n2 
            0 0 
            LEAVE                       \ n2 
        THEN
    LOOP
    2DROP                               \ 0 or n2
;
\
BASE !
