\
\ %string.f
\
.( /STRING )
\
\ Drop the first k characters of the string a n: the address moves
\ forward by k and the length shrinks by as much. Nothing is copied.
\ Forth-2012 String word set (17.6.1.0245).
\
: /STRING  ( a n k -- a+k n-k )
    ROT OVER + -ROT -
;

