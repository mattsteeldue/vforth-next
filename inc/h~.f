\
\ h~.f
\
.( H" ) 
\
NEEDS HP@
NEEDS HEAP
\
\
\ Accept a string and store it to Heap, return a
\ heap-address pointer to a counted string
: H" ( -- ha )
  HP@ CELL+          \ ha
  [CHAR] "  WORD     \ ha  a1
  DUP C@ 1+ TUCK     \ ha  u  a1  u
  HEAP >FAR DROP     \ ha  u  a1  a2
  ROT                \ ha  a1  a2  u
  CMOVE              \ ha
;

\ : C" H" DROP ;
\
