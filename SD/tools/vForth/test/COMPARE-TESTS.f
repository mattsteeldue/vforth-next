\
\ COMPARE-TESTS.f
\
\ COMPARE ( a1 c1 a2 c2 -- n ) is in the core since build 2026-10-28,
\ where it replaced the primitive (COMPARE) ( a1 a2 n -- n ), now
\ inc/(compare).f. Plan: planners/COMPARE-CORE-PLAN.md.
\
\     INCLUDE test/COMPARE-TESTS.f
\

.( COMPARE-TESTS ) CR

NEEDS TESTING

DECIMAL

CREATE S-ZOO  CHAR z C, CHAR o C, CHAR o C,
CREATE S-ZOOLOGY
    CHAR z C, CHAR o C, CHAR o C, CHAR l C,
    CHAR o C, CHAR g C, CHAR y C,
CREATE S-ZOA  CHAR z C, CHAR o C, CHAR a C,
CREATE S-AOO  CHAR a C, CHAR o C, CHAR o C,
CREATE S-UZOO CHAR Z C, CHAR O C, CHAR O C,

\ a 300-byte buffer, to go past the old 8-bit counter
CREATE BIG1 300 ALLOT  BIG1 300 CHAR x FILL
CREATE BIG2 300 ALLOT  BIG2 300 CHAR x FILL

TESTING \ equal strings
T{ S-ZOO 3 S-ZOO 3 COMPARE -> 0 }T
T{ S-ZOO 3 S-ZOOLOGY 3 COMPARE -> 0 }T

TESTING \ one is a prefix of the other: the shorter is the lesser
T{ S-ZOO 3 S-ZOOLOGY 7 COMPARE -> -1 }T
T{ S-ZOOLOGY 7 S-ZOO 3 COMPARE -> 1 }T

TESTING \ empty strings
T{ S-ZOO 0 S-ZOO 3 COMPARE -> -1 }T
T{ S-ZOO 3 S-ZOO 0 COMPARE -> 1 }T
T{ S-ZOO 0 S-AOO 0 COMPARE -> 0 }T

TESTING \ difference at the first and at the last byte
T{ S-AOO 3 S-ZOO 3 COMPARE -> -1 }T
T{ S-ZOO 3 S-AOO 3 COMPARE -> 1 }T
T{ S-ZOA 3 S-ZOO 3 COMPARE -> -1 }T
T{ S-ZOO 3 S-ZOA 3 COMPARE -> 1 }T

TESTING \ a difference decides before the lengths do
T{ S-ZOA 3 S-ZOOLOGY 7 COMPARE -> -1 }T
T{ S-ZOOLOGY 7 S-ZOA 3 COMPARE -> 1 }T

TESTING \ CASEOFF (the default) ignores case, CASEON does not
CASEOFF
T{ S-ZOO 3 S-UZOO 3 COMPARE -> 0 }T
CASEON
T{ S-ZOO 3 S-UZOO 3 COMPARE -> 1 }T
T{ S-UZOO 3 S-ZOO 3 COMPARE -> -1 }T
CASEOFF

TESTING \ lengths over 255
T{ BIG1 300 BIG2 300 COMPARE -> 0 }T
T{ BIG1 299 BIG2 300 COMPARE -> -1 }T
T{ BIG1 300 BIG2 256 COMPARE -> 1 }T
CHAR y BIG2 299 + C!
T{ BIG1 300 BIG2 300 COMPARE -> -1 }T
T{ BIG2 300 BIG1 300 COMPARE -> 1 }T

TESTING \ (COMPARE), the compatibility word
NEEDS (COMPARE)
T{ S-ZOO S-ZOOLOGY 3 (COMPARE) -> 0 }T
T{ S-AOO S-ZOO 3 (COMPARE) -> -1 }T
T{ S-ZOO S-AOO 3 (COMPARE) -> 1 }T
T{ S-ZOO S-AOO 0 (COMPARE) -> 0 }T

TESTING \ SEARCH, built on COMPARE
NEEDS SEARCH
T{ S-ZOOLOGY 7 S-ZOO 3 SEARCH NIP NIP -> -1 }T
T{ S-ZOOLOGY 7 S-ZOA 3 SEARCH NIP NIP -> 0 }T
