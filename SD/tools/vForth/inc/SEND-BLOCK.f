\
\ SEND-BLOCK.f
\
.( SEND-BLOCK )

\ send to RPi0 the BLOCK appending to filespec

NEEDS RPi0

create txt-echo ," echo "  

\ Send a string of text to RPi0 escaping >
: UART-send-text> ( a n -- ) 
    BOUNDS
    ?DO
        I C@ 
        DUP [CHAR] > = 
        IF \ escape >
            [CHAR] \ 
            UART-TX-BYTE
        THEN
        UART-TX-BYTE      \ send each character
    LOOP
;

\
: SEND-BLOCK ( n -- "filespec" )
    BL WORD COUNT           \ n  a1 n1
    ROT BLOCK               \ a1 n1 a0
    b/buf bounds            \ a1 n1 a0 a0+k
    \ for each row 
    do                      \ a1 n1 
        \ send echo and space    
        txt-echo count UART-TX-BYTE 
        \ send line content escaping >
        i c/l uart-send-text
        \ send a final redirection >>
        [CHAR] > DUP UART-TX-BYTE UART-TX-BYTE
        \ send filename
        2dup  uart-send-text
    c/l +loop
    2drop
;

