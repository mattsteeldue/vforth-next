\
\ expect.f
\
\ Inverse/True Video character sequence
\
.( EXPECT )
\
\ expect
\ Accepts at most n1 characters from terminal and stores them at address a 
\ CR stops input. A 'nul' is added as trailer.
\ the string length is kept in SPAN user variable.
: EXPECT ( -- )
  ACCEPT DROP
;
