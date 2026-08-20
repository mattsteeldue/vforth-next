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
\ the { ... } form -- same semantics, declared in place
\
\ Same words as above, re-expressed with { ... } : the names are parsed
\ from the very line being compiled, so this also covers the case of a
\ declaration read from an INCLUDEd file rather than from the keyboard.
\ ---------------------------------------------------------------------------

: B-SUM3    ( a b c -- n )      { A B C }   A B + C + ;
: B-ORDER   ( x y -- x y )      { X Y }     X Y ;
: B-TO      ( p q -- n )        { P Q }     P Q + TO P  P ;
: B-SQ      ( n -- n2 )         { N }       N N * ;
: B-NEST    ( u v -- n )        { U V }     U B-SQ  V B-SQ + ;
: B-EIGHT   ( 8n -- n )         { E1 E2 E3 E4 E5 E6 E7 E8 }
    E1 E2 + E3 + E4 + E5 + E6 + E7 + E8 + ;

: B-FACT    ( n -- n! )         { N }
    N 1 > IF  N 1- RECURSE  N *  ELSE  1  THEN ;

: B-EARLY   ( z -- n )          { Z }
    Z 0= IF  999 EXIT  THEN  Z 10 * ;

T{  1 2 3 B-SUM3            ->  6               }T
T{  111 1 2 3 B-SUM3        ->  111 6           }T
T{  7 9 B-ORDER             ->  7 9             }T
T{  3 4 B-TO                ->  7               }T
T{  5 B-SQ                  ->  25              }T
T{  3 4 B-NEST              ->  25              }T
T{  1 2 3 4 5 6 7 8 B-EIGHT ->  36              }T
T{  7 B-FACT                ->  5040            }T
T{  333 5 B-FACT            ->  333 120         }T
T{  0 B-EARLY               ->  999             }T
T{  7 B-EARLY               ->  70              }T

\ ---------------------------------------------------------------------------
\ { ... -- ... }  -- names after -- are OUTPUT locals: not bound from the
\ stack (created at 0 on every entry), and pushed automatically on every
\ exit path, in declaration order, instead of being referenced by the
\ body. See prompts/LOCALS-PLAN.md section 12 for the design.
\ ---------------------------------------------------------------------------

: B-SUMTO    ( n -- sum )        { N -- ACC }
    N 0> IF  N 0 DO  ACC I 1+ + TO ACC  LOOP  THEN ;

: B-RESET    ( flag -- v )       { F -- V }
    F IF  99 TO V  THEN ;

: B-SPLIT    ( n -- lo hi )      { N -- LO HI }
    N 10 MOD TO LO   N 10 / TO HI ;

: B-RFACT    ( n -- n! )         { N -- ACC }
    N 0= IF  1 TO ACC  ELSE  N 1- RECURSE  N *  TO ACC  THEN ;

: B-EIGHTMIX ( a b c d e f g -- n )    { A B C D E F G -- H }
    A B + C + D + E + F + G + TO H ;

T{  5 B-SUMTO                ->  15              }T
T{  0 B-SUMTO                ->  0               }T

\ V starts at 0 on every entry, even right after a call that set it to 99;
\ and if the body never assigns it, it stays 0 instead of leaking the
\ caller's value -- the case 12.6 is built to prevent.

T{  -1 B-RESET               ->  99              }T
T{   0 B-RESET               ->  0               }T

\ two outputs: declared-first ends up deepest, declared-second on top

T{  47 B-SPLIT               ->  7 4             }T

\ recursion with an output: each activation returns its own value

T{  5 B-RFACT                ->  120             }T

\ 7 input + 1 output: MAXLOCALS boundary with a split scope

T{  1 2 3 4 5 6 7 B-EIGHTMIX ->  28              }T

\ the two forms do not interfere: each scope replaces the previous one

T{  1 2 3 L-SUM3            ->  6               }T

\ ---------------------------------------------------------------------------
\ Not covered here, because a failure aborts instead of returning a value
\ and cannot be expressed as T{ ... }T. Verified by hand on the emulator.
\ Each line prints the offending token, then ? , then the message from the
\ standard error blocks -- listed by  9 LOAD  :
\
\   0 LOCALS-FOR ZZZ            -> #57 LOCALS: bad count.
\   9 LOCALS-FOR ZZZ ...        -> #57 LOCALS: bad count.
\   : OOPS LOCALS ;             -> #58 LOCALS: no scope declared.
\   scope, then an unrelated definition, then LOCALS
\                               -> #59 LOCALS: scope not adjacent.
\   FORTH then a local name     -> undefined (scoping works)
\   : OOPS { A B ;              -> #60 LOCALS: misplaced { or }.
\   : OOPS { } ;                -> #57 LOCALS: bad count.
\   : OOPS { 9 names } ;        -> #57 LOCALS: bad count.
\   : OOPS { A -- B -- C } ;    -> #60 LOCALS: misplaced { or }. (duplicate --)
\   }  on its own               -> #60 LOCALS: misplaced { or }.
\
\ Inside INCLUDE or LOAD the error also leaves  >IN BLK  on the stack, so
\ WHERE shows the offending screen, row and column.
\ ---------------------------------------------------------------------------

CR .( LOCALS-TESTS done. Type TESTING-TASK to unload. ) CR
