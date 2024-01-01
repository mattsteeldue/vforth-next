\
\ testing.f
\
\ Testing Suite

\ This is the source for the ANS test harness, it is based on the
\ harness originally developed by John Hayes

\ (C) 1995 JOHNS HOPKINS UNIVERSITY / APPLIED PHYSICS LABORATORY
\ MAY BE DISTRIBUTED FREELY AS LONG AS THIS COPYRIGHT NOTICE REMAINS.
\ VERSION 1.1

\ Revision history and possibly newer versions can be found at
\ http://www.forth200x/tests/ttester.fs

\ Aug 2021-2022 - Matteo Vitturi
\ Adaptation for Sinclair ZX Spectrum Next
\
\ Limited Floating-Point support.
\

.( TESTING Suite ) 

DECIMAL 

NEEDS S"
NEEDS INVERT
NEEDS SOURCE
NEEDS .S
NEEDS <>
NEEDS COMPARE
NEEDS POSTPONE
NEEDS CHAR+
NEEDS DEPTH

: S= \ ( addr1 c1 addr2 c2 -- t/f )  \ Compare two strings.
    COMPARE 0=
;

\

0 VARIABLE ACTUAL-DEPTH    ACTUAL-DEPTH !
CREATE ACTUAL-RESULTS 30 CELLS ALLOT
0 VARIABLE START-DEPTH     START-DEPTH  !
0 VARIABLE XCURSOR         XCURSOR      !

' ERROR VARIABLE ERROR-XT  ERROR-XT     !

WARNING @ 0 WARNING !
: ERROR ERROR-XT @ EXECUTE ; \ for vectoring of error reporting
WARNING !

: ERROR1 ( n -- )
  SOURCE -TRAILING CR TYPE CR
  MESSAGE .S CR
;


: T{  ( -- )  \ record pre-test depth
  DEPTH START-DEPTH !
  0 XCURSOR !
;


: ->   ( ... -- ) \ record depth and contents of stack
  DEPTH DUP ACTUAL-DEPTH !       \ record depth
  START-DEPTH @ > IF             \ is there something on stack
    DEPTH START-DEPTH @ - 0 DO   \ so save them
      ACTUAL-RESULTS I CELLS + !
    LOOP
  THEN
;


: }T    ( ... -- )  \  compare stack images
  DEPTH ACTUAL-DEPTH @ = IF         \ if depths match
    DEPTH START-DEPTH @ > IF        \ if something on the stack
      DEPTH START-DEPTH @ - 0 DO    \ for each stack item 
        ACTUAL-RESULTS I CELLS + @  \ compare actual with expected
        <> IF 50 ERROR LEAVE THEN   \ Message: Incorrect result.
      LOOP
    THEN
  ELSE                               \ depth mismatch
    51 ERROR                         \ Message: Wrong number of results.
  THEN
;


: ...}T  \ ( ... -- )
  XCURSOR @ START-DEPTH @ + ACTUAL-DEPTH @ <> IF
    52 ERROR   
    \ Message: Number of cell result before '->' does not match ...}T spec.
  ELSE DEPTH START-DEPTH @ = NOT IF
    53 ERROR   
    \ Message: Number of cell result before and after '->' does not match
  THEN THEN
;


: XTESTER \ ( X -- )
  DEPTH 0=  ACTUAL-DEPTH @ XCURSOR @ START-DEPTH @ + 1+ <
  OR IF
    54 ERROR
    \ Message: Number of cell result after '->' below ...}T spec.
  ELSE
    50 ERROR
    \ Message: Incorrect result.
    1 XCURSOR +!
  THEN
;


: X}T XTESTER ...}T ;
: XX}T XTESTER XTESTER ...}T ;
: XXX}T XTESTER XTESTER XTESTER ...}T ;
: XXXX}T XTESTER XTESTER XTESTER XTESTER ...}T ;


1 VARIABLE VERBOSE       VERBOSE        !

: TESTING \ ( -- ) talking comment
  SOURCE
  VERBOSE @ IF
    -TRAILING TYPE
  THEN
  [COMPILE] \
  CR
;

' ERROR1 ERROR-XT !      \ this activates new error handler


TESTING Test Suite

\ .( Test Suite - Basic Assumptions ) CR

 0   CONSTANT 0S
-1   CONSTANT 1S
1S 1 RSHIFT INVERT CONSTANT  MSB


\ .( Test Suite - Comparison        ) CR

0 INVERT                    CONSTANT MAX-UINT
0 INVERT 1 RSHIFT           CONSTANT MAX-INT
0 INVERT 1 RSHIFT INVERT    CONSTANT MIN-INT
0 INVERT 1 RSHIFT           CONSTANT MID-UINT
0 INVERT 1 RSHIFT INVERT    CONSTANT MID-UINT+1

\ .( Test Suite - True and False ) CR

0S  CONSTANT <FALSE>
1S  CONSTANT <TRUE>

\ .( Test Suite - Postpone ) CR

: IFFLOORED [ -3 2 / -2 = INVERT ] LITERAL IF POSTPONE \ THEN ;
: IFSYM     [ -3 2 / -1 = INVERT ] LITERAL IF POSTPONE \ THEN ;

\ .( Test Suite - Number Pattern ) CR

HEX 24 CONSTANT MAX-BASE
HEX 20 CONSTANT #BITS-UD

\ .( Test Suite - Memory movement ) CR

CREATE FBUF 00 C, 00 C, 00 C,
CREATE SBUF 12 C, 34 C, 56 C,
: SEEBUF FBUF C@ FBUF CHAR+ C@ FBUF CHAR+ CHAR+ C@ ;


