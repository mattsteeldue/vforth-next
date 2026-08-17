\
\ LOCALS-TESTS.f
\
\ Tests for lib/LOCALS.f -- re-entrant VALUE-like local variables.
\
\ Each definition under test must be preceded IMMEDIATELY by its own
\ LOCALS-FOR: the adjacency guard rejects a definition that is not the
\ first one created after the scope was declared.
\

NEEDS LOCALS
NEEDS RECURSE

MARKER TESTING-TASK

    NEEDS TESTING

TESTING \ re-entrant VALUE-like local variables

DECIMAL

\ ---------------------------------------------------------------------------
\ definitions under test
\ ---------------------------------------------------------------------------

3 LOCALS-FOR L-SUM3    A B C
: L-SUM3    ( a b c -- n )      LOCALS  A B + C + ;

2 LOCALS-FOR L-ORDER   X Y
: L-ORDER   ( x y -- x y )      LOCALS  X Y ;

2 LOCALS-FOR L-TO      P Q
: L-TO      ( p q -- n )        LOCALS  P Q + TO P  P ;

1 LOCALS-FOR L-SQ      N
: L-SQ      ( n -- n2 )         LOCALS  N N * ;

2 LOCALS-FOR L-NEST    U V
: L-NEST    ( u v -- n )        LOCALS  U L-SQ  V L-SQ + ;

8 LOCALS-FOR L-EIGHT   E1 E2 E3 E4 E5 E6 E7 E8
: L-EIGHT   ( 8n -- n )         LOCALS
    E1 E2 + E3 + E4 + E5 + E6 + E7 + E8 + ;

\ recursion: N is used AFTER the recursive call, so it only comes out
\ right if the inner activation restored the outer value on the way out.

1 LOCALS-FOR L-FACT    N
: L-FACT    ( n -- n! )         LOCALS
    N 1 > IF  N 1- RECURSE  N *  ELSE  1  THEN ;

1 LOCALS-FOR L-TRI     TN
: L-TRI     ( n -- n )          LOCALS
    TN 0= IF  0  ELSE  TN 1- RECURSE  TN +  THEN ;

\ an early EXIT must unwind exactly like the final one

1 LOCALS-FOR L-EARLY   Z
: L-EARLY   ( z -- n )          LOCALS
    Z 0= IF  999 EXIT  THEN  Z 10 * ;

\ ---------------------------------------------------------------------------
\ basic use
\ ---------------------------------------------------------------------------

T{  1 2 3 L-SUM3            ->  6               }T
T{  5 L-SQ                  ->  25              }T

\ declaration order is preserved: the first name declared receives the
\ deepest argument, so L-ORDER gives back exactly what it was given.

T{  7 9 L-ORDER             ->  7 9             }T

\ ---------------------------------------------------------------------------
\ the arguments are consumed, and nothing below them is disturbed
\ ---------------------------------------------------------------------------

T{  111 1 2 3 L-SUM3        ->  111 6           }T
T{  222 5 L-SQ              ->  222 25          }T

\ ---------------------------------------------------------------------------
\ TO writes a local (the core TO works unchanged: a local is a CONSTANT)
\ ---------------------------------------------------------------------------

T{  3 4 L-TO                ->  7               }T
T{  0 0 L-TO                ->  0               }T

\ ---------------------------------------------------------------------------
\ nesting: a word with locals calling another word with locals
\ ---------------------------------------------------------------------------

T{  3 4 L-NEST              ->  25              }T
T{  0 7 L-NEST              ->  49              }T

\ ---------------------------------------------------------------------------
\ re-entrancy: two live activations of the SAME word keep separate values,
\ because every entry saves the previous contents and every exit path
\ restores them. Keep the depth small: each level costs 4 bytes plus 4 per
\ local on the 160-byte return stack.
\ ---------------------------------------------------------------------------

T{  1 L-FACT                ->  1               }T
T{  5 L-FACT                ->  120             }T
T{  7 L-FACT                ->  5040            }T
T{  5 L-TRI                 ->  15              }T
T{  10 L-TRI                ->  55              }T

\ the caller's own local is intact after the callee returned

T{  333 5 L-FACT            ->  333 120         }T

\ ---------------------------------------------------------------------------
\ an early EXIT unwinds too
\ ---------------------------------------------------------------------------

T{  0 L-EARLY               ->  999             }T
T{  7 L-EARLY               ->  70              }T

\ ---------------------------------------------------------------------------
\ MAXLOCALS boundary: eight locals is the documented maximum
\ ---------------------------------------------------------------------------

T{  1 2 3 4 5 6 7 8 L-EIGHT ->  36              }T

\ ---------------------------------------------------------------------------
\ Not covered here, because a failure aborts instead of returning a value
\ and cannot be expressed as T{ ... }T. Verified by hand on the emulator:
\
\   0 LOCALS-FOR ZZZ            -> LOCALS: bad count
\   9 LOCALS-FOR ZZZ ...        -> LOCALS: bad count
\   : OOPS LOCALS ;             -> LOCALS: no scope declared
\   scope, then an unrelated definition, then LOCALS
\                               -> LOCALS: scope not adjacent
\   FORTH then a local name     -> undefined (scoping works)
\ ---------------------------------------------------------------------------

CR .( LOCALS-TESTS done. Type TESTING-TASK to unload. ) CR
