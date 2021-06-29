\
\ 3DUP.f
\
.( 3DUP )
\
\ duplicate the 3 top element on stack.
\
: 3DUP ( n1 n2 n3 -- n1 n2 n3 n1 n2 n3 )
    2 PICK 
    2 PICK
    2 PICK
;
