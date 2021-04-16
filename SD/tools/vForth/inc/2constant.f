\
\ 2constant.f
\
.( 2CONSTANT ) CR
\
\ 2constant ( d -- )  compile time
\           ( -- d )  run-time
: 2CONSTANT 
    <BUILDS SWAP , , DOES>
    2@
;
\
