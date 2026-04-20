\
\ THIS.f
\
.( THIS )

\ Accept text from current input stream and leave address a and length n
\ Useful to be used within LOAD or by ASK to send a in-line command
\ to RPi0 and receive reply to PAD.

BASE @ DECIMAL

\ 
\
: THIS ( -- a n )
    >IN @ >R                    \ save current input pointer >IN
    -2 >IN +!                   \ go back 2 chars to allow the followind compiled \ 
    [COMPILE] \                 \ to correctly skip the rest of current input line

    \ determines remaining data in input string
    BLK @ IF                    \ input not from TIB (keyboard) ?
        BLK @ 1- IF             \ input from BLOCK/Screen ?
            R@                  \ determine length of the rest of current line
            C/L 1- AND  
            C/L SWAP -  
        ELSE                    \ input is from source file (e.g. include)
            B/BUF C/L -         \ rest of current line is always 448.
        THEN
    ELSE
        SPAN @ R@ -             \ size of rest input from TIB computed from SPAN
    THEN

    \ determine starting point by adding original >IN
    BLK @ IF                    \ input not from TIB (keyboard) ?
        BLK @ BLOCK             \ INCLUDE uses BLOCK 0.
    ELSE
        TIB @
    THEN
    R> + SWAP
;

BASE !
