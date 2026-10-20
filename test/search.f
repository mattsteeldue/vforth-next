\
\ test/search.f
\

NEEDS TESTING

TESTING String - SEARCH

T{ S1 S2 SEARCH -> S1 DROP 9 + 4 -1 }T
T{ S1 S1 SEARCH -> S1 -1 }T
T{ S1 S1 DROP 0 SEARCH -> S1 -1 }T
T{ S1 S4 SEARCH -> S1 0 }T
T{ S2 S1 SEARCH -> S2 0 }T
T{ S1 S1 1- SEARCH -> S1 -1 }T
T{ S1 S1 1 /STRING SEARCH -> S1 1 /STRING -1 }T
T{ S1 DROP 0 S2 SEARCH -> S1 DROP 0 0 }T
\ a match at the very end, and a partial match just before the real one
T{ S1 S1 + 2 - 2 SEARCH -> S1 + 2 - 2 -1 }T
T{ S5 S5 1 /STRING SEARCH -> S5 1 /STRING -1 }T
\ case is ignored at start-up, as by COMPARE; CASEON makes it count
T{ S1 S6 SEARCH -> S1 DROP 9 + 4 -1 }T
CASEON
T{ S1 S6 SEARCH -> S1 0 }T
CASEOFF

