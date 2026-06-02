\
\ 007-loops.f
\ Counted loops: DO, LOOP, +LOOP, ?DO, LEAVE, I.
\
\ DO...LOOP is the Forth counted loop.  Unlike most languages the limit and
\ index are pushed in the order  limit index DO   --  limit first, index second.
\ This is the most common source of confusion for newcomers.
\
\ The loop continues while the index has NOT crossed the boundary between
\ limit-1 and limit.  For a simple ascending loop from 0 to N-1, write:
\   N 0 DO ... LOOP
\ The body executes for index = 0, 1, 2, ... N-1.  When LOOP increments
\ the index to N, the boundary is crossed and execution continues after LOOP.
\
\ Important: DO always executes the body at least once even when limit=index.
\ Use ?DO when a zero-iteration case is possible.
\
\ J and K (outer loop indices in nested loops) require NEEDS.  The manual
\ itself warns that deeply nested DO loops are poor Forth style  --  factor
\ instead.
\
\ Reference: sec.2.12.7
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   007 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 007 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 007: loops loaded. ) CR
.(     Type NEWTASK to unload.   ) CR


\ ===========================================================================
\ 1. BOUNDS  --  converting addr+len to end+start for DO loops
\ ===========================================================================
\
\ BOUNDS  ( addr len -- addr+len addr )
\
\ A built-in that converts a conventional address/length pair into the
\ limit/index pair expected by DO or ?DO.  Equivalent to OVER + SWAP.
\
\ This idiom appears constantly when iterating over byte arrays or strings.
\ The canonical example from the vForth source is TYPE itself:
\
\   : TYPE  ( a n -- )
\       BOUNDS ?DO  I C@ EMIT  LOOP ;
\
\ Without BOUNDS you would write:  OVER + SWAP ?DO ... LOOP
\ which is correct but less readable.

: DEMO-TYPE  ( a n -- )
    \ Reimplementation of TYPE using BOUNDS, for illustration.
    BOUNDS ?DO  I C@ EMIT  LOOP ;


\ ===========================================================================
\ 2. DO ... LOOP  (index increments by 1)
\ ===========================================================================
\
\ limit index DO  ... body ...  LOOP
\
\ I  ( -- n )   copies the current index to TOS (does not remove it).
\ I' ( -- n )   copies the loop *limit* to TOS.
\
\   : .RANGE  ( limit -- )
\       0 DO  I .  LOOP  CR ;
\
\   5 .RANGE            => 0 1 2 3 4
\
\ Counting down: set index above limit, step negatively with +LOOP (sec.3).
\
\   : .DOWN  ( n -- )
\       0 SWAP DO  I .  -1 +LOOP  CR ;   \ see section 3
\
\   5 .DOWN             => 5 4 3 2 1

: .RANGE  ( limit -- )
    0 DO  I .  LOOP  CR ;


\ ===========================================================================
\ 3. DO with non-zero start index
\ ===========================================================================
\
\ limit and index can be any values; the loop runs while index has not
\ crossed the limit-1/limit boundary in the ascending direction.
\
\   : .FROM-TO  ( start limit -- )
\       SWAP DO  I .  LOOP  CR ;
\
\   3 8 .FROM-TO        => 3 4 5 6 7

: .FROM-TO  ( start limit -- )
    SWAP DO  I .  LOOP  CR ;

.( Try: 5 .RANGE       ) CR
.( Try: 3 8 .FROM-TO   ) CR


\ ===========================================================================
\ 4. DO ... n +LOOP  (variable step)
\ ===========================================================================
\
\ n +LOOP adds n (signed) to the index each iteration.
\ The boundary check is the same as LOOP: exit when the boundary between
\ limit-1 and limit is crossed.
\
\   : .STEP2  ( limit -- )
\       0 DO  I .  2 +LOOP  CR ;
\
\   10 .STEP2           => 0 2 4 6 8
\
\ Descending loop: index starts above limit, step is negative.
\ Set limit one below the last value you want to print.
\
\   : .DOWN  ( n -- )   \ print n down to 1
\       0 SWAP 1+ DO  I .  -1 +LOOP  CR ;
\
\   5 .DOWN             => 5 4 3 2 1

