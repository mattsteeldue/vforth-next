\
\ 3DUP.f
\
.( 3DUP included ) 6 EMIT
\
\ duplicate the 3 top element on stack.
\
: 3DUP ( n1 n2 n3 -- n1 n2 n3 n1 n2 n3 )
    2 PICK 
    2 PICK
    2 PICK
;
