\
\ RPi0-SEND-BLOCK.f
\
.( RPi0-SEND-BLOCK )

\ send to RPi0 the BLOCK appending to filespec

NEEDS RPi0

MARKER TASK

\ constant string for Unix command echo
CREATE RPi0-TXT-ECHO ," echo "  

\ char to be sent escaped
CREATE RPi0-CHAR-TO-ESCAPE 
    ," #s\<|>"

CREATE RPi0-FLAG-TO-ESCAPE 
    RPi0-CHAR-TO-ESCAPE C@ ALLOT

\ this way we map these chars to false-flag
    RPi0-FLAG-TO-ESCAPE  C@ ERASE


\ Send a string of text to RPi0 escaping some chars
: UART-send-text-esc ( a n -- ) 
    BOUNDS
    ?DO
        RPi0-CHAR-TO-ESCAPE 1+
        RPi0-FLAG-TO-ESCAPE COUNT
        I C@ (MAP) 0=
        IF
            [CHAR] \ 
            UART-TX-BYTE        \ send each character
        THEN
        I C@ UART-TX-BYTE       \ send each character
    LOOP
;


: RPi0-SEND-LINE ( a n -- )
    \ send echo and space    
    RPi0-TXT-ECHO COUNT     \ a n
    UART-TX-BYTE            \ a n
    \ send line content escaping >
    UART-SEND-TEXT-esc      \ a n
    \ send a final redirection >>
    [CHAR] > DUP            \ a n c
    UART-TX-BYTE            \ a n c
    UART-TX-BYTE            \ a n 
;


\ accepts a filespec in the current input stream
\ then send block n to RPi0 via UART
\ appending file to RPi0 filesystem
: RPi0-SEND-BLOCK ( n -- "filespec" )
    BL WORD COUNT               \ n  a1 n1
    ROT BLOCK                   \ a1 n1 a0
    B/BUF BOUNDS                \ a1 n1 a0 a0+k
    \ for each row 
    DO                          \ a1 n1 
        \ send echo and space    
        RPi0-TXT-ECHO COUNT     \ a1 n1 a2 n2
        UART-TX-BYTE            \ a1 n1 
        \ send line content escaping >
        I C/L                   \ a1 n1 a 64
        UART-SEND-TEXT-esc      \ a1 n1
        \ send a final redirection >>
        [CHAR] > DUP            \ a1 n1 c c
        UART-TX-BYTE            \ a1 n1 c
        UART-TX-BYTE            \ a1 n1
        \ send filename
        UART-SEND-TEXT-esc      \ a1 n1 
    C/L +LOOP               
    2DROP   
;

