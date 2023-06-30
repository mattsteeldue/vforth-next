\
\ DSQRT.f
\
.( DSQRT )
\
\ Square root
\
DECIMAL
NEEDS INVERT
\
: DSQRT ( d -- n )
    [ 0 INVERT 1 RSHIFT INVERT ] LITERAL    \ number with high bit set only 
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

