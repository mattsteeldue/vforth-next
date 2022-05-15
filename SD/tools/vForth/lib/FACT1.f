\
\ FACT1.f
\
NEEDS RECURSE
\
\ Factorial single precision
: FACT1 ( n -- n! )
  ?DUP IF
    1- RECURSE *
  ELSE
    1
  THEN
;

