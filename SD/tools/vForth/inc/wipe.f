\
\ WIPE.f
\
.( WIPE )

NEEDS EDITOR

BASE @ DECIMAL

\
\ Set content of current Screen to blanks and stores two nulls in the first
\ two character position
\
: WIPE ( -- )
    0 SCR @ B/SCR * DUP B/SCR OVER + SWAP
    DO
        I BLOCK B/BUF BLANK
        UPDATE
    LOOP
    BLOCK !
;

BASE !
