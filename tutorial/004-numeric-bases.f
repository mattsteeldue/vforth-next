\
\ 004-numeric-bases.f
\ Numeric bases: BASE, global switching, per-number prefixes,
\ double-precision literals, and the pitfalls to avoid.
\
\ BASE is a user variable (not a constant) that controls both input and
\ output conversions simultaneously.  This symmetry is a source of bugs
\ when not handled carefully: switching base for output also changes how
\ the interpreter reads the next number you type.
\
\ vForth extends the standard with single-number prefix characters that
\ temporarily override BASE without modifying it (see sec.2.9).  These
\ prefixes are the safest way to mix bases in source code.
\
\ Reference: sec.2.9, 2.12.5, 2.12.11
\
\ Load from a clean session:
\   INCLUDE tutorial/004-numeric-bases.f
\ To unload and reload interactively:
\   NO-NUMERIC-BASES
\   INCLUDE tutorial/004-numeric-bases.f
\

MARKER NO-NUMERIC-BASES

CR
.( --- Tutorial 004: numeric bases loaded. ) CR
.(     Type NO-NUMERIC-BASES to unload.   ) CR

NEEDS BINARY                        \ for BINARY in demonstration words


\ ===========================================================================
\ 1. BASE and the global switching words
\ ===========================================================================
\
\ BASE  ( -- a )    user variable address; holds the current radix.
\ DECIMAL           set BASE to 10
\ HEX               set BASE to 16
\ BINARY            set BASE to 2  (requires NEEDS BINARY at interpreter level)
\ OCTAL             set BASE to 8  (requires NEEDS OCTAL at interpreter level)
\
\ NEEDS is always interpreted, never compiled  --  it cannot appear inside
\ a colon-definition.  Load optional words before defining words that use them.
\
\ Both input *and* output follow BASE:
\
\   255 HEX .       => FF       (push 255 decimal, then switch, then print)
\   DECIMAL         (restore before typing anything else!)
\
\ The classic trap: if you type HEX and forget DECIMAL, the next number
\ you enter is read as hex  --  10 means sixteen, not ten.
\
\   BASE @ .        => 10       (decimal: shows current base value)


\ ===========================================================================
\ 2. Per-number prefix characters (see sec.2.9)
\ ===========================================================================
\
\ These prefixes override BASE for a single number only, without changing
\ BASE permanently.  They are the recommended way to embed non-decimal
\ literals in source code regardless of the current BASE.
\
\   $   hexadecimal    $FF  => 255
\   #   decimal        #255 => 255
\   %   binary         %11111111 => 255
\
\ Octal has no prefix  --  use OCTAL ... DECIMAL if you really need it.
\
\ Sign character comes *after* the prefix, not before:
\   #-33  .         => -33     (correct)
\   \ -#33          => error   (wrong order  --  parser fails)
\
\ Edge cases: $ and % alone (without digits) evaluate to zero because
\ (PREFIX) increments the parse pointer and (NUMBER) converts an empty
\ string to zero.  # alone is a dictionary word, not a numeric prefix.
\
\   $  .            => 0       ($ with no digits = zero)
\   %  .            => 0       (% with no digits = zero)


\ ===========================================================================
\ 3. Output formatting with a specified base
\ ===========================================================================
\
\ The clean pattern: push the number, switch, print, restore.
\
\   255 HEX . DECIMAL       => FF
\   255 HEX U. DECIMAL      => FF   (unsigned  --  same here, matters near 32767)
\
\ Inside definitions, prefer the prefix form to avoid a forgotten restore:
\
\   : .HEX  ( n -- )   HEX . DECIMAL ;
\
\ Warning: if . triggers an error mid-definition, DECIMAL is never reached
\ and BASE stays corrupted.  Defensive code saves and restores BASE@:
\
\   : .SAFE-HEX  ( n -- )
\       BASE @          \ save current base
\       HEX . 
\       BASE !  ;       \ restore whatever was there before


\ ===========================================================================
\ 4. Double-precision integer literals (see sec.2.9, 4.3)
\ ===========================================================================
\
\ Any number containing one of the punctuation marks  , . / - :
\ is interpreted as a double-precision (32-bit) integer, pushing two
\ cells onto the stack (LSCell below, MSCell on top).
\
\   120,000 .S      => 120000  0     (d: low=120000 high=0, shown as two cells)
\   3.14159 .S      => 314159  0     (decimal point is a separator, not float!)
\   1/23/45 .S      => 12345   0     (all punctuation acts the same way)
\
\ This is *not* floating point  --  the punctuation just signals "double".
\ The actual decimal position is recorded in DPL but not used here.
\ To print a double: D.
\
\   120,000 D.      => 120000
\
\ A lone punctuation character produces 0. 0 (double zero):
\   , .S            => 0  0


\ ===========================================================================
\ 5. Demonstration words
\ ===========================================================================

: .BASES  ( n -- )
    \ Print n in decimal, binary, and hex on one line.
    ." dec=" DUP DECIMAL .
    ." bin=" DUP BINARY .  DECIMAL
    ." hex=" HEX . DECIMAL CR ;

: .BYTE  ( b -- )
    \ Print an 8-bit value as $XX (always two hex digits).
    HEX
    S>D <#  #  #  [CHAR] $ HOLD  #>  TYPE
    DECIMAL CR ;

.( Try: 65 .BASES   ) CR
.( Try: $41 .BYTE   ) CR
.( Try: 120,000 D.  ) CR


\ ===========================================================================
\ 6. Summary of pitfalls
\ ===========================================================================
\
\ 1. Always restore DECIMAL after HEX (or save/restore BASE @ / BASE !).
\ 2. Push the number *before* switching base for output.
\ 3. Sign prefix goes after the base prefix: #-33 not -#33.
\ 4. $ and % alone are zero; # alone is a word.
\ 5. Any punctuation in a number makes it double (two cells on stack).
\ 6. BINARY and OCTAL require NEEDS  --  they are not in the core.


\ ===========================================================================
\ 7. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ NEEDS TESTING
\ T{  $FF          -> 255        }T
\ T{  #255         -> 255        }T
\ T{  %11111111    -> 255        }T
\ T{  $            -> 0          }T
\ T{  %            -> 0          }T
\ T{  120,000      -> 120000  0  }T   \ double-precision
