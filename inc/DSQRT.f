\
\ DSQRT.f
\
.( DSQRT )
\
\ Square root of d (modified Newton-Raphson method)
\ 0 <= d < 1073741824
\ n <-- ( n + d/n ) / 2
\
DECIMAL
\
: DSQRT ( d -- n )
    [ -1 1 RSHIFT -1 XOR ] LITERAL \ number with high bit set only 
    15 0 DO 
        >R 2DUP R@      \ d d n     R: n
        UM/MOD NIP      \ d d/n
        R> +            \ d n+d/n
        1 RSHIFT        \ d (n+d/n)/2
    LOOP
    NIP NIP             \ n
;
