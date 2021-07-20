\
\ random.f  
\
\ Leo Brodie - Thinking Forth
\ RANDOM definition
\ 
\
.( RANDOM ) 
\
DECIMAL
\
: RANDOM ( -- u )
    23670           \ a : SEED system variable
    DUP @           \ a n
    31421 * 6927 +  \ a n
    TUCK            \ n a n
    SWAP !          \ n  
;

