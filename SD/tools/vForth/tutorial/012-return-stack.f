\
\ 012-return-stack.f
\ The return stack: >R, R>, R@.
\
\ Forth has two stacks: the data (calculation) stack and the return
\ stack.  Normally the return stack is managed invisibly by CALL/RET
\ opcodes as words call each other.  The words >R, R>, and R@ give
\ direct access to it as a second scratch area for data.
\
\ Stack notation for return-stack words uses a separate (R: ) section:
\   >R  ( n -- ) ( R: -- n )   push n onto the return stack
\   R>  ( -- n ) ( R: n -- )   pop  n from  the return stack
\   R@  ( -- n ) ( R: n -- n ) copy the top of the return stack
\
\ The golden rule: EVERY >R inside a colon-definition must be balanced
\ by an R> (or R> DROP) before the word exits.  The compiler cannot
\ check this -- an unbalanced return stack will crash the interpreter.
\
\ Never use >R or R> outside a colon-definition, the interpreter will crash.
\
\ DO...LOOP places the loop limit and index on the return stack.
\ Never use >R inside a DO loop without a matching R> before LOOP,
\ as this corrupts the loop parameters.
\
\ All three words (>R, R>, R@) are in the core; no NEEDS required.
\
\ Reference: sec.2.12.2
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   012 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 012 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 012: return stack loaded. ) CR
.(     Type NEWTASK to unload.   ) CR


\ ===========================================================================
\ 1. Basic >R, R>, R@
\ ===========================================================================
\
\ Compiled examples:
\
\   : R-TEST
\       1 2                     (prepares two values)
\       >R .S           => 1    (2 is on return stack, invisible to .S)
\       R> .S   CR      => 1 2  (2 back on data stack)
\       >R R@ . CR      => 2    (R@ peeks)
\       R> DROP .       => 1    (R> retrieves)
\   ;   
\
\ In a definition, R@ copies the current top of the return stack
\ without disturbing it -- useful to read the value multiple times.


\ ===========================================================================
\ 2. Common pattern: set one value aside
\ ===========================================================================
\
\ When working with three values on a two-operand stack, >R provides a
\ clean way to "park" one while operating on the other two.
\
\ Without >R, this requires convoluted ROT/OVER/SWAP sequences.
\ With >R, the intent is clear: "set aside n3, work with n1 n2".
\
\   : ADD-SCALED  ( n1 n2 factor -- n1+n2*factor )
\       >R              ( n1 n2 )    ( R: factor )
\       R@ *            ( n1 n2*f )  ( R: factor )
\       +               ( sum )      ( R: factor )
\       R> DROP         ( sum )
\   ;
\
\   4 7 3 ADD-SCALED .   => 25    (4 + 7*3)


\ ===========================================================================
\ 3. CLAMP -- a practical three-argument example
\ ===========================================================================

: CLAMP  ( n lo hi -- n' )
    \ Constrain n to the range [lo, hi].
    >R              ( n lo )     ( R: hi )
    MAX             ( n|lo )
    R>              ( n|lo hi )
    MIN ;           ( n' )
CR
.( Try: -5 0 10 CLAMP .   ) CR    \ => 0
.( Try: 15 0 10 CLAMP .   ) CR    \ => 10
.( Try:  7 0 10 CLAMP .   ) CR    \ => 7


\ ===========================================================================
\ 4. R@ to read a loop limit
\ ===========================================================================
\
\ Inside a DO loop, the return stack holds [index, limit] (implementation
\ detail).  I  reads the index.  R@ during a DO loop is the same as  I. 
\ Instead  I' (NEEDS I')  reads the loop limit.
\
\ Wrong usage of R@: It can't be used in a word called FROM INSIDE a DO loop
\ if the caller pushes a value with >R before entering the loop and
\ pops it with R> after LOOP:
\
\   : .TIMES  ( n -- )
\       >R          ( )         ( R: n )
\       10 0 DO
\           R@ I *  .           \ use R@ is just as I
\       LOOP
\       R> DROP     ( )         \ retrieve the original  n 
\   ;


\ ===========================================================================
\ 5. The "do not" list
\ ===========================================================================
\
\ 1. DO NOT return from a word with items left on the return stack:
\      : BAD!  ( -- )  1 >R ;    \ wrong: R stack unbalanced 
\
\ 2. DO NOT use >R inside DO...LOOP without R> before LOOP:
\      : BAD2! ( -- )
\          10 0 DO  I >R  LOOP   \ wrong: pushes 10 values, pops none
\      ;
\
\ 3. DO NOT pass data between words via the return stack:
\      : PUSH-FOR-NEXT  1 >R ;      \ wrong: R> is in a different word
\      : POP-FROM-PREV  R> . ;      \ this will pop the return address!
\
\ These mistakes cause crashes that are hard to diagnose.


\ ===========================================================================
\ 6. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ NEEDS TESTING
\ T{  1 >R 2  R>   -> 2 1        }T
\ T{  5 >R   R@    -> 5          }T
\ T{  5 >R   R> DROP -> ( empty) }T
\ T{  -5 0 10 CLAMP  -> 0        }T
\ T{  15 0 10 CLAMP  -> 10       }T
\ T{   7 0 10 CLAMP  ->  7       }T
