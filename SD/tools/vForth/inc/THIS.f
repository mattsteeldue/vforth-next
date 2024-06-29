\
\ THIS.f
\
.( THIS )

\ Accept text from current input stream and leave address a and length n

BASE @ DECIMAL

\ 
\
: THIS ( -- a n )
    >IN @ >R                    \ save current input pointer
    -2 >IN +!                   \ go back 2 chars to allow comment to work
    [COMPILE] \                 \ skip the rest of current input line

    \ determines remaining data in input string
    BLK @ IF                    \ input not from TIB (keyboard) ?
        BLK @ 1- IF             \ input from Screen ?
            R@                  \ determine length of the rest of current line
            C/L 1- AND  
            C/L SWAP -  
        ELSE                    \ input is from source file (e.g. include)
            B/BUF C/L -         \ rest of current line is 448.
        THEN
    ELSE
        SPAN @ R@ -             \ size of rest input on TIB
    THEN

    \ determine starting point by adding original >IN
    BLK @ 
    IF
        BLK @ BLOCK
    ELSE
        TIB @
    THEN
    R> + SWAP
;

BASE !
