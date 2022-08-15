\
\ random.f  
\
\ RND equivalent
\ random number generator from the sequence n --> (75*(n+1) % 65537)-1
\
\ This piece of code exploits the fact (d % 65537) is equivalent to subtracting 
\ the higher 16-bit part from the lower 16-bit part, but for a boundary 
\ condition resolved by adding 1, depending on which 16-bit part is bigger.
\ 
.( RND )
\
BASE @

DECIMAL
\
\ gives a pseudo-random number between 0 and u-1
: RND ( u -- u2 )
    23670           \ u a         \ address of "SEED" system variable 
    DUP @           \ u a n
    1+ ?DUP         \ u a n+1
    IF
        75 UM*      \ u a d    = 75*(n+1)
        2DUP U< 
        IF 
            - 
        ELSE 
            - 1- 
        THEN        \ u a  n   = (75*(n+1) % 65537)-1
    ELSE
        -75         \ u a  n   = 65461
    THEN
    TUCK            \ u n a n
    SWAP !          \ u n         \ store back to SEED
    UM* NIP         \ u1
;

BASE !
\
