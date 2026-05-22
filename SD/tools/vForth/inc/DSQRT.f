\
\ DSQRT.f
\
.( DSQRT )
\
\ Square root of d (modified Newton-Raphson method)
\ 0 <= d < 1073741824
\ n <-- ( n + d/n ) / 2
\
\
: DSQRT ( d -- n )          \ d = high low -->  n = floor(sqrt(d))
    2DUP OR IF    
        OVER 1+ OVER XOR
        16 0 DO 
            >R                      \ d         R: x
            2DUP R@ UM/MOD NIP      \ d (d/x)
            R@ + 1 RSHIFT           \ d x+(d/x)
            DUP R> =                \ d x+(d/x) f
            IF LEAVE THEN           \ leave when x=x+(d/x)
        LOOP
        NIP NIP
    ELSE
        DROP
    THEN
;

