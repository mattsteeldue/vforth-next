\ evaluate-bug-repro.f -- reproduction for the EVALUATE bug
\ See doc/EVALUATE-bug-analysis.md
\ from the keyboard, first:
\   NEEDS EVALUATE
\   CREATE TST-A ," 1 2 + ."
\   CREATE TST-B ," 3 4 + ."
\ then:  INCLUDE test/evaluate-bug-repro.f
CR
.( case A same line: ) TST-A COUNT EVALUATE .( tail-A) CR
.( case B new line: ) TST-B COUNT
EVALUATE
.( tail-B) CR
.( done) CR
