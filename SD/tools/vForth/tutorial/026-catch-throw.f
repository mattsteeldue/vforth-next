\
\ 026-catch-throw.f
\ Exception handling: CATCH, THROW, ABORT.
\
\ Forth's exception model is lightweight and explicit.  THROW signals
\ an exception with a numeric code; CATCH intercepts it and returns
\ the code to the caller.  A code of 0 means "no exception".
\
\ THROW ( n -- ) : if n=0, does nothing.  If n<>0, unwinds the return
\ stack to the most recent CATCH and transfers execution there.
\ CATCH ( xt -- n ) : execute xt.  If THROW occurs, return the throw
\ code.  If xt completes normally, return 0.
\
\ Standard negative throw codes (reserved by ANS/ISO Forth):
\   -1  ABORT
\   -2  ABORT" (with message)
\  -13  undefined word
\  -14  interpreting a compile-only word
\  ...  (see Forth standard appendix)
\ User-defined codes: positive integers are conventionally free.
\
\ ABORT (core) is an unconditional abort that always returns to the
\ interactive prompt.  It clears both stacks regardless of CATCH.
\
\ All four require NEEDS: CATCH, THROW, ABORT" (already in 006),
\ and ABORT is core.
\
\ Starting FORTH (Brodie): no Brodie counterpart (vForth extension)
\ Reference: sec.5
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   026 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 026 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 026: exceptions loaded. ) CR
.(     Type NEWTASK to unload.  ) CR

NEEDS CATCH
NEEDS THROW
NEEDS ABORT"
NEEDS SQRT

CR

\ ===========================================================================
\ 1. THROW -- signalling an exception
\ ===========================================================================
\
\ 0 THROW   is always a no-op (success path).
\ n THROW   (n<>0) transfers to the nearest CATCH.
\
\ Convention used in this tutorial: user error codes are positive.
\
\   10 CONSTANT ERR-NOT-FOUND
\   20 CONSTANT ERR-OVERFLOW
\   30 CONSTANT ERR-BAD-ARG

10 CONSTANT ERR-NOT-FOUND
20 CONSTANT ERR-OVERFLOW
30 CONSTANT ERR-BAD-ARG


\ ===========================================================================
\ 2. CATCH -- intercepting exceptions
\ ===========================================================================
\
\ CATCH executes an xt (execution token, obtained with '):
\   ['] word  CATCH  n
\ If word completes normally, n = 0.
\ If word THROWs code c, execution jumps out of word and n = c.
\
\ A word that might throw:
: SAFE-SQRT  ( n -- sqrt )
    DUP 0< IF  ERR-BAD-ARG THROW  THEN
    SQRT ;              \ SQRT requires NEEDS SQRT; use a simple version

\ Wrapper that uses CATCH:
: TRY-SQRT  ( n -- sqrt | 0 )
    ['] SAFE-SQRT  CATCH
    DUP IF
        ." Error " . ." (sqrt of negative)" CR  DROP  0
    THEN ;


\ ===========================================================================
\ 3. Structuring safe operations
\ ===========================================================================
\
\ The standard pattern:
\
\   : SAFE-OP  ( args -- result )
\       ['] risky-op  CATCH
\       DUP 0<> IF
\           \ handle error: n is the throw code
\           ." Error: " . CR
\           ( clean up the args if needed )
\       THEN  DROP ;

: SAFE-DIV  ( n1 n2 -- n3 )
    \ Integer division with divide-by-zero detection.
    DUP 0= IF  ERR-BAD-ARG THROW  THEN
    / ;

: PROTECTED-DIV  ( n1 n2 -- n3 | 0 )
    ['] SAFE-DIV  CATCH
    DUP IF
        ." Division error " . CR  2DROP  0
    ELSE
        DROP
    THEN ;
CR
.( Try: 10 2 PROTECTED-DIV .  ) CR    \ => 5
.( Try: 10 0 PROTECTED-DIV .  ) CR    \ => Division error, 0


\ ===========================================================================
\ 4. Cleanup with nested CATCH
\ ===========================================================================
\
\ THROW unwinds the return stack all the way back to the matching
\ CATCH; any intermediate >R values are automatically discarded.
\ This means CATCH provides automatic cleanup of the return stack.
\
\ For data-stack cleanup, use a saved stack depth:

: WITH-CLEANUP  ( n -- n | 0 )
    \ Square root, returning 0 on any error.  Demonstrates cleanup.
    DUP  >R               \ save original for message
    ['] SAFE-DIV  CATCH
    DUP IF
        R> DROP  DROP  0  \ discard saved, drop n1 n2, return 0
    ELSE
        R> DROP           \ discard saved, result already on stack
    THEN ;


\ ===========================================================================
\ 5. ABORT" revisited in context
\ ===========================================================================
\
\ ABORT" ( f -- ) is built on THROW -2.  It is the right tool for
\ fatal pre-condition checks inside a definition where there is no
\ recovery needed:
\
\   : POSITIVE-ONLY  ( n -- n )
\       DUP 0<= ABORT" requires a positive number" ;
\
\ If ABORT" is called inside a CATCH, the catch sees throw code -2.

: POSITIVE-ONLY  ( n -- n )
    DUP 0> NOT ABORT" requires a positive number" ;

.( Try: 5 POSITIVE-ONLY .   ) CR   \ => 5
.( Try: 0 POSITIVE-ONLY .   ) CR   \ aborts with message


\ ===========================================================================
\ 6. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ NEEDS TESTING
\ T{  0 THROW          ->      }T    \ 0 THROW is a no-op
\ T{  10 2 PROTECTED-DIV -> 5  }T
\ T{  10 0 PROTECTED-DIV -> 0  }T   \ error caught, returns 0
\ T{  ['] POSITIVE-ONLY CATCH -> -2 }T   \ ABORT" throws -2 (no arg)
