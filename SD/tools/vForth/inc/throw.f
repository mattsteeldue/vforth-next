\
\ throw.f
\
.( THROW )
\
: THROW ( ... n -- ... n )
  ?DUP IF                \ n       0 THROW is no-op
    HANDLER @ ?DUP IF    \ n       there was a CATCH to
      RP!                \ n       restore prev return stack
      R> HANDLER !       \ n       restore prev handler
      R> SWAP >R         \ sp      n on return stack
      SP! DROP R>        \ n       restore stack
      \ Return to the caller of CATCH because return
      \ stack is restored to the state that existed
      \ when CATCH began execution
    ELSE
      ERROR              \         default error handler
    THEN
  THEN
;

