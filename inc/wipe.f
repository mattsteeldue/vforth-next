\
\ WIPE.f
\
.( WIPE )

NEEDS EDITOR

BASE @ DECIMAL

\
\ Set content of current Screen to blanks and stores a nul in the first
\ character position
\
: WIPE ( -- )    
    0                       \ c 
    SCR @ B/SCR *           \ c n
    DUP B/SCR OVER + SWAP   \ c n n+2 n
    DO                      \ c n 
        I BLOCK             \ c n a
        B/BUF BLANK         \ c n
        UPDATE              \ c n
    LOOP                    \ c n
    BLOCK C!                 
;

BASE !
