\
\ h~.f
\
\ this is part of the HEAP memory management libary. See also:
\ FAR HP@ POINTER HEAP S" +C +" HEAP-INIT HEAP-DONE
\ See "Heap memory facility" in PDF documentation for details
\
.( H" included ) 6 EMIT
\
NEEDS >FAR
NEEDS HP@
NEEDS HEAP
\
\ Accept a string and store it to Heap, return a
\ heap-address pointer to a counted string
\ 
: H" ( -- ha )
  HP@ CELL+          \ ha               new heap address as HEAP does
  [CHAR] "  WORD     \ ha  a1           accept string from input stream
  DUP C@ 1+ TUCK     \ ha  u  a1  u     find total length
  HEAP >FAR DROP     \ ha  u  a1  a2    allocate
  ROT                \ ha  a1  a2  u
  CMOVE              \ ha
;
\
\ : C" H" DROP ;
\
