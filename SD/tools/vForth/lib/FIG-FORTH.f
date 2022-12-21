\
\ fig-forth.f
\

CODE FIG-FORTH 
HEX DD C, E9 C, ( NEXT ) SMUDGE \ jp (ix)


WARNING @
0 WARNING !

\ variable with initialisation value
: VARIABLE 
    [COMPILE] VARIABLE
    -2 ALLOT ,
; IMMEDIATE


\ minus is the same as negate
: MINUS ( n -- -n )
    NEGATE
;


: SP!
    S0 @ SP!
;

WARNING !

