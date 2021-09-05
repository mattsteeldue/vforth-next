\
\ catch.f
\
.( CATCH included ) 6 EMIT
\  
\
: CATCH ( xt -- n | ff )
  SP@       >R           \ xt   save data stack pointer
  HANDLER @ >R           \ xt   and previous handler
  RP@ HANDLER !          \ xt   set current handler
  EXECUTE                \      execute returns if no THROW
  R> HANDLER !           \      restore previous handler
  R> DROP                \      discard saved data stack ptr
  0                      \ ff
;

