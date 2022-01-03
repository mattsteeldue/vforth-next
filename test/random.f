\
\ random.f  
\
\ Leo Brodie - Starting Forth
\ RANDOM definition
\ 
NEEDS TESTING

TESTING Custom - RANDOM


NEEDS RANDOMIZE
NEEDS RANDOM
NEEDS CHOOSE

\
5C76 CONSTANT V_SEED \ address of "SEED" system variable 

V_SEED @

T{ 0 V_SEED ! RANDOM -> 1B0F }T
T{ 1 V_SEED ! RANDOM -> 95CC }T

V_SEED !
