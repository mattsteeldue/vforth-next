\
\ XRND-TESTS.f
\
\ XSEED, XNEXT, XRANDOMIZE, XRND: the generator of NextBASIC's RND.
\ Expected values from the reference model: python3 util/next-rnd.py --vectors
\ planners/archive/NEXTBASIC-RND-PLAN.md
\
NEEDS TESTING
DECIMAL

NEEDS XRANDOMIZE
NEEDS XRND

TESTING Zx Next - Custom - XRND

\ one step: lo hi -> lo' hi'
T{ $0000 $0000 XNEXT -> $0101 $8080 }T
T{ $0001 $0000 XNEXT -> $0101 $8080 }T
T{ $0101 $8080 XNEXT -> $4081 $4001 }T
T{ $5678 $1234 XNEXT -> $1F6F $91F1 }T
T{ $FFFF $FFFF XNEXT -> $00FF $7F80 }T
T{ $0000 $8000 XNEXT -> $0000 $8040 }T

\ XRANDOMIZE sets XSEED, and SEED (23670) is left alone
T{ 23670 @  $1234 $5678 XRANDOMIZE  23670 @ = -> -1 }T
T{ XSEED 2@ -> $1234 $5678 }T

\ the state of NextBASIC after a reset and RANDOMIZE 1
T{ 1 0 XRANDOMIZE  100 XRND 100 XRND 100 XRND -> 0 1 97 }T
T{ XSEED 2@ -> $6161 $F1E1 }T

\ 0 XRND and 1 XRND give 0 and take no step
T{ 0 XRND 1 XRND XSEED 2@ -> 0 0 $6161 $F1E1 }T

T{ 1 0 XRANDOMIZE  6 XRND 6 XRND 6 XRND 6 XRND 6 XRND 6 XRND
   -> 0 1 1 0 4 4 }T
T{ XSEED 2@ -> $E022 $474C }T

\ just above a power of 2: the mask is 511 and half the draws are thrown
T{ 1 0 XRANDOMIZE  257 XRND 257 XRND 257 XRND 257 XRND -> 128 1 8 220 }T
T{ XSEED 2@ -> $0571 $90DC }T

\ the full mask $FFFF
T{ 1 0 XRANDOMIZE  65535 XRND 65535 XRND 65535 XRND
   -> 32896 16385 61921 }T
T{ XSEED 2@ -> $6161 $F1E1 }T

T{ 1 0 XRANDOMIZE  2 XRND 2 XRND 2 XRND 2 XRND 2 XRND 2 XRND 2 XRND 2 XRND
   -> 0 1 1 0 0 1 0 1 }T
T{ XSEED 2@ -> $1443 $2A29 }T
