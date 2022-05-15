\
\ GCD.f
\
NEEDS RECURSE
\
\ Greatest Common Divisor betwee a and b
: GCD ( n1 n2 -- n3 )
  ?DUP IF
    TUCK MOD RECURSE
  THEN
;

