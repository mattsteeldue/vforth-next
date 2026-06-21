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
\ Starting FORTH (Brodie): Ch.4  |  vForth screens 816-820
\ Reference: sec.2.12.7
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   006 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 006 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 006: control flow loaded. ) CR
.(     Type NEWTASK to unload.   ) CR


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
CR
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
\           ?TERMINAL IF QUIT THEN
\       AGAIN ;
\
\ The only way to stop this infinite loop is pressing [BREAK] key


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
\ 7. ?ERROR  (conditional error with standard message)
\ ===========================================================================
\
\ f n ?ERROR
\
\ If f is true, displays standard error message n and aborts to the prompt.
\ Error messages are stored in Screen# 4-7 (BLOCK 8-15): they are part of
\ the block file and shared by all library code.  No string is compiled into
\ the definition -- just a one-cell error number.  This saves dictionary space
\ compared to ABORT" .
\
\   : SAFE-DIVIDE  ( n1 n2 -- n3 )
\       DUP 0=  13 ?ERROR
\       / ;
\
\   10 2 SAFE-DIVIDE .    => 5
\   10 0 SAFE-DIVIDE .    => error 13, abort to prompt

: SAFE-DIVIDE  ( n1 n2 -- n3 )
    DUP 0=  13 ?ERROR
    / ;

.( Try: 10 2 SAFE-DIVIDE .  ) CR
.( Try: 10 0 SAFE-DIVIDE .  ) CR    \ triggers error message 13

\ ===========================================================================
\ 8. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ NEEDS TESTING
\ T{  5  .POSITIVE ->        }T    \ side effect only; stack clean
\ T{  5  ABS-VAL  -> 5      }T
\ T{  -5 ABS-VAL  -> 5      }T
\ T{  0  ABS-VAL  -> 0      }T
