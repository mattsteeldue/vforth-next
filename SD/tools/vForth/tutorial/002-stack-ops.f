\
\ 002-stack-ops.f
\ Stack manipulation: the words that rearrange, copy, and discard cells
\ without performing arithmetic.
\
\ Mastering these is essential: Forth has no named local variables by
\ default, so all intermediate values live on the stack and must be
\ shuffled explicitly.  The diagrams below use the convention
\   ( before -- after )   with the rightmost item being TOS.
\
\ Reference: sec.2.12.2
\
\ Load from a clean session:
\   INCLUDE tutorial/002-stack-ops.f
\ To unload and reload interactively:
\   NO-STACK-OPS
\   INCLUDE tutorial/002-stack-ops.f
\

MARKER NO-STACK-OPS

CR
.( --- Tutorial 002: stack ops loaded. ) CR
.(     Type NO-STACK-OPS to unload.   ) CR


\ ===========================================================================
\ 1. The essential five
\ ===========================================================================
\
\ DUP  ( n -- n n )       duplicate TOS
\ DROP ( n -- )           discard TOS
\ SWAP ( n1 n2 -- n2 n1 ) exchange the two top cells
\ OVER ( n1 n2 -- n1 n2 n1 ) copy second cell onto top
\ ROT  ( n1 n2 n3 -- n2 n3 n1 ) rotate: pull the third cell to the top
\
\ Interactive examples  --  type these at the prompt:
\
\   1 2 3 .S           => 1 2 3
\   1 2 3 ROT .S       => 2 3 1
\   1 2 SWAP .S        => 2 1
\   1 2 OVER .S        => 1 2 1
\   1 2 3 DROP .S      => 1 2
\   42 DUP * .         => 1764    (square of 42)


\ ===========================================================================
\ 2. Removing and tucking
\ ===========================================================================
\
\ NIP  ( n1 n2 -- n2 )        drop the second cell, keep TOS
\ TUCK ( n1 n2 -- n2 n1 n2 )  copy TOS below the second cell
\ -ROT ( n1 n2 n3 -- n3 n1 n2 ) inverse of ROT
\
\   1 2 3 NIP  .S      => 1 3
\   1 2   TUCK .S      => 2 1 2
\   1 2 3 -ROT .S      => 3 1 2


\ ===========================================================================
\ 3. Conditional duplication
\ ===========================================================================
\
\ ?DUP ( n -- n n | 0 )   duplicates only if non-zero; leaves zero unchanged.
\ Useful to avoid an explicit IF 0= check before consuming a value.
\
\   0 ?DUP .S          => 0          (zero: unchanged)
\   7 ?DUP .S          => 7 7        (non-zero: duplicated)


\ ===========================================================================
\ 4. Generalised pick and rotate
\ ===========================================================================
\
\ PICK ( ... n -- ... nth )
\   Copies the n-th element (zero-based) to TOS without removing it.
\   0 PICK = DUP,  1 PICK = OVER.
\
\   10 20 30  0 PICK .S   => 10 20 30 30
\   10 20 30  1 PICK .S   => 10 20 30 20
\   10 20 30  2 PICK .S   => 10 20 30 10
\
\ ROLL ( ... k -- ... )
\   Rotates the k top cells, pulling the k-th to TOS.
\   1 ROLL = SWAP,  2 ROLL = ROT.
\   Not available at startup  --  must be imported.
\
\ NEEDS ROLL
\   10 20 30  2 ROLL .S   => 20 30 10    (same as ROT)


\ ===========================================================================
\ 5. Double-cell (32-bit) variants
\ ===========================================================================
\
\ A double-precision integer occupies two cells, MSCell on top (see sec.4.3).
\ The 2xxx words treat each pair as a single logical unit.
\
\ 2DUP  ( d -- d d )
\ 2DROP ( d -- )
\ 2SWAP ( d1 d2 -- d2 d1 )
\ 2OVER ( d1 d2 -- d1 d2 d1 )
\
\   1 2 3 4 2SWAP .S   => 3 4 1 2
\   1 2     2DUP  .S   => 1 2 1 2


\ ===========================================================================
\ 6. Demonstration words
\ ===========================================================================

: SQUARE  ( n -- n^2 )
    DUP * ;

: AVERAGE  ( n1 n2 -- avg )
    \ integer average: (n1+n2)/2
    + 2/ ;

: MIN-MAX  ( n1 n2 -- min max )
    \ leave both min and max without losing either value
    2DUP < IF SWAP THEN ;  \ if n1 < n2 already ordered; else swap

.( Try: 7 SQUARE .          ) CR
.( Try: 10 20 AVERAGE .     ) CR
.( Try: 30 10 MIN-MAX . .   ) CR


\ ===========================================================================
\ 7. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ NEEDS TESTING
\ T{  1 2    SWAP  -> 2 1       }T
\ T{  1 2    OVER  -> 1 2 1     }T
\ T{  1 2 3  ROT   -> 2 3 1     }T
\ T{  1 2    NIP   -> 2         }T
\ T{  1 2    TUCK  -> 2 1 2     }T
\ T{  0      ?DUP  -> 0         }T
\ T{  7      ?DUP  -> 7 7       }T
\ T{  5      SQUARE -> 25       }T
\ T{  10 20  AVERAGE -> 15      }T
