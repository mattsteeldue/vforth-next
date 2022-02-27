\
\ test/environment^.f
\
\ since filename environment?.f is illegal.


NEEDS TESTING

TESTING F.6.1.1345 - ENVIRONMENT?

\ should be the same for any query starting with X:
T{ S" X:deferred" ENVIRONMENT? DUP 0= XOR INVERT -> <TRUE>  }T
T{ S" X:notfound" ENVIRONMENT? DUP 0= XOR INVERT -> <FALSE> }T


