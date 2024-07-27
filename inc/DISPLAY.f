\
\ DISPLAY.f
\
.( DISPLAY )

\ Counterpart of ASK, this definition uses emits n characters-long string currently stored at PAD

BASE @ DECIMAL

\ 
\
: DISPLAY ( n -- )
    CR PAD SWAP TYPE CR 
;

BASE !
