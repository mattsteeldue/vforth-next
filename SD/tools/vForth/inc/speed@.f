\
\ speed@.f
\
\ Set CPU speed via Register #7 Port.
\ 0 -->  3.5 MHz
\ 1 -->  7.0 MHz
\ 2 --> 14.0 MHz
\ 3 --> 28.0 MHz
\
.( SPEED@ )
\

\
: SPEED@ ( -- n )
    7  REG@  3 AND
;

