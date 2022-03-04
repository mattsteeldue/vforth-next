\
\ test/save-input.f
\

NEEDS TESTING

NEEDS SAVE-INPUT
NEEDS S"

TESTING F.6.2.2182 - SAVE-INPUT

\ Testing with a file source
VARIABLE siv -1 siv !
: NeverExecuted
   ." This should never be executed" ABORT
;

11111 SAVE-INPUT

siv @

[IF]
   0 siv !
   RESTORE-INPUT
   NeverExecuted
[ELSE]
   \ Testing the ELSE part is executed
   22222
[THEN]

T{ -> 11111 0 22222 }T    \ 0 comes from RESTORE-INPUT

\ Testing with a string source
VARIABLE si_inc 0 si_inc !

: si1
   si_inc @ >IN +!
   15 si_inc !
;

: s$ S" SAVE-INPUT si1 RESTORE-INPUT 12345" ;

T{ s$ EVALUATE si_inc @ -> 0 2345 15 }T

\ Testing nesting
: read_a_line
   REFILL 0=
   ABORT" REFILL failed"
;

0 si_inc !
2VARIABLE 2res -1. 2res 2!

: si2
   read_a_line
   read_a_line
   SAVE-INPUT
   read_a_line
   read_a_line
   s$ EVALUATE 2res 2!
   RESTORE-INPUT
;

\ WARNING: do not delete or insert lines of text after si2 is called otherwise the next test will fail

si2
33333                  \ This line should be ignored
2res 2@ 44444          \ RESTORE-INPUT should return to this line

55555

T{ -> 0 0 2345 44444 55555 }T
