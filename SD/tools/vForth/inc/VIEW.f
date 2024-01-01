\
\ view.f

.( VIEW )

\ Typical usage 
\
\   VIEW filename
\
BASE @
DECIMAL

NEEDS ?ESCAPE

: VIEW ( -- cccc )
    OPEN< >R

    \ prepare char size (85 per line)
    30 EMITC 6 EMITC

    \ use BLOCK number 1 to keep one line of text read from file
    BEGIN
        ?ESCAPE IF
            1
        ELSE
            1 BLOCK B/BUF R@ F_GETLINE
            \ send to ouput
            DUP IF 
                1 BLOCK B/BUF 1- -TRAILING TYPE CR 
            THEN
        THEN
    \ zero byte read means end-of-file
    0= 
    \ or [break] 
    ?TERMINAL OR
    UNTIL

    \ restore screenchar size
    30 EMITC 8 EMITC

    \ closedown
    R> F_CLOSE 42 ?ERROR
;

BASE !

