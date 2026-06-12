\
\ test/evaluate.f
\

NEEDS TESTING

NEEDS S"
NEEDS EVALUATE

TESTING F.6.1.1360 - EVALUATE

: GE1 S" 123" ; IMMEDIATE
: GE2 S" 123 1+" ; IMMEDIATE
: GE3 S" : GE4 345 ;" ;
: GE5 EVALUATE ; IMMEDIATE

( TEST EVALUATE IN INTERP. STATE )
\
T{ GE1 EVALUATE -> 123 }T 
T{ GE2 EVALUATE -> 124 }T
T{ GE3 EVALUATE ->     }T
T{ GE4          -> 345 }T

( TEST EVALUATE IN COMPILE STATE )

\ Regression: EVALUATE run during a file INCLUDE used to drop the rest of
\ the source line (here the closing `;`), so these had to be split across
\ two lines. Fixed 2026-06-11 (doc/EVALUATE-bug-analysis.md): a single line
\ now works again -- this is the regression test for that fix.
\ N.B. nested EVALUATE (EVALUATE inside EVALUATE) is a separate latent
\ issue and is still unaddressed.

T{ : GE6 GE1 GE5 ; -> }T
T{ GE6 -> 123 }T

T{ : GE7 GE2 GE5 ; -> }T
T{ GE7 -> 124 }T

\ my custom test...

: GE8 S" : GE9 678 ;" EVALUATE ; 
T{ GE8 -> }T
T{ GE9 -> 678 }T


