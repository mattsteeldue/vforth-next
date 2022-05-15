\
\ used-by.f
\
\ Search memory for a specific  xt for debugging purposes
: USED-BY (  xt -- )
  HERE 0 +ORIGIN DO
    DUP I @ = IF I U. THEN
  LOOP
  -1 S0 @ DO
    DUP I @ = IF I U. THEN
  LOOP
  DROP
;



\ HEX : EXAM FF58 EA40
\       DO CR 2B EMIT I U.
\       I USED-BY ?TERMINAL IF LEAVE THEN
\       LOOP ;

