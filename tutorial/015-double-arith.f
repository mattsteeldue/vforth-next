\
\ 015-double-arith.f
\ 32-bit (double-precision) integer arithmetic.
\
\ The Z80 is a 8-bit processor, but a single vForth cell holds values
\ -32768 to 32767 (signed) or 0 to 65535 (unsigned).  When larger
\ numbers are needed -- screen addresses beyond 65535, counters, game
\ scores, file sizes -- double-precision integers are used.
\
\ A double occupies two consecutive cells on the stack.  The low cell
\ (LSCell) is pushed first and sits deeper; the high cell (MSCell) is
\ on top.  Stack notation: d for signed, ud for unsigned; shown as
\ two entries with (lo hi) order.
\
\ Positive doubles: e.g. 120,000 on stack is two integer ( 54464 1 ).
\ Negative doubles use two's-complement throughout the 32-bit range.
\ for example -120,000 on stack is 11072 65534, that is -2.
\
\ Core double words (no NEEDS): D+ DNEGATE D+- (cond negate)
\ Words requiring NEEDS: D- DABS D0= D= 2CONSTANT M+ S>D
\
\ The core word for converting signed single to double is S>D (the S->D
\ is obsolete).
\
\ Starting FORTH (Brodie): Ch.5, Ch.8(dbl)  |  vForth screens 821-825, 854-864
\ Reference: sec.2.12.11, sec.4.3
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   015 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 015 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 015: double arithmetic loaded. ) CR
.(     Type NEWTASK to unload.        ) CR

NEEDS S>D
NEEDS D-
NEEDS DABS
NEEDS D0=
NEEDS D=
NEEDS 2CONSTANT
NEEDS 2VARIABLE
NEEDS M+


\ ===========================================================================
\ 1. Double literals and S>D
\ ===========================================================================
\
\ A number containing . , / - or : is read as a double -- two cells pushed:
\
\   120,000 .S       => 120000  0       (lo=120000 hi=0)
\   3.14    .S       => 314     0       (NOT float! just double)
\
\ S>D ( n -- d ) sign-extends a single to double:
\
\   42    S>D  .S   => 42    0         (positive: hi=0)
\   -1    S>D  .S   => -1   -1         (negative: hi=$FFFF)
\
\ D. ( d -- ) prints a signed double followed by a space.
\ DU. ( ud -- ) prints an unsigned double.
\
\   120,000  D.             => 120000
\   -1 S>D   D.             => -1


\ ===========================================================================
\ 2. D+ and D-
\ ===========================================================================
\
\ D+ ( d1 d2 -- d3 )   add two double-precision integers
\ D- ( d1 d2 -- d3 )   subtract  (NEEDS D-)
\
\   50,000  S>D  50,000  S>D  D+  D.   => 100000
\   100,000 S>D  30,000  S>D  D-  D.   => 70000
\
\ D- is defined as DNEGATE D+.  DNEGATE (core) negates a double:
\
\   1 S>D  DNEGATE  D.   => -1
\   0 S>D  DNEGATE  D.   => 0


\ ===========================================================================
\ 3. DABS and comparison
\ ===========================================================================
\
\ DABS  ( d -- ud )   absolute value; result is unsigned
\ D0=   ( d -- f )    true if double is zero
\ D=    ( d1 d2 -- f ) true if both doubles equal
\
\   -42 S>D  DABS  D.        => 42
\    42 S>D  DABS  D.        => 42
\    0  S>D  D0=   .         => -1    (true)
\   42  S>D  D0=   .         => 0     (false)


\ ===========================================================================
\ 4. 2CONSTANT -- named double constants
\ ===========================================================================
\
\ 2CONSTANT ( d -- ) defines a constant holding a 32-bit value.
\ When the constant is executed, it pushes back the stored double.
\
\   120000  0  2CONSTANT BIG-NUMBER
\   BIG-NUMBER  D.      => 120000
\
\   \ Useful for hardware constants larger than 65535:
\   $0000  $4000  2CONSTANT SCREEN-BASE-D  \ $40000000 (example)

100000  0  2CONSTANT BUDGET
   500  0  2CONSTANT MONTHLY
CR
.( Try: BUDGET D.    ) CR     \ => 100000
.( Try: BUDGET MONTHLY D-  D. ) CR   \ => 99500


\ ===========================================================================
\ 5. M+  -- add a single to a double
\ ===========================================================================
\
\ M+ ( d n -- d' )   add single n to double d; result is double
\
\ Use M+ to accumulate a running total into a double variable:
\
\   2VARIABLE TOTAL
\   0. TOTAL 2!
\   : ADD-TO-TOTAL  ( n -- )  TOTAL 2@  ROT M+  TOTAL 2! ;
\   1000 ADD-TO-TOTAL
\   2000 ADD-TO-TOTAL
\   TOTAL 2@ D.   => 3000

2VARIABLE TOTAL

: RESET-TOTAL  ( -- )   0. TOTAL 2! ;
: ADD-TO-TOTAL  ( n -- )  TOTAL 2@  ROT M+  TOTAL 2! ;
: .TOTAL        ( -- )    TOTAL 2@  D.  CR ;

RESET-TOTAL

.( Try: 1000 ADD-TO-TOTAL  2000 ADD-TO-TOTAL  .TOTAL ) CR
.( (should print 3000)                                ) CR


\ ===========================================================================
\ 6. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ NEEDS TESTING
\ T{  42 S>D       -> 42 0          }T
\ T{  -1 S>D       -> -1 -1         }T
\ T{  0  S>D D0=   -> -1            }T
\ T{  1  S>D D0=   -> 0             }T
\ T{  50,000 S>D  50,000 S>D D+  -> 100000 0 }T
\ T{  -42 S>D DABS -> 42 0          }T
\ T{  42  S>D DABS -> 42 0          }T
\ T{  100000 0  500 0 D= -> 0       }T
\ T{  42 0   42  0 D=  -> -1        }T
