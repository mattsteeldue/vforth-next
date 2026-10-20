\
\ STRING-TESTS.f
\
\ Tests for the string words of inc/ that the Forth-2012 String word set
\ and common practice provide: /STRING, SCAN, SKIP, SEARCH.
\ The test strings are kept inside colon definitions, so that S" does
\ not take a new piece of heap at every use.
\ In the headless emulator: python emu/test_core_suite.py
\ test/STRING-TESTS.f (all passed, 2026-10-18).
\

MARKER TESTING-TASK

WARNING @
0 WARNING ! \ reduce messaging #4

    NEEDS TESTING

WARNING !

    NEEDS S"
    NEEDS /STRING   NEEDS SCAN      NEEDS SKIP      NEEDS SEARCH

 \ Save base value
BASE    @ DECIMAL

: S1  ( -- a n )  S" Spectrum Next" ;
: S2  ( -- a n )  S" Next" ;
: S3  ( -- a n )  S"    abc" ;
: S4  ( -- a n )  S" Nexus" ;
: S5  ( -- a n )  S" aab" ;
: S6  ( -- a n )  S" NEXT" ;

CR

TESTING \ String

    INCLUDE  test/%string.f
    INCLUDE  test/scan.f
    INCLUDE  test/skip.f
    INCLUDE  test/search.f

\ Restore base
BASE !

