\
\ FACT1.f
\
NEEDS RECURSE
\
\ Factorial from single precision to double precision
: FACT1 ( u -- ud )
    ?DUP IF         \  u
        DUP 1-      \  u  u-1
        RECURSE     \  u  d
        DROP        \  u  (u-1)!
        UM*         \  d
    ELSE
        1 0         \  d
    THEN
;
