\
\ random.f  
\
\ Leo Brodie - Starting Forth
\ RANDOM definition
\ 
.( RANDOM )
\
BASE @

DECIMAL
\
: RANDOM ( -- u )
    23670           \ a         \ address of "SEED" system variable 
    DUP @           \ a n
    31421 UM* DROP  \ a n
    6927 +          \ a n       \ 31421 and 6927 are coprime
    TUCK            \ n a n
    SWAP !          \ n         \ store back to SEED
;

BASE !
\