: .STEP2  ( limit -- )
    0 DO  I .  2 +LOOP  CR ;

: .DOWN  ( n -- )
    0 SWAP 1+ DO  I .  -1 +LOOP  CR ;

.( Try: 10 .STEP2  ) CR
.( Try: 5 .DOWN    ) CR


\ ===========================================================================
\ 5. LEAVE  (early exit)
\ ===========================================================================
\
\ LEAVE exits the innermost DO loop immediately, jumping to the instruction
\ after the corresponding LOOP or +LOOP.  Loop parameters are discarded.
\ Typically used inside an IF.
\
\   : FIND-FIRST-ZERO  ( addr len -- idx | -1 )
\       \ Return index of first zero byte, or -1 if none found.
\       OVER + SWAP           \ end start
\       DO
\           I C@ 0= IF
\               I            \ leave index on stack
\               LEAVE
\           THEN
\       LOOP
\       \ if LEAVE was taken, I is on stack; otherwise push sentinel
\       \ (simplification: real code would use a flag variable)
\       ;
\
\ Note: after LEAVE the code after LOOP executes normally  --  LEAVE does
\ not return from the definition.  Use EXIT after LEAVE if needed.


\ ===========================================================================
\ 6. ?DO  (zero-trip guard)
\ ===========================================================================
\
\ ?DO behaves like DO but skips the entire loop body when limit = index
\ and no iteration has to be performed.
\
\   : .SAFE-RANGE  ( limit -- )
\       0 ?DO  I .  LOOP  CR ;
\
\   0 .SAFE-RANGE       =>             (silent -- DO would execute 65536 times)
\   3 .SAFE-RANGE       => 0 1 2

: .SAFE-RANGE  ( limit -- )
    0 ?DO  I .  LOOP  CR ;

.( Try: 0 .SAFE-RANGE  ) CR
.( Try: 3 .SAFE-RANGE  ) CR


\ ===========================================================================
\ 7. Nested loops and J  (requires NEEDS J)
\ ===========================================================================
\
\ Inside a nested DO loop, I returns the inner index, J the outer index.
\ K (NEEDS K) gives the second outer index in triple nesting.
\
\ As the manual notes, nesting DO loops more than two levels deep is poor
\ Forth style -- the inner body should be factored into a separate definitions.
\
\ NEEDS J
\   : MULTIPLICATION-TABLE  ( n -- )
\       1+ 1 DO                  \ outer: rows 1..n
\           1+ 1 DO              \ inner: cols 1..n
\               J I * 4 .R       \ J=row, I=col
\           LOOP
\           CR
\       LOOP ;
\
\   5 MULTIPLICATION-TABLE


\ ===========================================================================
\ 8. Practical example: SUM and FILL-ARRAY
\ ===========================================================================

: SUM-1-TO  ( n -- sum )
    \ Sum of integers 1..n using a DO loop.
    0 SWAP                      \ accumulator  limit
    1+ 1 DO  I +  LOOP ;        \ add I for I = 1, 2, ... n

: FILL-ARRAY  ( addr n val -- )
    \ Store val into n consecutive cells starting at addr.
    SWAP 0 ?DO                  \ ?DO guards against n=0
        2DUP SWAP I CELLS + !   \ store val at addr+I*2
    LOOP
    2DROP ;

.( Try: 10 SUM-1-TO .  ) CR     \ => 55


\ ===========================================================================
\ 9. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ NEEDS TESTING
\ T{  5  SUM-1-TO  -> 15        }T
\ T{  10 SUM-1-TO  -> 55        }T
\ T{  0 .SAFE-RANGE ->          }T   \ no output, no crash
