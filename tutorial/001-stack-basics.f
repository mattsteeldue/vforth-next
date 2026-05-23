\
\ 001-stack-basics.f
\ Introduction to the vForth calculator stack, basic arithmetic, and output.
\
\ vForth uses a single shared Calculator Stack (16-bit cells, see sec.4.2).
\ Every number you type is pushed onto it; every word consumes and/or
\ produces values on it.  The stack notation ( before -- after ) used
\ throughout this tutorial matches the convention in the reference manual.
\
\ Reference: sec.2.2, 2.9, 2.12.2, 2.12.4, 2.12.5
\
\ Load from a clean session:
\   INCLUDE tutorial/001-stack-basics.f
\ To unload and reload interactively:
\   NO-STACK-BASICS
\   INCLUDE tutorial/001-stack-basics.f
\

MARKER NO-STACK-BASICS

CR
.( --- Tutorial 001: stack basics loaded. ) CR
.(     Type NO-STACK-BASICS to unload.   ) CR


\ ===========================================================================
\ 1. Pushing numbers and printing them
\ ===========================================================================
\
\ Typing a number pushes it onto the stack.
\ . ( n -- ) removes and prints the top value, followed by a space.
\ U. ( u -- ) prints as unsigned; handy above 32767.
\
\   42 .          => 42
\   -1 .          => -1
\   65535 U.      => 65535
\
\ .S ( -- ) prints the whole stack without consuming it, useful for
\ inspecting intermediate state during interactive exploration.
\
\   1 2 3 .S      => 1 2 3    (stack contents, bottom to top)
\
\ DEPTH ( -- n ) leaves the current stack depth.
\
\   1 2 3 DEPTH . => 3


\ ===========================================================================
\ 2. Numeric base prefixes (see sec.2.9)
\ ===========================================================================
\
\ The default base is DECIMAL.  Prefix characters let you mix bases
\ without changing the global BASE variable:
\
\   $FF .        => 255    (hexadecimal)
\   #255 .       => 255    (decimal, explicit)
\   %11111111 .  => 255    (binary)
\
\ Switching the global base:
\   HEX   FF .   => FF
\   DECIMAL
\
\ Note: $ and % alone evaluate to zero; # is a built-in word.


\ ===========================================================================
\ 3. Basic arithmetic
\ ===========================================================================
\
\ All operators consume their arguments from the stack and push the result.
\
\   3 4 +  .      => 7
\   10 3 - .      => 7
\   6 7 *  .      => 42
\   22 7 / .      => 3       (integer quotient)
\   22 7 MOD .    => 1       (remainder)
\   22 7 /MOD . . => 1 3     (prints remainder then quotient)
\
\ 2* and 2/ are faster shift-based alternatives for 2 * and 2 /:
\
\   5 2* .        => 10
\   10 2/ .       => 5


\ ===========================================================================
\ 4. Signed vs unsigned: ABS and NEGATE
\ ===========================================================================
\
\   -7 ABS  .     => 7
\    7 NEGATE .   => -7


\ ===========================================================================
\ 5. Demonstration words
\ ===========================================================================

: SHOW-SUM   ( a b -- )
    \ Print "a + b = result" on one line.
    OVER .          \ print a (keep it on stack via OVER)
    .( + )
    DUP .           \ print b (keep it on stack via DUP)
    .( = )
    + .             \ consume both, print sum
    CR ;

: SHOW-DIVMOD  ( n1 n2 -- )
    \ Print quotient and remainder of n1/n2.
    2DUP            \ keep originals for MOD
    / .             \ quotient
    MOD .           \ remainder
    CR ;

.( Try: 22 7 SHOW-DIVMOD ) CR
.( Try: 100 37 SHOW-SUM  ) CR


\ ===========================================================================
\ 6. Simple tests (requires lib/testing.f  --  skip if not loaded)
\ ===========================================================================
\
\ Uncomment the block below after:  NEEDS TESTING
\
\ NEEDS TESTING
\ T{  3 4 +       -> 7          }T
\ T{  10 3 -      -> 7          }T
\ T{  6 7 *       -> 42         }T
\ T{  22 7 /      -> 3          }T
\ T{  22 7 MOD    -> 1          }T
\ T{  -7 ABS      -> 7          }T
\ T{  7 NEGATE    -> -7         }T
\ T{  5 2*        -> 10         }T
\ T{  10 2/       -> 5          }T
\ T{  $FF         -> 255        }T
\ T{  %11111111   -> 255        }T
