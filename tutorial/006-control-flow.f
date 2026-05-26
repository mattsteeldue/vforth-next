\
\ 006-control-flow.f
\ Conditionals and unbounded loops: IF, BEGIN, and their variants.
\
\ All flow-control words in Forth are IMMEDIATE: they execute at compile
\ time to stitch together branch offsets inside the definition being built.
\ They only make sense inside a colon-definition  --  never at the prompt.
\
\ Flags: vForth follows the standard convention: zero is false (ff),
\ any non-zero value is true (tf).  The comparison words (=, <, >, 0=,
\ 0<, 0> ...) all leave 0 or -1 ($FFFF), but code must tolerate any
\ non-zero value as true.
\
\ vForth synonyms worth knowing:
\   THEN  =  ENDIF   (both close an IF structure)
\   END   =  UNTIL   (both close a BEGIN ... f loop)
\
\ Reference: sec.2.12.7
\
\ Load from a clean session:
\   INCLUDE tutorial/006-control-flow.f
\ To unload and reload interactively:
\   NO-CONTROL-FLOW
\   INCLUDE tutorial/006-control-flow.f
\

MARKER NO-CONTROL-FLOW

CR
.( --- Tutorial 006: control flow loaded. ) CR
.(     Type NO-CONTROL-FLOW to unload.   ) CR

NEEDS ABORT"                        \ for conditional abort


\ ===========================================================================
\ 1. IF ... THEN  (one-armed conditional)
\ ===========================================================================
\
\   f IF  <true-part>  THEN
\
\ Consumes f; executes <true-part> only when f is non-zero.
\ Stack must be balanced on both paths  --  the true-part must leave the
\ same number of cells as if it were skipped.
\
\   : .POSITIVE  ( n -- )
\       DUP 0> IF  ." positive"  THEN  DROP CR ;
\
\   5 .POSITIVE         => positive
\   -3 .POSITIVE        =>             (silent)

: .POSITIVE  ( n -- )
    DUP 0> IF  ." positive"  THEN  DROP CR ;


\ ===========================================================================
\ 2. IF ... ELSE ... THEN  (two-armed conditional)
\ ===========================================================================
\
\   f IF  <true-part>  ELSE  <false-part>  THEN
\
\ Exactly one branch executes; both must leave the same stack depth.

: .SIGN  ( n -- )
    0< IF  ." negative"  ELSE  ." non-negative"  THEN  CR ;

: ABS-VAL  ( n -- |n| )
    DUP 0< IF  NEGATE  THEN ;


\ ===========================================================================
\ 3. Nested IF and stack discipline
\ ===========================================================================
\
\ IFs can nest freely.  Each IF must have exactly one matching THEN.
\ The classic mistake is an unbalanced stack inside a branch.

: .CLASSIFY  ( n -- )
    DUP 0= IF
        ." zero"
    ELSE
        DUP 0> IF
            ." positive"
        ELSE
            ." negative"
        THEN
    THEN
    DROP CR ;

.( Try: -7 .CLASSIFY  0 .CLASSIFY  42 .CLASSIFY ) CR


\ ===========================================================================
\ 4. BEGIN ... AGAIN  (infinite loop)
\ ===========================================================================
\
\ BEGIN marks the loop start; AGAIN always jumps back to BEGIN.
\ The only exit is EXIT (early return) or a hardware reset.
\ Use only when the loop is intentionally unbounded  --  e.g. a main event loop.
\
\   : BLINK  ( -- )
\       BEGIN
\           ... toggle LED ...
\       AGAIN ;
\
\ Not demonstrated here because it would hang the interpreter.


\ ===========================================================================
\ 5. BEGIN ... f UNTIL  (post-test loop)
\ ===========================================================================
\
\ The body executes at least once.  UNTIL consumes f: loops back to BEGIN
\ when f is false (zero), exits when f is true (non-zero).
\ END is a synonym for UNTIL.
\
\   : COUNT-DOWN  ( n -- )
\       BEGIN
\           DUP . 1-
\           DUP 0<
\       UNTIL
\       DROP CR ;
\
\   5 COUNT-DOWN        => 5 4 3 2 1 0

: COUNT-DOWN  ( n -- )
    BEGIN
        DUP . 1-
        DUP 0<
    UNTIL
    DROP CR ;

\ Real-world pattern: wait for a key with [BREAK] as escape.
\ ?TERMINAL ( -- f ) returns true if [BREAK] is pressed.
\
\   : WAIT-BREAK  ( -- )
\       BEGIN  ?TERMINAL  UNTIL ;


\ ===========================================================================
\ 6. BEGIN ... f WHILE ... REPEAT  (pre-test loop)
\ ===========================================================================
\
\ WHILE consumes f: if true, continues into the loop body; if false, exits.
\ REPEAT always jumps back to BEGIN.  Unlike UNTIL, the body may never run.
\
\   : COUNT-UP  ( limit -- )
\       0 SWAP                  \ current  limit
\       BEGIN
\           2DUP <              \ current < limit ?
\       WHILE
\           OVER . SWAP 1+ SWAP \ print current, increment
\       REPEAT
\       2DROP CR ;
\
\   5 COUNT-UP          => 0 1 2 3 4

: COUNT-UP  ( limit -- )
    0 SWAP
    BEGIN
        2DUP <
    WHILE
        OVER . SWAP 1+ SWAP
    REPEAT
    2DROP CR ;

.( Try: 5 COUNT-DOWN ) CR
.( Try: 6 COUNT-UP   ) CR


\ ===========================================================================
\ 7. ABORT"  (conditional abort with message)
\ ===========================================================================
\
\ f ABORT" message"
\
\ If f is true, prints message and aborts to the command prompt.
\ Useful for defensive checks inside definitions.

: SAFE-DIVIDE  ( n1 n2 -- n3 )
    DUP 0= ABORT" division by zero"
    / ;

.( Try: 10 2 SAFE-DIVIDE .  ) CR
.( Try: 10 0 SAFE-DIVIDE .  ) CR    \ triggers abort


\ ===========================================================================
\ 8. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ NEEDS TESTING
\ T{  5  .POSITIVE ->        }T    \ side effect only; stack clean
\ T{  5  ABS-VAL  -> 5      }T
\ T{  -5 ABS-VAL  -> 5      }T
\ T{  0  ABS-VAL  -> 0      }T
