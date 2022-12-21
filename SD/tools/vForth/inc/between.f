\
\ between.f
\
\ True if n between a and b, i.e.  a <= n <= b
\
.( BETWEEN )

: BETWEEN ( n a b -- f )
    2 PICK              \  n   a   b   n                    
    <                   \  n   a  n>b    
    -ROT                \ n>b  n   a
    <                   \ n>b n<a
    OR                  \ a>n|n>b
    NOT                 \ a<=n<=b
;

