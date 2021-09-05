\
\ DSQRT.f
\
.( DSQRT included ) 6 EMIT
\
\ Square root
\
DECIMAL
\
: DSQRT ( d -- n )
    32768                  \ d n
    15 0 DO
        >R                 \ d         R: n
        2DUP R@            \ d d n    
        UM/MOD             \ d r q
        NIP                \ d q
        R>                 \ d q n     R:
        + 1 RSHIFT         \ d (q+n)/2
    LOOP
    NIP NIP                \ n
; 

