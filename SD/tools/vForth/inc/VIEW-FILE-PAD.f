\
\ view-file-pad.f

.( VIEW-FILE-PAD )

\ Typical usage 
\
\   PAD" filename" VIEW-FILE-PAD
\
\ Given PAD holds a z-string
\ open it and send to screen
\ If file not exists, report message 43 "File not found."
\
BASE @
DECIMAL

NEEDS .PAD
NEEDS PAD"
NEEDS ?ESCAPE

: VIEW-FILE-PAD ( -- )
    PAD DUP 10 - 01 F_OPEN 
    IF
        DROP .PAD SPACE
        43 MESSAGE
    ELSE
        >R 
        \ prepare char size (85 per line)
        30 EMITC 6 EMITC
        \ use BLOCK number 1 to keep one line of text read from file
        \ buffer address is stable: nothing in the loop calls BLOCK
        1 BLOCK
        BEGIN
            ?ESCAPE IF
                1
            ELSE
                DUP B/BUF R@ F_GETLINE
                \ send to output
                DUP IF
                    OVER B/BUF 1- -TRAILING TYPE CR
                THEN
            THEN
        \ zero byte read means end-of-file
        0=
        \ or [break]
        ?TERMINAL OR
        UNTIL
        DROP
        \ restore screenchar size
        30 EMITC 8 EMITC
        \ closedown
        R> F_CLOSE 42 ?ERROR
    THEN
;


BASE !

